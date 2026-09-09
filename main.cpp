#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

// 1. Обязательно подключаем заголовки!
#include "j2meview.h"
#include "retrohost.h"
#include "gamemanager.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    // 2. РЕГИСТРИРУЕМ J2MEView В QML
    // Параметры: (URI модуля, Мажорная версия, Минорная версия, Название типа в QML)
    qmlRegisterType<J2MEView>("Retro", 1, 0, "J2MEView");

    QQmlApplicationEngine engine;

    // 3. Создаем RetroHost как контекстное свойство (чтобы не дох Process)
    RetroHost retroHost;
    engine.rootContext()->setContextProperty("retroHost", &retroHost);
    GameManager gameManager;
    engine.rootContext()->setContextProperty("gameManager", &gameManager);

    QCoreApplication::setApplicationName("zyaba-focus.jwb-bravada-n-jwb-tutantxamon");

    const QUrl url(QStringLiteral("qrc:/MainView.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
		   &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
	   QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
