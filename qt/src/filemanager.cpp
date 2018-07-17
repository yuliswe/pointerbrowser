#include <QStandardPaths>
#include <QTextStream>
#include <QFile>
#include <QUrl>
#include <QDebug>
#include <QDir>
#include "filemanager.h"
#include <QDesktopServices>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>

FileManager::FileManager(QObject *parent) : QObject(parent)
{
}

void FileManager::mkDataDir()
{
    QDir dir;
    qInfo() << "FileManager::mkDataDir"<< FileManager::dataPath();
    dir.mkpath(FileManager::dataPath());
    QStringList defaults;
    defaults << "search.db"
             << "auto-bookmark.txt"
             << "version";
    for (QString file : defaults) {
        QFile_ src = FileManager::qrcFile("defaults/"+file);
        QFile_ dest = FileManager::dataFile(file);
        if (! dest->exists()) {
            qInfo() << "copying" << src->fileName() << "to" << dest->fileName();
            src->copy(dest->fileName());
            QFile::setPermissions(dest->fileName(),
                                  QFileDevice::ReadOwner|
                                  QFileDevice::WriteOwner);
        }
    }
}

void FileManager::rmDataDir()
{
    qInfo() << "FileManager::rmDataDir"<< FileManager::dataPath();
    QDir dir(FileManager::dataPath());
    dir.removeRecursively();
}

void FileManager::rmDataFile(const QString& filename)
{
    qInfo() << "FileManager::rmDataFile"<< filename;
    QDir dir(FileManager::dataPath());
    dir.remove(filename);
}

QFile_ FileManager::dataFile(const QString& filename)
{
    QString path = FileManager::dataPath() + filename;
    return QFile_::create(path);
}


QFile_ FileManager::qrcFile(const QString& filename)
{
    return QFile_::create(":/" + filename);
}


QString FileManager::dataPath()
{
    return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/";
}

QString FileManager::readQrcFileS(const QString& file)
{
    QFile input(":/" + file);
    input.open(QIODevice::ReadOnly | QIODevice::Text);
    QTextStream ts(&input);
    return ts.readAll();
}

QByteArray FileManager::readQrcFileB(const QString& file)
{
    QFile input(":/" + file);
    input.open(QIODevice::ReadOnly);
    return input.readAll();
}

QVariantMap FileManager::readQrcJsonFileM(const QString &file)
{
    QByteArray contents = FileManager::readQrcFileB(file);
    QJsonDocument doc = QJsonDocument::fromJson(contents);
    QJsonObject jobj = doc.object();
    return jobj.toVariantMap();
}

void FileManager::writeDataFileB(const QString& filename, const QByteArray& contents)
{
//    QString path = FileManager::dataPath() + filename;
    QFile_ file = FileManager::dataFile(filename);
    file->open(QIODevice::WriteOnly | QIODevice::Text);
    file->write(contents);
    file->close();
//    qInfo() << "writeDataFileB: writing file " << filename << endl
//             << contents << endl;
}

void FileManager::appendDataFileB(const QString& filename, const QByteArray& contents)
{
//    QString path = FileManager::dataPath() + filename;
    QFile_ file = FileManager::dataFile(filename);
    file->open(QIODevice::ReadWrite | QIODevice::Append | QIODevice::Text);
    file->write(contents);
    file->close();
//    qInfo() << "appendDataFileB: writing file " << filename << endl
//             << contents << endl;
}


void FileManager::writeDataFileS(const QString& filename, const QString& contents)
{
    FileManager::writeDataFileB(filename, contents.toUtf8());
}

void FileManager::appendDataFileS(const QString& filename, const QString& contents)
{
    FileManager::appendDataFileB(filename, contents.toUtf8());
}


void FileManager::writeDataJsonFileM(const QString& file, const QVariantMap& map)
{
    QJsonObject jobj = QJsonObject::fromVariantMap(map);
    QJsonDocument doc{jobj};
    FileManager::writeDataFileB(file, doc.toJson());
}

void FileManager::writeDataJsonFileA(const QString& file, const QVariantList& ls)
{
    QJsonArray jarr = QJsonArray::fromVariantList(ls);
    QJsonDocument doc{jarr};
    FileManager::writeDataFileB(file, doc.toJson());
}

QString FileManager::readDataFileS(const QString& filename)
{
    QString path = FileManager::dataPath() + filename;
    QFile file(path);
    file.open(QIODevice::ReadOnly | QIODevice::Text);
    qInfo() << "readDataFileS: reading file " << path;
    return file.readAll();
}

QByteArray FileManager::readDataFileB(const QString& filename)
{
    QString path = FileManager::dataPath() + filename;
    QFile file(path);
    file.open(QIODevice::ReadOnly);
    qInfo() << "readDataFileB: reading file " << path;
    return file.readAll();
}

QVariantMap FileManager::readDataJsonFileM(const QString &file)
{
    QByteArray contents = FileManager::readDataFileB(file);
    QJsonDocument doc = QJsonDocument::fromJson(contents);
    QJsonObject jobj = doc.object();
    return jobj.toVariantMap();
}

QVariantList FileManager::readDataJsonFileA(const QString &file)
{
    QByteArray contents = FileManager::readDataFileB(file);
    QJsonDocument doc = QJsonDocument::fromJson(contents);
    QJsonArray jarr = doc.array();
    return jarr.toVariantList();
}

void FileManager::defaultOpenUrl(const QString& filename)
{
    QUrl url(filename);
    url.setScheme("file");
    qInfo() << "FileManager::defaultOpenUrl" << url;
    QDesktopServices::openUrl(url);
}
