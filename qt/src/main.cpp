#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QDebug>
#include "qmlregister.h"
#include "palette.h"
#include "eventfilter.h"
#ifdef Q_OS_MACX
#include <QtWebEngine>
#endif
#ifdef Q_OS_WIN
#include <QtWebEngine>
#endif

int main(int argc, char *argv[])
{
    // init ui
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);
    // set properties
    QMLRegister::fileManager->setupDirectories();
    QMLRegister::searchDB->connect();
    QMLRegister::palette->setup();
    QMLRegister::registerToQML();
#ifdef Q_OS_MACX
    QtWebEngine::initialize();
#endif
#ifdef Q_OS_WIN
    QCoreApplication::setAttribute(Qt::AA_UseSoftwareOpenGL);
    QtWebEngine::initialize();
#endif

    app.installEventFilter(QMLRegister::eventFilter);

    // load qmls
    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    //    QMLRegister::tabsModel->loadTabs();

    QObject::connect(&app, &QCoreApplication::aboutToQuit, [=]() {
        QMLRegister::tabsModel->saveTabs();
        QMLRegister::searchDB->disconnect();
    });

    return app.exec();
}
