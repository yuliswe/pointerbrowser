#include <QStandardPaths>
#include <QTextStream>
#include <QFile>
#include "filemanager.h"

FileManager::FileManager(QObject *parent) : QObject(parent)
{

}

void FileManager::setupDirectories()
{
}


QString FileManager::dataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);

QString FileManager::readFileQrc(QString file) {
    QFile input(":/" + file);
    input.open(QIODevice::ReadOnly);
    QTextStream ts(&input);
    return ts.readAll();
}
