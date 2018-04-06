#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QtWebView>
#include <QPalette>
#include <QDebug>
#include <QCursor>
#include "qmlregister.h"
#include "palette.h"
#include "eventfilter.h"

int main(int argc, char *argv[])
{
    // init ui
        QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);
    // set properties
    QMLRegister::tabsModel->loadTabs();
    QMLRegister::fileManager->setupDirectories();

    Palette customPal;
    app.setPalette(customPal);

    QMLRegister::registerToQML();
    QMLRegister::searchDB->connect();
    QtWebView::initialize();

#ifdef Q_OS_WIN
    QQuickWindow::setSceneGraphBackend(QSGRendererInterface::Software);
#endif

    app.installEventFilter(QMLRegister::eventFilter);

    // set window transparent
    //    QSurfaceFormat surfaceFormat;
    //    surfaceFormat.setAlphaBufferSize(8);
    //    QSurfaceFormat::setDefaultFormat(surfaceFormat);
    //    viewer.setClearBeforeRendering(true);
    //    viewer.setColor(QColor(Qt::transparent));

    // load qmls
    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }


    return app.exec();
}
