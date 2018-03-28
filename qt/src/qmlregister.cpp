#include <QQmlEngine>
#include <QString>
#include "qmlregister.h"
#include "filemanager.h"
#include "tabsmodel.h"
#include "webpage.h"
#include "eventfilter.h"
#include "searchdb.h"

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
//    qmlRegisterType<Webpage>("Backend", 1, 0, "Webpage");
}


FileManager* QMLRegister::fileManager = new FileManager();
TabsModel* QMLRegister::tabsModel = new TabsModel();
EventFilter* QMLRegister::eventFilter = new EventFilter();
SearchDB* QMLRegister::searchDB = new SearchDB();
