#include <QtCore/QtCore>
#include "filemanager.hpp"

FileManager::FileManager(QObject *parent) : QObject(parent)
{
}

void FileManager::mkDataDir()
{
    QDir dir;
    qCInfo(FileLogging) << "FileManager::mkDataDir"<< FileManager::dataPath();
    dir.mkpath(FileManager::dataPath());
    QStringList defaults;
    defaults << "search.db"
             << "bookmarks.json"
             << "version";
    for (QString file : defaults) {
        QFile_ src = FileManager::qrcFile("defaults/"+file);
        QFile_ dest = FileManager::dataFile(file);
        if (! dest->exists()) {
            qCInfo(FileLogging) << "copying" << src->fileName() << "to" << dest->fileName();
            src->copy(dest->fileName());
            QFile::setPermissions(dest->fileName(),
                                  QFileDevice::ReadOwner|
                                  QFileDevice::WriteOwner);
        }
    }
}

void FileManager::rmDataDir()
{
    qCInfo(FileLogging) << "FileManager::rmDataDir"<< FileManager::dataPath();
    QDir dir(FileManager::dataPath());
    dir.removeRecursively();
}

void FileManager::rmDataFile(QString const& filename)
{
    qCInfo(FileLogging) << "FileManager::rmDataFile"<< filename;
    QDir dir(FileManager::dataPath());
    dir.remove(filename);
}

QFile_ FileManager::dataFile(QString const& filename)
{
    QString path = FileManager::dataPath() + filename;
    return QFile_::create(path);
}


QFile_ FileManager::qrcFile(QString const& filename)
{
    return QFile_::create(":/" + filename);
}


QString FileManager::bookmarksPath()
{
    return FileManager::dataPath("bookmarks.json");
}

QString FileManager::crawlerRulesPath()
{
    return FileManager::dataPath("discovery-rules.json");
}


QString FileManager::dataPath()
{
    return FileManager::dataPath("");
}


QString FileManager::dataPath(QString const& file)
{
    return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/" + file;
}

QString FileManager::readQrcFileS(QString const& file)
{
    QFile input(":/" + file);
    input.open(QIODevice::ReadOnly | QIODevice::Text);
    QTextStream ts(&input);
    return ts.readAll();
}

QByteArray FileManager::readQrcFileB(QString const& file)
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

void FileManager::writeDataFileB(QString const& filename, const QByteArray& contents)
{
//    QString path = FileManager::dataPath() + filename;
    QFile_ file = FileManager::dataFile(filename);
    file->open(QIODevice::WriteOnly | QIODevice::Text);
    file->write(contents);
    file->close();
//    qCInfo(FileLogging) << "writeDataFileB: writing file " << filename << endl
//             << contents << endl;
}

void FileManager::appendDataFileB(QString const& filename, const QByteArray& contents)
{
//    QString path = FileManager::dataPath() + filename;
    QFile_ file = FileManager::dataFile(filename);
    file->open(QIODevice::ReadWrite | QIODevice::Append | QIODevice::Text);
    file->write(contents);
    file->close();
//    qCInfo(FileLogging) << "appendDataFileB: writing file " << filename << endl
//             << contents << endl;
}


void FileManager::writeDataFileS(QString const& filename, QString const& contents)
{
    FileManager::writeDataFileB(filename, contents.toUtf8());
}

void FileManager::appendDataFileS(QString const& filename, QString const& contents)
{
    FileManager::appendDataFileB(filename, contents.toUtf8());
}


void FileManager::writeDataJsonFileM(QString const& file, const QVariantMap& map)
{
    QJsonObject jobj = QJsonObject::fromVariantMap(map);
    QJsonDocument doc{jobj};
    FileManager::writeDataFileB(file, doc.toJson());
}

void FileManager::writeDataJsonFileA(QString const& file, const QVariantList& ls)
{
    QJsonArray jarr = QJsonArray::fromVariantList(ls);
    QJsonDocument doc{jarr};
    FileManager::writeDataFileB(file, doc.toJson());
}

QString FileManager::readDataFileS(QString const& filename)
{
    QString path = FileManager::dataPath() + filename;
    QFile file(path);
    if (! file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        file.open(QIODevice::ReadWrite | QIODevice::Text);
    }
    qCInfo(FileLogging) << "readDataFileS: reading file " << path;
    return file.readAll();
}

QByteArray FileManager::readDataFileB(QString const& filename)
{
    QString path = FileManager::dataPath() + filename;
    QFile file(path);
    if (! file.open(QIODevice::ReadOnly)) {
        file.open(QIODevice::ReadWrite);
    }
    qCInfo(FileLogging) << "readDataFileB: reading file " << path;
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

void FileManager::defaultOpenUrl(QString const& filename)
{
    QUrl url(filename);
    url.setScheme("file");
    qCInfo(FileLogging) << "FileManager::defaultOpenUrl" << url;
//    QDesktopServices::openUrl(url);
}
