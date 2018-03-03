#include <QQmlEngine>
#include <QUrl>
#include "qmlregister.h"
#include "filemanager.h"

QMLRegister::QMLRegister(QObject *parent) : QObject(parent)
{

}


void QMLRegister::registerToQML() {
    qmlRegisterSingletonType<FileManager>("Backend", 1, 0, "FileManager", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        return QMLRegister::fileManager;
    });
}


FileManager* QMLRegister::fileManager = new FileManager();
