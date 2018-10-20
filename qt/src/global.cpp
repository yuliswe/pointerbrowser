#include <QtCore/QtCore>
#include "global.hpp"
#include "filemanager.hpp"
#include "tabsmodel.hpp"
#include "webpage.hpp"
#include "searchdb.hpp"
#include "webpage.hpp"
#include "keymaps.hpp"
#include "url.hpp"
#include "crawler.hpp"

#ifdef Q_OS_MACOS
#include "mac_crawler.hpp"
#endif


void myMessageHandler(QtMsgType type, const QMessageLogContext &, const QString & msg)
{
#ifdef QT_NO_DEBUG_OUTPUT
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
    qCInfo(GlobalLogging) << "QLibraryInfo::PrefixPath" << QLibraryInfo::location(QLibraryInfo::PrefixPath);
    qCInfo(GlobalLogging) << "QLibraryInfo::LibrariesPath" << QLibraryInfo::location(QLibraryInfo::LibrariesPath);
    qCInfo(GlobalLogging) << "QLibraryInfo::ImportsPath" << QLibraryInfo::location(QLibraryInfo::ImportsPath);
    qCInfo(GlobalLogging) << "QLibraryInfo::DataPath" << QLibraryInfo::location(QLibraryInfo::DataPath);
}

Global::Global(QObject *parent) : QObject(parent)
{
}

void Global::startQCoreApplicationThread(int argc, const QStringList& argv) {
    qRegisterMetaType<void const*>();
    qRegisterMetaType<CrawlerRule>();
    qRegisterMetaType<CrawlerRuleTable>();
    static std::vector<char*> vec(argc);
    static QList<QByteArray> bytes;
    bytes.reserve(argc);
    for (int i = 0; i < argc; i++) {
        bytes << argv[i].toLatin1();
        vec[i] = bytes[i].data();
    }

//    qRegisterMetaType<Controller::TabState>("TabState");
    Global::startQCoreApplicationThread(argc, vec.data());
}

void Global::startQCoreApplicationThread(int argc, char** argv) {
    if (qCoreApplication) { return; } // already running

    //    QCoreApplication::setLibraryPaths(QStringList("@executable_path"));

    qCoreApplication = new QCoreApplication(argc, argv);
    qCoreApplication->moveToThread(qCoreApplicationThread);

    QObject::connect(qCoreApplicationThread, &QThread::started, [=]() {
        initGlobalObjects();
        dumpLibraryInfo();
        QLoggingCategory::setFilterRules(QStringLiteral("*=false"));
        QString currV = FileManager::readQrcFileS("defaults/version");
        QString dataV = FileManager::readDataFileS("version");
        qCInfo(GlobalLogging) << "running version" << currV
                << "data version" << dataV;
        if (currV != dataV) {
            FileManager::rmDataDir();
        }
        FileManager::mkDataDir();
        searchDB->connect();
        controller->loadLastOpen();
    });

    QObject::connect(qCoreApplicationThread, &QThread::finished, [=]() {
        searchDB->disconnect();
    });

    qCoreApplicationThread->start();
}

void Global::stopQCoreApplicationThread()
{
    qCoreApplicationThread->quit();
    qCoreApplicationThread->wait();
}

QCoreApplication* Global::qCoreApplication = nullptr;
QThread* const Global::qCoreApplicationThread = new QThread();

//FileManager* Global::fileManager = new FileManager();
SearchDB* Global::searchDB = nullptr;
Controller* Global::controller = nullptr;
Crawler* Global::crawler = nullptr;
//KeyMaps* Global::keyMaps = new KeyMaps();
//SettingsModel* Global::settingsModel = new SettingsModel();

void Global::initGlobalObjects()
{
    Q_ASSERT(QThread::currentThread() == qCoreApplicationThread);
    searchDB = new SearchDB();
    controller = new Controller();

#ifdef Q_OS_MACOS
    crawler = new Crawler(MacCrawlerDelegateFactory_::create(), 100, 1);
#endif

}

