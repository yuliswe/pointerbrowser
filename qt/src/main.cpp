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

void myMessageHandler(QtMsgType type, const QMessageLogContext &, const QString & msg)
{
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

int main(int argc, char *argv[])
{
    qputenv("QT_QUICK_CONTROLS_1_STYLE", "Flat");
    qputenv("QTWEBENGINE_CHROMIUM_FLAGS", "--disable-logging --log-level=4");

    qInstallMessageHandler(myMessageHandler);

    // init ui
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#ifdef Q_OS_WIN
    QFont font("Tahoma");
    QGuiApplication::setFont(font);
#endif
    QGuiApplication app(argc, argv);
    // set properties
    qDebug() << "FileManager::dataPath()" << FileManager::dataPath();
    QString currV = FileManager::readQrcFileS("defaults/version");
    QString dataV = FileManager::readDataFileS("version");
    qDebug() << "running version" << currV
             << "data version" << dataV;
    if (currV != dataV) {
        FileManager::rmDataDir();
    }
    FileManager::mkDataDir();
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

//    app.installEventFilter(QMLRegister::eventFilter);

    // load qmls
    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    QObject::connect(&app, &QCoreApplication::aboutToQuit, [=]() {
        QMLRegister::tabsModel->saveTabs();
        QMLRegister::tabsModel->clear();
        QMLRegister::searchDB->disconnect();
#ifndef QT_DEBUG
        FileManager::rmDataFile("debug.log");
        FileManager::rmDataFile("info.log");
        FileManager::rmDataFile("warning.log");
        FileManager::rmDataFile("critical.log");
#endif
    });
    return app.exec();
}
