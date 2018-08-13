#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QDebug>
#include "qmlregister.h"
#include "palette.h"
#include "eventfilter.h"
#include <QLibraryInfo>

#ifdef Q_OS_MACOS
#include <QtWebEngine>
#include "os-specific/mac/macwindow.h"
#endif
#ifdef Q_OS_WIN
#include <QtWebEngine>
#endif

void myMessageHandler(QtMsgType type, const QMessageLogContext &, const QString & msg)
{
#if QT_NO_DEBUG_OUTPUT
    return;
#endif
    QString txt;
    switch (type) {
    case QtFatalMsg: txt = QString("Fatal: %1\n").arg(msg); break;
    case QtCriticalMsg: txt = QString("Critical: %1\n").arg(msg); break;
    case QtWarningMsg: txt = QString("Warning: %1\n").arg(msg); break;
    case QtInfoMsg: txt = QString("Info: %1\n").arg(msg); break;
    case QtDebugMsg: txt = QString("Debug: %1\n").arg(msg); break;
    }
    switch (type) {
    case QtFatalMsg:
        FileManager::appendDataFileS("fatal.log", txt);
    case QtCriticalMsg:
        FileManager::appendDataFileS("critical.log", txt);
    case QtWarningMsg:
        FileManager::appendDataFileS("warning.log", txt);
    case QtInfoMsg:
        FileManager::appendDataFileS("info.log", txt);
    case QtDebugMsg:
        FileManager::appendDataFileS("debug.log", txt);
    }
}

void dumpLibraryInfo()
{
    qInfo() << "QLibraryInfo::PrefixPath" << QLibraryInfo::location(QLibraryInfo::PrefixPath);
    qInfo() << "QLibraryInfo::LibrariesPath" << QLibraryInfo::location(QLibraryInfo::LibrariesPath);
    qInfo() << "QLibraryInfo::PluginsPath" << QLibraryInfo::location(QLibraryInfo::PluginsPath);
    qInfo() << "QLibraryInfo::ImportsPath" << QLibraryInfo::location(QLibraryInfo::ImportsPath);
    qInfo() << "QLibraryInfo::Qml2ImportsPath" << QLibraryInfo::location(QLibraryInfo::Qml2ImportsPath);
}

int main(int argc, char *argv[])
{

#ifdef Q_OS_MACOS
    qputenv("QTWEBENGINE_CHROMIUM_FLAGS", "--disable-logging --log-level=4 -c * -o /Users/ylilarry/lab/trace.log");

    // init ui
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QQuickWindow::setTextRenderType(QQuickWindow::NativeTextRendering);
    QQuickWindow::setSceneGraphBackend(QSGRendererInterface::OpenGL);
    QGuiApplication::setFont(QFont("SF Pro Text", 12));
#endif

#ifdef Q_OS_WIN
    qputenv("QTWEBENGINE_CHROMIUM_FLAGS", "--disable-logging --log-level=4");
    // init ui
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QQuickWindow::setTextRenderType(QQuickWindow::NativeTextRendering);
    QQuickWindow::setSceneGraphBackend(QSGRendererInterface::OpenGL);
    QGuiApplication::setAttribute(Qt::AA_UseSoftwareOpenGL);
    QGuiApplication::setFont(QFont("Tahoma",15));
#endif

    qInstallMessageHandler(myMessageHandler);

    QGuiApplication app(argc, argv);

    dumpLibraryInfo();
    qInfo() << "Using font" << QGuiApplication::font();

    // set properties
    qInfo() << "FileManager::dataPath()" << FileManager::dataPath();
    QString currV = FileManager::readQrcFileS("defaults/version");
    QString dataV = FileManager::readDataFileS("version");
    qInfo() << "running version" << currV
             << "data version" << dataV;
    if (currV != dataV) {
        FileManager::rmDataDir();
    }
    FileManager::mkDataDir();
    QMLRegister::searchDB->connect();
    QMLRegister::keyMaps->sync();
    QMLRegister::palette->setup();
    QMLRegister::registerToQML();
#ifdef Q_OS_MACOS
    QtWebEngine::initialize();
#endif
#ifdef Q_OS_WIN
    QtWebEngine::initialize();
#endif

//    app.installEventFilter(QMLRegister::eventFilter);

    // load qmls
    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

#ifdef Q_OS_MACOS
    MacWindow::initMacWindows();
#endif

    QObject::connect(&app, &QCoreApplication::aboutToQuit, [=]() {
        QMLRegister::browserController->saveLastOpen();
        QMLRegister::searchDB->disconnect();
#ifndef QT_DEBUG
        FileManager::rmDataFile("debug.log");
        FileManager::rmDataFile("info.log");
        FileManager::rmDataFile("warning.log");
        FileManager::rmDataFile("critical.log");
#endif
    });

    QMLRegister::browserController->loadLastOpen();

    return app.exec();
}
