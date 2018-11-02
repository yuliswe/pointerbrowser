#ifndef Global_H
#define Global_H

#include <QtCore/QtCore>
#include "filemanager.hpp"
#include "tabsmodel.hpp"
#include "searchdb.hpp"
#include "keymaps.hpp"
#include "controller.hpp"
#include "crawler.hpp"
#include "logging.hpp"

class GlobalSignals : public QObject
{
    Q_OBJECT
    SIG_TF_0(global_objects_initialized)
    SIG_TF_0(everything_loaded)
};

class Global : public QObject
{
    Q_OBJECT

    static QCoreApplication* qCoreApplication;
    static void initGlobalObjects();

public:
    static GlobalSignals sig;
    explicit Global(QObject *parent = nullptr);
    static SearchDB* searchDB;
    static Crawler* crawler;
    static Controller* controller;
    static QThread* const qCoreApplicationThread;
    static bool isNewInstall;

//#ifdef Q_OS_MACOS
//#endif
public slots:
    static void startQCoreApplicationThread(int argc, char** argv);
    static void startQCoreApplicationThread(int argc, const QStringList& argv);
    static void stopQCoreApplicationThread();
//    static void registerQMetaTypes();

};

Q_DECLARE_METATYPE(void const*)
Q_DECLARE_METATYPE(uint_least64_t)
#endif // Global_H

