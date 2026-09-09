#ifndef RETROHOST_H
#define RETROHOST_H

#include <QObject>
#include <QProcess>
#include <QImage>
#include <QMap>
#include <QVariant>

class RetroHost : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool running READ isRunning NOTIFY runningChanged)
    Q_PROPERTY(QString suitName READ suitName NOTIFY suitNameChanged)

public:
    explicit RetroHost(QObject *parent = nullptr);
    ~RetroHost();

    Q_INVOKABLE void start(const QString &jarPath, const QString &gamePath);
    Q_INVOKABLE void stop();
    //Q_INVOKABLE void closeRunningJar();

    bool isRunning() const;

    QString suitName() const { return m_suitName; }

    // Ввод
    Q_INVOKABLE void sendKeyPress(int keyCode);
    Q_INVOKABLE void sendKeyRelease(int keyCode);
    Q_INVOKABLE void sendPointerPressed(int x, int y);
    Q_INVOKABLE void sendPointerReleased(int x, int y);

    // Настройки
    Q_INVOKABLE void setFpsLimit(int fps);
    Q_INVOKABLE void setFpsHack(int hack);
    Q_INVOKABLE void setBacklightColor(int index);
    Q_INVOKABLE void setResolution(int width, int height);
    Q_INVOKABLE void setRotation(int degrees);

    // Чтение конфигов
    Q_INVOKABLE QVariantMap loadGameConfig(const QString &appName);
    Q_INVOKABLE QVariantMap loadConfigForGamePath(const QString &gamePath);

signals:
    void configLoaded(QVariantMap config);
    void frameReady(const QImage &frame);
    void logMessage(const QString &message);
    void runningChanged();
    void suitNameChanged();

private slots:
    void onReadyReadStandardOutput();
    void onReadyReadStandardError();
    void onProcessError(QProcess::ProcessError error);
    void onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);

private:
    void parseBuffer();

    QProcess m_process;
    QByteArray m_buffer;
    QString m_suitName;
};

#endif // RETROHOST_H
