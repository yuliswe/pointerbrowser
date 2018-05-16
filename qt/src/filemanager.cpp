#include <QStandardPaths>
#include <QTextStream>
#include <QFile>
#include <QUrl>
#include <QDebug>
#include <QDir>
#include "filemanager.h"
#include <QDesktopServices>

FileManager::FileManager(QObject *parent) : QObject(parent)
{
}

void FileManager::setupDirectories()
{
    QDir dir;
    qDebug() << "setupDirectories"<< FileManager::dataPath();
    dir.mkpath(FileManager::dataPath());
    QStringList defaults;
    defaults << "search.db" << "auto-bookmark.txt";
    for (QString file : defaults) {
        QFile_ dest = FileManager::dataFile(file);
        QFile_ src = FileManager::qrcFile("defaults/"+file);
        if (! dest->exists()) {
            qDebug() << "copying" << src->fileName() << "to" << dest->fileName();
            src->copy(dest->fileName());
            QFile::setPermissions(dest->fileName(),
                                  QFileDevice::ReadOwner|
                                  QFileDevice::WriteOwner);
        }
    }
}

QFile_ FileManager::dataFile(QString filename)
{
    QString path = FileManager::dataPath() + filename;
    return QFile_::create(path);
}


QFile_ FileManager::qrcFile(QString filename)
{
    return QFile_::create(":/" + filename);
}


QString FileManager::dataPath()
{
    return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/";
}

QString FileManager::readQrcFileS(QString file)
{
    QFile input(":/" + file);
    input.open(QIODevice::ReadOnly | QIODevice::Text);
    QTextStream ts(&input);
    return ts.readAll();
}

QByteArray FileManager::readQrcFileB(QString file)
{
    QFile input(":/" + file);
    input.open(QIODevice::ReadOnly);
    return input.readAll();
}

void FileManager::saveFile(QString filename, QByteArray contents)
{
    QString path = FileManager::dataPath() + filename;
    QFile file(path);
    file.open(QIODevice::WriteOnly | QIODevice::Text);
    file.write(contents);
    qDebug() << "saveFile: writing file " << path << endl
             << contents << endl;
}

QString FileManager::readFileS(QString filename)
{
    QString path = FileManager::dataPath() + filename;
    QFile file(path);
    file.open(QIODevice::ReadOnly | QIODevice::Text);
    qDebug() << "readFileS: reading file " << path;
    return file.readAll();
}

QByteArray FileManager::readFileB(QString filename)
{
    QString path = FileManager::dataPath() + filename;
    QFile file(path);
    file.open(QIODevice::ReadOnly);
    qDebug() << "readFileB: reading file " << path;
    return file.readAll();
}

void FileManager::defaultOpenUrl(QString filename)
{
    QUrl url(filename);
    url.setScheme("file");
    qDebug() << "FileManager::defaultOpenUrl" << url;
    QDesktopServices::openUrl(url);
}
