#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QtWebView>
#include <QDebug>
#include "qmlregister.h"
#include "palette.h"
#include "eventfilter.h"

int main(int argc, char *argv[])
{
    // init ui
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);
    // set properties
    QMLRegister::fileManager->setupDirectories();
    QMLRegister::registerToQML();
    QMLRegister::searchDB->connect();
    QMLRegister::palette->setup();
    QtWebView::initialize();

#ifdef Q_OS_WIN
    QQuickWindow::setSceneGraphBackend(QSGRendererInterface::Software);
#endif

    QCoreApplication::instance()->installEventFilter(QMLRegister::eventFilter);

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
