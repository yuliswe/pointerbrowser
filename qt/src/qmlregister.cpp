#include <QQmlEngine>
#include <QString>
#include "qmlregister.h"
#include "filemanager.h"
#include "tabsmodel.h"
#include "webpage.h"
#include "eventfilter.h"
#include "searchdb.h"
#include "palette.h"
#include "webpage.h"
#include "keymaps.h"

#ifdef Q_OS_MACOS
#include "os-specific/mac/macwindow.h"
#endif

QMLRegister::QMLRegister(QObject *parent) : QObject(parent)
{
}


void QMLRegister::registerToQML() {
    qmlRegisterSingletonType<FileManager>("Backend", 1, 0, "FileManager", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        return QMLRegister::fileManager;
    });
    qmlRegisterSingletonType<TabsModel>("Backend", 1, 0, "TabsModel", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        return QMLRegister::tabsModel;
    });
    qmlRegisterSingletonType<TabsModel>("Backend", 1, 0, "PreviewTabsModel", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        return QMLRegister::previewTabsModel;
    });
    qmlRegisterSingletonType<TabsModel>("Backend", 1, 0, "EventFilter", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        return QMLRegister::eventFilter;
    });
    qmlRegisterSingletonType<SearchDB>("Backend", 1, 0, "SearchDB", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        return QMLRegister::searchDB;
    });
    qmlRegisterSingletonType<Palette>("Backend", 1, 0, "Palette", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        return QMLRegister::palette;
    });
    qmlRegisterSingletonType<Palette>("Backend", 1, 0, "SettingsModel", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        return QMLRegister::settingsModel;
    });
    qmlRegisterSingletonType<Palette>("Backend", 1, 0, "BrowserController", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        return QMLRegister::browserController;
    });
    qmlRegisterSingletonType<Palette>("Backend", 1, 0, "KeyMaps", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        return QMLRegister::keyMaps;
    });

#ifdef Q_OS_MACOS
    qmlRegisterSingletonType<MacWindow>("Backend", 1, 0, "MacWindow", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        return QMLRegister::macWindow;
    });
#endif
}


FileManager* QMLRegister::fileManager = new FileManager();
TabsModel* QMLRegister::tabsModel = new TabsModel();
TabsModel* QMLRegister::previewTabsModel = new TabsModel();
KeyMaps* QMLRegister::keyMaps = new KeyMaps();
SettingsModel* QMLRegister::settingsModel = new SettingsModel();
EventFilter* QMLRegister::eventFilter = new EventFilter();
SearchDB* QMLRegister::searchDB = new SearchDB();
Palette* QMLRegister::palette = new Palette();
BrowserController* QMLRegister::browserController = new BrowserController();
#ifdef Q_OS_MACOS
MacWindow* QMLRegister::macWindow = new MacWindow();
#endif
