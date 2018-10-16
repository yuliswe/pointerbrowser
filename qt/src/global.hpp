#ifndef Global_H
#define Global_H

#include <QtCore/QtCore>
#include "filemanager.hpp"
#include "tabsmodel.hpp"
#include "searchdb.hpp"
#include "keymaps.hpp"
#include "controller.hpp"
#include "crawler.hpp"

extern QLoggingCategory GlobalLogging;

class Global : public QObject
{
    Q_OBJECT

    static QCoreApplication* qCoreApplication;
    static void moveDataToQCoreApplicationThread();

public:
    explicit Global(QObject *parent = nullptr);
//    static FileManager* fileManager;
//    static SettingsModel* settingsModel;
//    static KeyMaps* keyMaps;
//    static TabsModel* tabsModel;
//    static TabsModel* previewTabsModel;
//    static EventFilter* eventFilter;
    static SearchDB* searchDB;
    static Crawler* crawler;
    static Controller* controller;
    static QThread* const qCoreApplicationThread;

//#ifdef Q_OS_MACOS
//#endif
public slots:
    static void startQCoreApplicationThread(int argc, char** argv);
    static void startQCoreApplicationThread(int argc, const QStringList& argv);
    static void stopQCoreApplicationThread();
//    static void registerQMetaTypes();

};

Q_DECLARE_METATYPE(void const*)

#endif // Global_H

