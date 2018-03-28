#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QtWebView>
#include <QPalette>
#include <QDebug>
#include "qmlregister.h"
#include "palette.h"
#include "eventfilter.h"

int main(int argc, char *argv[])
{
    // init ui
    //    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    // set properties
    QMLRegister::tabsModel->loadTabs();
    QMLRegister::fileManager->setupDirectories();

    QPalette pal = QGuiApplication::palette();
    //            pal.setColor(QPalette::Inactive, QPalette::Button, QColor("#000"));
    QMLRegister::registerToQML();
    QMLRegister::searchDB->connect();
    QtWebView::initialize();
    QQuickWindow::setSceneGraphBackend(QSGRendererInterface::Software);

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
