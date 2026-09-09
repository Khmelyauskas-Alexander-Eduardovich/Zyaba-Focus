#include "retrohost.h"
#include <QtEndian>
#include <QCoreApplication>
#include <QDir>
#include <QFileInfo>
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <Qt>
#include <QImage>
#include <QProcess>
#include <QInputEvent>
#include <QInputMethod>
#include <QMap>
#include <QVariant>
#include <QThread>
#include <QtGui/private/qzipreader_p.h>
#include <QUrl>
#include <QSysInfo>
#include <QStandardPaths>

static QString detectJavaExecutable(const QString &appDir)
{
#ifdef Q_OS_WIN
    // 1. Проверяем вшитую Windows JRE
    QString winJava = QDir(appDir).filePath("jre/bin/java.exe");
    if (QFileInfo::exists(winJava)) return winJava;
    winJava = QDir(appDir).filePath("Windows_JVM/jre/bin/java.exe");
    if (QFileInfo::exists(winJava)) return winJava;
    return "java.exe";
#else
    // 2. Ищем универсальный путь (когда Qbs при сборке скопировал нужную JRE в jre/)
    QString bundledJava = QDir(appDir).filePath("jre/bin/java");
    if (QFileInfo::exists(bundledJava)) return bundledJava;

    // 3. Определяем архитектуру системы через QSysInfo
    QString arch = QSysInfo::buildCpuArchitecture().toLower();
    QString archSubDir;

    if (arch == "arm" || arch == "armhf" || arch == "armv7l" || arch == "armv7a" || arch == "arm-linux-gnueabihf") {
        archSubDir = "armhf";
    } else if (arch == "arm64" || arch == "aarch64") {
        archSubDir = "arm64";
    } else if (arch == "x86_64" || arch == "amd64") {
        archSubDir = "x86_64";
    }

    if (!archSubDir.isEmpty()) {
        QString archJava = QDir(appDir).filePath(QString("Linux_JVM/%1/jre/bin/java").arg(archSubDir));
        if (QFileInfo::exists(archJava)) return archJava;
    }

    // 4. Fallback: системная Java из $PATH
    return "java";
#endif
}

// Структура с результатами парсинга JAR
struct JarMetadata {
    QString suiteName;
    QImage icon;
};

JarMetadata extractJarMetadata(const QString &jarPath)
{
    JarMetadata meta;
    meta.suiteName = QFileInfo(jarPath).completeBaseName(); // Fallback по умолчанию

    if (!QFileInfo::exists(jarPath)) return meta;

    QZipReader zip(jarPath);
    if (zip.status() != QZipReader::NoError) return meta;

    // 1. Читаем MANIFEST.MF прямо из архива
    QByteArray manifestData = zip.fileData("META-INF/MANIFEST.MF");
    if (manifestData.isEmpty()) {
        zip.close();
        return meta;
    }

    QString iconPathInZip;
    QTextStream stream(manifestData);

    while (!stream.atEnd()) {
        QString line = stream.readLine().trimmed();

        if (line.startsWith("MIDlet-1:", Qt::CaseInsensitive)) {
	   // Формат строки в MANIFEST.MF: MIDlet-1: Name, /icon.png, Class
	   QString val = line.section(':', 1).trimmed();
	   QStringList parts = val.split(',');

	   if (!parts.isEmpty()) {
	       QString rawName = parts.at(0).trimmed();
	       rawName.remove(':'); // Ровно как в MIDletLoader.java
	       if (!rawName.isEmpty()) {
		  meta.suiteName = rawName;
	       }
	   }

	   if (parts.size() >= 2) {
	       iconPathInZip = parts.at(1).trimmed();
	       if (iconPathInZip.startsWith('/')) {
		  iconPathInZip.remove(0, 1); // Убираем слэш в начале пути для ZIP
	       }
	   }
        }
    }

    // 2. Если нашли путь к иконке — вытаскиваем её из архива
    if (!iconPathInZip.isEmpty()) {
        QByteArray iconData = zip.fileData(iconPathInZip);
        if (!iconData.isEmpty()) {
	   meta.icon.loadFromData(iconData);
        }
    }

    zip.close();
    return meta;
}


QString getMidletSuiteName(const QString &jarPath)
{
    // Быстрое извлечение MANIFEST.MF через системную утилиту (на Ubuntu/WSL/Linux)
    QProcess unzip;
    unzip.start("unzip", QStringList() << "-p" << jarPath << "META-INF/MANIFEST.MF");
    if (!unzip.waitForFinished(1000)) {
        return QFileInfo(jarPath).completeBaseName(); // Fallback на имя файла
    }

    QByteArray manifestData = unzip.readAllStandardOutput();
    QTextStream stream(manifestData);

    while (!stream.atEnd()) {
        QString line = stream.readLine().trimmed();
        if (line.startsWith("MIDlet-1:", Qt::CaseInsensitive)) {
	   QString val = line.section(':', 1).trimmed();
	   QString midletName = val.split(',').first().trimmed();

	   // Повторяем ровно ту же логику очистки, что и в MIDletLoader.java:
	   midletName.remove(':');
	   return midletName;
        }
    }

    return QFileInfo(jarPath).completeBaseName();
}

static int translateQtKeyToJ2ME(int key)
{
    switch (key) {
        // Soft Keys (LSK = 9, RSK = 8)
        case Qt::Key_F1:
        case Qt::Key_Q:         return 9;
        case Qt::Key_F2:
        case Qt::Key_W:         return 8;

        // D-Pad / Навигация
        case Qt::Key_Up:        return 0;
        case Qt::Key_Down:      return 1;
        case Qt::Key_Left:      return 2;
        case Qt::Key_Right:     return 3;
        case Qt::Key_Return:
        case Qt::Key_Enter:
        case Qt::Key_Space:
        case Qt::Key_Select:    return 7;

        // Цифровой блок (Numpad)
        case Qt::Key_1:         return 10;
        case Qt::Key_2:         return 14;
        case Qt::Key_3:         return 11;
        case Qt::Key_4:         return 15;
        case Qt::Key_5:         return 18;
        case Qt::Key_6:         return 16;
        case Qt::Key_7:         return 5;
        case Qt::Key_8:         return 17;
        case Qt::Key_9:         return 4;
        case Qt::Key_Asterisk:  return 12;
        case Qt::Key_0:         return 6;
        case Qt::Key_NumberSign: return 13;

        default:
	   if (key >= 0 && key <= 19) {
	       return key;
	   }
	   return -1;
    }
}

RetroHost::RetroHost(QObject *parent)
    : QObject(parent)
{
    connect(&m_process, &QProcess::readyReadStandardOutput, this, &RetroHost::onReadyReadStandardOutput);
    connect(&m_process, &QProcess::readyReadStandardError, this, &RetroHost::onReadyReadStandardError);
    connect(&m_process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
	  this, &RetroHost::onProcessFinished);
    connect(&m_process, &QProcess::errorOccurred, this, &RetroHost::onProcessError);
}

RetroHost::~RetroHost()
{
    stop();
}

QVariantMap RetroHost::loadGameConfig(const QString &appName)
{
    QVariantMap configMap;
    if (appName.isEmpty()) return configMap;

    //Daily Broston "Gogoro Ze Autzia" - Missing conf file in Ubuntu Touch environment + fix-up of QML bug, so as QML with C++ parsing the conf file and converts into visual value
#ifdef Q_OS_WIN
    QString appDir = QCoreApplication::applicationDirPath();
#else
    QString appDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
#endif
    //DBGZA end! [!]

    // Папка config лежит ПРЯМО в appDir, а не уровнем выше!
    QDir dir(appDir);
    QString configFilePath = dir.filePath(QString("config/%1/game.conf").arg(appName));

    QFileInfo checkFile(configFilePath);
    if (!checkFile.exists() || !checkFile.isFile()) {
        emit logMessage(QString("[C++ Config] File not found: %1").arg(configFilePath));
        return configMap;
    }

    QFile file(configFilePath);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&file);
        while (!in.atEnd()) {
	   QString line = in.readLine().trimmed();
	   if (line.isEmpty() || line.startsWith("#")) continue;

	   int sepIdx = line.indexOf(':');
	   if (sepIdx != -1) {
	       QString key = line.left(sepIdx).trimmed().toLower(); // приводим ключ к lowerCase
	       QString val = line.mid(sepIdx + 1).trimmed();
	       configMap.insert(key, val);
	   }
        }
        file.close();
        emit logMessage(QString("[C++ Config] Successfully loaded config for: %1").arg(appName));
    }

    return configMap;
}

QVariantMap RetroHost::loadConfigForGamePath(const QString &gamePath)
{
    if (gamePath.isEmpty()) return QVariantMap();

    // 1. Извлекаем имя сюиты из MANIFEST.MF
    JarMetadata meta = extractJarMetadata(gamePath);

    // 2. Ищем config/suiteName/game.conf
    QVariantMap config = loadGameConfig(meta.suiteName);

    // 3. Fallback на имя .jar файла
    if (config.isEmpty()) {
        QFileInfo fi(gamePath);
        config = loadGameConfig(fi.completeBaseName());
    }

    return config;
}
void RetroHost::start(const QString &jarPath, const QString &gamePath)
{
    if (m_process.state() != QProcess::NotRunning) {
        stop();
    }

    m_buffer.clear();

    QString appDir = qgetenv("APP_DIR");
    if (appDir.isEmpty()) {
        appDir = QCoreApplication::applicationDirPath();
    }

    // Автоматическое определение пути к java бинарнику под архитектуру
    QString javaExec = detectJavaExecutable(appDir);

    QString effectiveJar = jarPath;
    if (effectiveJar.isEmpty() || !QFileInfo::exists(effectiveJar)) {
        effectiveJar = QDir(appDir).filePath("freej2me.jar");
    }

    QString cleanGame = gamePath;
    if (cleanGame.startsWith("file://")) {
        cleanGame = QUrl(cleanGame).toLocalFile();
    }
    cleanGame = QDir::cleanPath(cleanGame);

    JarMetadata meta = extractJarMetadata(cleanGame);
    QString appName = meta.suiteName;

    if (m_suitName != meta.suiteName) {
        m_suitName = meta.suiteName;
        emit suitNameChanged();
    }

    QString cleanJarPath = QDir::cleanPath(effectiveJar);

    // Важно для Linux / Ubuntu Touch: раздельный вывод каналов stdout/stderr
    m_process.setProcessChannelMode(QProcess::SeparateChannels);

    // --- Настройка рабочей директории и аргументов JVM ---
    QString targetWorkDir = appDir;

#ifndef Q_OS_WIN
    // 1. Уровень перестраховки #1: Стандартная writable-директория приложения
    targetWorkDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);

    // 2. Уровень перестраховки #2: Если папка не создалась, уходим в /tmp
    if (targetWorkDir.isEmpty() || !QDir().mkpath(targetWorkDir)) {
        targetWorkDir = QStandardPaths::writableLocation(QStandardPaths::TempLocation);
        QDir().mkpath(targetWorkDir);
    }
#endif

    QStringList arguments;
    arguments
	     << "-Djava.awt.headless=true"
	     << "-Dfile.encoding=ISO_8859_1" // Вместо UTF-8 ставим ISO-8859-1
	     << "-Dfreej2me.debug=true";

#ifndef Q_OS_WIN
    // 3. Уровень перестраховки #3: Принудительный Duser.dir для Java
    // Гарантирует, что JVM считает рабочей папкой разрешенную директорию
    if (!targetWorkDir.isEmpty()) {
        arguments << QString("-Duser.dir=%1").arg(targetWorkDir);
    }
#endif

    arguments << "-jar"
	     << cleanJarPath
	     << cleanGame
	     << "240"
	     << "320";

    emit logMessage(QString("[C++] Launching: %1 %2").arg(javaExec, arguments.join(" ")));

    // Применяем вычисленную директорию
    m_process.setWorkingDirectory(targetWorkDir);
    m_process.start(javaExec, arguments);

    if (!m_process.waitForStarted(3000)) {
        emit logMessage(QString("[C++ ERROR] Process start failed: %1").arg(m_process.errorString()));
    } else {
        emit logMessage(QString("[C++ SUCCESS] Started PID: %1").arg(m_process.processId()));

        QThread::msleep(500);

        QVariantMap config = loadConfigForGamePath(cleanGame);
        if (!config.isEmpty()) {
	   int fps = config.value("fps", 60).toInt();
	   int w = config.value("scrwidth", 240).toInt();
	   int h = config.value("scrheight", 320).toInt();
	   int rot = config.value("rotate", 0).toInt();

	   QString hackStr = config.value("fpshack", "Disabled").toString().toLower();
	   int hackIndex = (hackStr == "safe") ? 1 : (hackStr == "extended") ? 2 : (hackStr == "aggressive") ? 3 : 0;

	   QString bgStr = config.value("backlightcolor", "Disabled").toString().toLower();
	   int bgIndex = 0;
	   if (bgStr == "green") bgIndex = 1;
	   else if (bgStr == "cyan") bgIndex = 2;
	   else if (bgStr == "orange") bgIndex = 3;
	   else if (bgStr == "violet") bgIndex = 4;
	   else if (bgStr == "red") bgIndex = 5;

	   setFpsLimit(fps);
	   setFpsHack(hackIndex);
	   setBacklightColor(bgIndex);
	   setResolution(w, h);
	   setRotation(rot);

	   emit configLoaded(config);
        }
    }

    emit runningChanged();
}


void RetroHost::stop()
{
    if (m_process.state() != QProcess::NotRunning) {
        m_process.terminate();
        if (!m_process.waitForFinished(1000)) {
	   m_process.kill();
	   m_process.waitForFinished(500); // Обязательно даём ОС забрать PID
        }
    }
    emit runningChanged();
}

bool RetroHost::isRunning() const
{
    return m_process.state() != QProcess::NotRunning;
}

void RetroHost::sendKeyPress(int keyCode)
{
    if (!isRunning()) return;
    int j2meKey = translateQtKeyToJ2ME(keyCode);
    if (j2meKey < 0) return;

    QByteArray packet;
    packet.append(static_cast<char>(0x01));
    quint32 code = qToBigEndian<quint32>(static_cast<quint32>(j2meKey));
    packet.append(reinterpret_cast<const char*>(&code), sizeof(code));

    m_process.write(packet);
}

void RetroHost::sendKeyRelease(int keyCode)
{
    if (!isRunning()) return;
    int j2meKey = translateQtKeyToJ2ME(keyCode);
    if (j2meKey < 0) return;

    QByteArray packet;
    packet.append(static_cast<char>(0x02));
    quint32 code = qToBigEndian<quint32>(static_cast<quint32>(j2meKey));
    packet.append(reinterpret_cast<const char*>(&code), sizeof(code));

    m_process.write(packet);
}

void RetroHost::sendPointerPressed(int x, int y)
{
    if (!isRunning()) return;
    QByteArray packet;
    packet.append(static_cast<char>(0x03));
    quint32 bx = qToBigEndian<quint32>(static_cast<quint32>(x));
    quint32 by = qToBigEndian<quint32>(static_cast<quint32>(y));
    packet.append(reinterpret_cast<const char*>(&bx), sizeof(bx));
    packet.append(reinterpret_cast<const char*>(&by), sizeof(by));

    m_process.write(packet);
}

void RetroHost::sendPointerReleased(int x, int y)
{
    if (!isRunning()) return;
    QByteArray packet;
    packet.append(static_cast<char>(0x04));
    quint32 bx = qToBigEndian<quint32>(static_cast<quint32>(x));
    quint32 by = qToBigEndian<quint32>(static_cast<quint32>(y));
    packet.append(reinterpret_cast<const char*>(&bx), sizeof(bx));
    packet.append(reinterpret_cast<const char*>(&by), sizeof(by));

    m_process.write(packet);
}

void RetroHost::setFpsLimit(int fps)
{
    if (!isRunning()) return;
    QByteArray packet;
    packet.append(static_cast<char>(0x05));
    quint32 val = qToBigEndian<quint32>(static_cast<quint32>(fps));
    packet.append(reinterpret_cast<const char*>(&val), sizeof(val));
    m_process.write(packet);
}

void RetroHost::setFpsHack(int hack)
{
    if (!isRunning()) return;
    QByteArray packet;
    packet.append(static_cast<char>(0x06));
    quint32 val = qToBigEndian<quint32>(static_cast<quint32>(hack));
    packet.append(reinterpret_cast<const char*>(&val), sizeof(val));
    m_process.write(packet);
}

void RetroHost::setBacklightColor(int index)
{
    if (!isRunning()) return;
    QByteArray packet;
    packet.append(static_cast<char>(0x07));
    quint32 val = qToBigEndian<quint32>(static_cast<quint32>(index));
    packet.append(reinterpret_cast<const char*>(&val), sizeof(val));
    m_process.write(packet);
}

void RetroHost::setResolution(int width, int height)
{
    if (!isRunning()) return;
    QByteArray packet;
    packet.append(static_cast<char>(0x08));
    quint32 w = qToBigEndian<quint32>(static_cast<quint32>(width));
    quint32 h = qToBigEndian<quint32>(static_cast<quint32>(height));
    packet.append(reinterpret_cast<const char*>(&w), sizeof(w));
    packet.append(reinterpret_cast<const char*>(&h), sizeof(h));
    m_process.write(packet);
}

void RetroHost::setRotation(int degrees)
{
    if (!isRunning()) return;
    QByteArray packet;
    packet.append(static_cast<char>(0x09));
    quint32 val = qToBigEndian<quint32>(static_cast<quint32>(degrees));
    packet.append(reinterpret_cast<const char*>(&val), sizeof(val));
    m_process.write(packet);
}

void RetroHost::onReadyReadStandardOutput()
{
    m_buffer.append(m_process.readAllStandardOutput());
    parseBuffer();
}

void RetroHost::onReadyReadStandardError()
{
	   QString err = QString::fromUtf8(m_process.readAllStandardError()).trimmed();
	       if (!err.isEmpty()) {
		  emit logMessage(QString("[FreeJ2ME]: %1").arg(err));
	       }
}

void RetroHost::onProcessError(QProcess::ProcessError error)
{
    Q_UNUSED(error);
    emit logMessage(QString("[C++ QProcess Error]: %1").arg(m_process.errorString()));
}

void RetroHost::onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    emit logMessage(QString("[C++ Process Exit] Code: %1, Status: %2")
        .arg(exitCode).arg(exitStatus == QProcess::NormalExit ? "Normal" : "Crashed"));
    emit runningChanged();
}

void RetroHost::parseBuffer()
{
    const char magic[4] = {'F', 'R', 'A', 'M'};

    while (true) {
        if (m_buffer.size() < 8) return;

        int magicPos = m_buffer.indexOf(QByteArray(magic, 4));

        if (magicPos > 0) {
	   QByteArray logChunk = m_buffer.left(magicPos);
	   emit logMessage(QString("[FreeJ2ME Out]: %1").arg(QString::fromUtf8(logChunk).trimmed()));
	   m_buffer.remove(0, magicPos);
        }

        if (magicPos == -1) {
	   if (!m_buffer.isEmpty() && m_buffer.size() < 4) {
	       // Оставляем хвостик для следующего чтения
	       return;
	   }
	   // Если магии нет совсем, но буфер забит — чистим, чтобы не раздувать память
	   if (m_buffer.size() >= 4) {
	       m_buffer.remove(0, m_buffer.size() - 3);
	   }
	   return;
        }

        // Проверяем, хватает ли байт на заголовки ширины и высоты
        if (m_buffer.size() < magicPos + 8) return;

        quint16 width = qFromBigEndian<quint16>(reinterpret_cast<const uchar*>(m_buffer.constData() + magicPos + 4));
        quint16 height = qFromBigEndian<quint16>(reinterpret_cast<const uchar*>(m_buffer.constData() + magicPos + 6));

        if (width == 0 || height == 0 || width > 2048 || height > 2048) {
	   // Мусор вместо размеров — сдвигаем на 1 байт вперед от текущего FRAM, чтобы искать дальше
	   m_buffer.remove(0, magicPos + 1);
	   continue;
        }

        int frameDataBytes = width * height * 4;
        int totalPacketSize = magicPos + 8 + frameDataBytes;

        if (m_buffer.size() < totalPacketSize) {
	   // Кадр еще не доехал целиком, ждем остаток
	   return;
        }

        // Вырезаем мусор до пакета, если он был
        if (magicPos > 0) {
	   m_buffer.remove(0, magicPos);
        }

        QImage frame(width, height, QImage::Format_RGB32);
        const uchar *src = reinterpret_cast<const uchar*>(m_buffer.constData() + 8);
        QRgb *dest = reinterpret_cast<QRgb*>(frame.bits());

        int totalPixels = width * height;
        for (int i = 0; i < totalPixels; ++i) {
	   uchar r = src[i * 4 + 0];
	   uchar g = src[i * 4 + 1];
	   uchar b = src[i * 4 + 2];
	   dest[i] = qRgb(r, g, b);
        }

        emit frameReady(frame);
        m_buffer.remove(0, totalPacketSize);
    }
}
