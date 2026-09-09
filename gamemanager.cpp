#include "gamemanager.h"
#include <QCoreApplication>
#include <QStandardPaths>
#include <QTextStream>
#include <QImage>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QFile>
#include <QDir>
#include <QRegExp>
#include <QtGui/private/qzipreader_p.h>
#include <QDebug>
#include <QUrl>

GameManager::GameManager(QObject *parent) : QObject(parent) {}

QString GameManager::customGamesPath() const
{
    return m_customGamesPath;
}

void GameManager::setCustomGamesPath(const QString &path)
{
    QString clean = QDir::cleanPath(path);
    if (clean.startsWith("file://")) {
        clean = QUrl(clean).toLocalFile();
    }

    if (m_customGamesPath != clean) {
        m_customGamesPath = clean;
        emit customGamesPathChanged();
    }
}

QString GameManager::getEffectiveGamesDir() const
{
    QString targetDir = m_customGamesPath;

    if (targetDir.isEmpty()) {
        targetDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/games";
    }

    QDir dir(targetDir);
    if (!dir.exists()) {
        dir.mkpath(targetDir); // Автоматическое создание всей цепочки каталогов
    }

    return targetDir;
}

QString GameManager::getDatabasePath() const
{
    return getEffectiveGamesDir() + "/games.json";
}

QVariantMap GameManager::parseJarMetadata(const QString &jarPath)
{
    QVariantMap meta;
    QFileInfo fi(jarPath);

    meta["gameName"] = fi.completeBaseName();
    meta["vendorName"] = "Unknown Vendor";
    meta["logo"] = "ZyabaUI/Icons/note.svg";
    meta["filePath"] = jarPath;

    if (!fi.exists()) return meta;

    QZipReader zip(jarPath);
    if (zip.status() != QZipReader::NoError) return meta;

    QByteArray manifestData = zip.fileData("META-INF/MANIFEST.MF");
    if (manifestData.isEmpty()) {
        zip.close();
        return meta;
    }

    QString iconPathInZip;
    QTextStream stream(manifestData);

    while (!stream.atEnd()) {
        QString line = stream.readLine().trimmed();

        if (line.startsWith("MIDlet-Name:", Qt::CaseInsensitive)) {
	   meta["gameName"] = line.section(':', 1).trimmed();
        }
        else if (line.startsWith("MIDlet-Vendor:", Qt::CaseInsensitive)) {
	   meta["vendorName"] = line.section(':', 1).trimmed();
        }
        else if (line.startsWith("MIDlet-1:", Qt::CaseInsensitive)) {
	   QStringList parts = line.section(':', 1).split(',');
	   if (parts.size() >= 2) {
	       iconPathInZip = parts.at(1).trimmed();
	       if (iconPathInZip.startsWith('/')) iconPathInZip.remove(0, 1);
	   }
        }
    }

    if (!iconPathInZip.isEmpty()) {
        QByteArray iconData = zip.fileData(iconPathInZip);
        if (!iconData.isEmpty()) {
	   QString cachedIconUri = saveIconToCache(meta["gameName"].toString(), iconData);
	   if (!cachedIconUri.isEmpty()) {
	       meta["logo"] = cachedIconUri;
	   }
        }
    }

    zip.close();
    return meta;
}

QString GameManager::saveIconToCache(const QString &appName, const QByteArray &iconData)
{
    QImage img;
    if (!img.loadFromData(iconData)) return QString();

    QString cacheDir = QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + "/icons";
    QDir().mkpath(cacheDir);

    QString safeName = appName;
    safeName.remove(QRegExp("[^a-zA-Z0-9_]"));

    QString iconFilePath = QString("%1/%2.png").arg(cacheDir, safeName);
    if (img.save(iconFilePath, "PNG")) {
        return QUrl::fromLocalFile(iconFilePath).toString();
    }

    return QString();
}

QVariantList GameManager::loadInstalledGames(const QString &customPath)
{
    Q_UNUSED(customPath);
    QVariantList gamesList;

    QFile file(getDatabasePath());
    if (!file.open(QIODevice::ReadOnly)) {
        return gamesList;
    }

    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    file.close();

    if (doc.isArray()) {
        QJsonArray arr = doc.array();
        for (const QJsonValue &val : arr) {
	   gamesList.append(val.toObject().toVariantMap());
        }
    }

    return gamesList;
}

bool GameManager::installGame(const QString &filePath)
{
    QString cleanPath = QDir::cleanPath(filePath);

    if (cleanPath.startsWith("file://")) {
        cleanPath = QUrl(cleanPath).toLocalFile();
    }

    QFileInfo srcInfo(cleanPath);
    qDebug() << "[GameManager] Attempting to install from path:" << cleanPath;

    if (!srcInfo.exists()) {
        qDebug() << "[GameManager ERROR] File does NOT exist at path:" << cleanPath;
        return false;
    }

    QString gamesDirPath = getEffectiveGamesDir();
    QDir().mkpath(gamesDirPath);

    QString destPath = gamesDirPath + "/" + srcInfo.fileName();

    if (QDir::cleanPath(cleanPath) != QDir::cleanPath(destPath)) {
        if (QFile::exists(destPath)) {
	   QFile::remove(destPath); // QFile::copy НЕ умеет перезаписывать
        }
        if (!QFile::copy(cleanPath, destPath)) {
	   qDebug() << "[GameManager ERROR] Failed to copy file from" << cleanPath << "to" << destPath;
	   return false;
        }
    }

    QVariantMap meta = parseJarMetadata(destPath);
    QVariantList currentGames = loadInstalledGames();

    for (const QVariant &item : currentGames) {
        if (item.toMap()["filePath"].toString() == destPath) {
	   qDebug() << "[GameManager] Game already registered in DB:" << destPath;
	   return true;
        }
    }

    currentGames.append(meta);

    QJsonArray arr;
    for (const QVariant &var : currentGames) {
        arr.append(QJsonObject::fromVariantMap(var.toMap()));
    }

    QFile file(getDatabasePath());
    if (file.open(QIODevice::WriteOnly)) {
        file.write(QJsonDocument(arr).toJson());
        file.close();
        qDebug() << "[GameManager SUCCESS] Game installed successfully!";
        return true;
    }

    return false;
}

bool GameManager::removeGame(const QString &filePath)
{
    QString cleanPath = QDir::cleanPath(filePath);
    if (cleanPath.startsWith("file://")) {
        cleanPath = QUrl(cleanPath).toLocalFile();
    }

    QVariantList currentGames = loadInstalledGames();
    QVariantList updatedGames;
    bool found = false;

    for (const QVariant &item : currentGames) {
        QVariantMap map = item.toMap();
        if (map["filePath"].toString() == cleanPath) {
	   found = true;
	   QFile::remove(cleanPath);

	   QString iconUri = map["logo"].toString();
	   if (iconUri.startsWith("file://")) {
	       QString iconPath = QUrl(iconUri).toLocalFile();
	       QFile::remove(iconPath);
	   }
        } else {
	   updatedGames.append(map);
        }
    }

    if (!found) {
        qDebug() << "[GameManager] Game not found for removal:" << cleanPath;
        return false;
    }

    QJsonArray arr;
    for (const QVariant &var : updatedGames) {
        arr.append(QJsonObject::fromVariantMap(var.toMap()));
    }

    QFile file(getDatabasePath());
    if (file.open(QIODevice::WriteOnly)) {
        file.write(QJsonDocument(arr).toJson());
        file.close();
        qDebug() << "[GameManager SUCCESS] Game removed successfully:" << cleanPath;
        return true;
    }

    return false;
}
