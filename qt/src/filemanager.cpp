#include <QStandardPaths>
#include <QTextStream>
#include <QFile>
#include <QUrl>
#include <QDebug>
#include <QDir>
#include "filemanager.h"

FileManager::FileManager(QObject *parent) : QObject(parent)
{
}

void FileManager::setupDirectories()
{
    QDir dir;
    qDebug() << "setupDirectories: "
             << FileManager::dataPath()
             << endl;
    dir.mkpath(FileManager::dataPath());
}


QString FileManager::dataPath()
{
    return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
}

QString FileManager::readFileQrc(QString file)
{
    QFile input(":/" + file);
    input.open(QIODevice::ReadOnly | QIODevice::Text);
    QTextStream ts(&input);
    return ts.readAll();
}

void FileManager::saveFile(QString filename, QByteArray contents)
{
    QString path = FileManager::dataPath() + "/" + filename;
    QFile file(path);
    file.open(QIODevice::WriteOnly | QIODevice::Text);
    file.write(contents);
    qDebug() << "saveFile: writing file " << path << endl
             << contents << endl;
}

QString FileManager::readFileS(QString filename)
{
    QString path = FileManager::dataPath() + "/" + filename;
    QFile file(path);
    file.open(QIODevice::ReadOnly | QIODevice::Text);
    qDebug() << "readFileS: reading file " << path;
    return file.readAll();
}

QByteArray FileManager::readFileB(QString filename)
{
    QString path = FileManager::dataPath() + "/" + filename;
    QFile file(path);
    file.open(QIODevice::ReadOnly);
    qDebug() << "readFileB: reading file " << path;
    return file.readAll();
}
