#ifndef GAMEMANAGER_H
#define GAMEMANAGER_H

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QDir>
#include <QFileInfo>
#include <QStandardPaths>
#include <QtGui/private/qzipreader_p.h>

class GameManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString customGamesPath READ customGamesPath WRITE setCustomGamesPath NOTIFY customGamesPathChanged)

public:
    explicit GameManager(QObject *parent = nullptr);

    QString customGamesPath() const;
    void setCustomGamesPath(const QString &path);

    Q_INVOKABLE QString getDatabasePath() const;
    Q_INVOKABLE QString getEffectiveGamesDir() const;
    Q_INVOKABLE QVariantMap parseJarMetadata(const QString &jarPath);
    Q_INVOKABLE QVariantList loadInstalledGames(const QString &customPath = QString());
    Q_INVOKABLE bool installGame(const QString &filePath);
    // Добавь Q_INVOKABLE для удаления, если ещё не добавлено:
    Q_INVOKABLE bool removeGame(const QString &filePath);

signals:
    void customGamesPathChanged();

private:
    QString m_customGamesPath;
    QString saveIconToCache(const QString &appName, const QByteArray &iconData);
};

#endif // GAMEMANAGER_H
