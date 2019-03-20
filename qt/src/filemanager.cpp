#include <QtCore/QtCore>
#include "filemanager.hpp"
#include "macros.hpp"

FileManager::FileManager(QObject *parent) : QObject(parent)
{
}

void FileManager::mkRootDataDir()
{
    QDir dir;
    qCInfo(FileLogging) << "FileManager::mkDataDir"<< FileManager::dataPath();
    FileManager::copyDirContents(qrcPath("defaults"), dataPath(), WhenExistsSkip);
}

void FileManager::rmRootDataDir()
{
    qCInfo(FileLogging) << "FileManager::rmDataDir"<< FileManager::dataPath();
    QDir dir(FileManager::dataPath());
    dir.removeRecursively();
}

QFile_ FileManager::dataFile(QString const& filename)
{
    QString path = FileManager::dataPath(filename);
    return QFile_::create(path);
}

QString FileManager::qrcPath(QString const& filename)
{
    return ":/" + filename;
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

QString FileManager::searchDBPath()
{
    return FileManager::dataPath("search.db");
//    return ":memory:";
}

QString FileManager::makeFilename(QString filename)
{
    return QUrl::toPercentEncoding(filename, " |_-()[]{}");
}

QString FileManager::dataPath()
{
    return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
}


QString FileManager::dataPath(QString const& file)
{
    QDir dir(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/" + file);
    QDir rootDataDir(dataPath());
    QString s1 = dir.absolutePath();
    QString s2 = rootDataDir.absolutePath();
    Q_ASSERT(s1.indexOf(s2) == 0 && s1.length() > s2.length());
    return s1;
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
    QFile_ file = FileManager::dataFile(filename);
    QFileInfo info(dataPath(filename));
    info.dir().mkpath(info.dir().absolutePath());
    file->open(QIODevice::WriteOnly | QIODevice::Text);
    file->write(contents);
    file->close();
}

void FileManager::appendDataFileB(QString const& filename, const QByteArray& contents)
{
    QFile_ file = FileManager::dataFile(filename);
    file->open(QIODevice::ReadWrite | QIODevice::Append | QIODevice::Text);
    file->write(contents);
    file->close();
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
    QString path = FileManager::dataPath(filename);
    QFile file(path);
    if (! file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        file.open(QIODevice::ReadWrite | QIODevice::Text);
    }
    qCInfo(FileLogging) << "readDataFileS: reading file " << path;
    return file.readAll();
}

QByteArray FileManager::readDataFileB(QString const& filename)
{
    QString path = FileManager::dataPath(filename);
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
    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(contents, &error);
    if (doc.isNull()) {
        CRIT(FileLogging) << error.errorString() << "at" << error.offset;
        return QVariantMap();
    }
    QJsonObject jobj = doc.object();
    return jobj.toVariantMap();
}

QVariantList FileManager::readDataJsonFileA(const QString &file)
{
    QByteArray contents = FileManager::readDataFileB(file);
    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(contents, &error);
    if (doc.isNull()) {
        CRIT(FileLogging) << error.errorString() << "at" << error.offset;
        return QVariantList();
    }
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

QList<QFileInfo> FileManager::readDirContents(QString const& dirpath)
{
    QDir dir(dirpath);
    QList<QFileInfo> infols = dir.entryInfoList(QDir::AllDirs|QDir::Files|QDir::NoDotAndDotDot|QDir::Readable|QDir::Writable,
                                                QDir::Time);
    return infols;
}

int FileManager::moveFileToDir(QString const& filepath,
                               QString const& dirpath,
                               QString const& newfilename)
{
    qCInfo(FileLogging) << "FileManager::moveFileToDir" << filepath << dirpath << newfilename;
    QFileInfo originalfile(filepath);
    QDir destdir(dirpath);
    QFileInfo destfile;
    if (newfilename.isEmpty()) {
        destfile = destdir.filePath(originalfile.fileName());
    } else {
        destfile = destdir.filePath(newfilename);
    }
    if (destfile == originalfile) {
        return true;
    }
    if (! originalfile.exists())
    {
        CRIT(FileLogging) << "original file" << originalfile.absoluteFilePath() << "does not exist";
        return 1;
    }
    if (destfile.exists()) {
        CRIT(FileLogging) << "destination file" << destfile.absoluteFilePath() << "already exists";
        return 2;
    }
    return QFile(originalfile.absoluteFilePath()).rename(destfile.absoluteFilePath());
}

bool FileManager::copyDirContents(QString const& sourceFolder, QString const& destFolder, WhenExists whenExists)
{
    INFO(FileLogging) << sourceFolder << destFolder;
    bool success = false;
    QDir sourceDir(sourceFolder);

    if(!sourceDir.exists())
        return false;

    QDir destDir(destFolder);
    if(!destDir.exists())
        destDir.mkpath(destFolder);

    QStringList files = sourceDir.entryList(QDir::Files);
    for(int i = 0; i< files.count(); i++) {
        QString srcName = sourceFolder + QDir::separator() + files[i];
        QString destName = destFolder + QDir::separator() + files[i];
        if (QFile::exists(destName)) {
            if (whenExists == WhenExistsOverwrite) {
                QFile::remove(destName);
            } else if (whenExists == WhenExistsSkip) {
                QFile::setPermissions(destName, QFileDevice::ReadOwner|QFileDevice::WriteOwner|QFileDevice::ReadUser|QFileDevice::WriteUser|QFileDevice::ReadGroup|QFileDevice::WriteGroup);
                continue;
            }
        }
        success = QFile::copy(srcName, destName);
        if(!success) {
            return false;
        }
        QFile::setPermissions(destName, QFileDevice::ReadOwner|QFileDevice::WriteOwner|QFileDevice::ReadUser|QFileDevice::WriteUser|QFileDevice::ReadGroup|QFileDevice::WriteGroup);
    }

    files.clear();
    files = sourceDir.entryList(QDir::AllDirs | QDir::NoDotAndDotDot);
    for(int i = 0; i< files.count(); i++)
    {
        QString srcName = sourceFolder + QDir::separator() + files[i];
        QString destName = destFolder + QDir::separator() + files[i];
        success = copyDirContents(srcName, destName, whenExists);
        if(!success)
            return false;
    }

    return true;
}

void FileManager::removeDataDir(QString const& dirname)
{
    INFO(FileLogging) << dirname;
    // alert! this check is fatal
    QDir dir(dataPath(dirname));
    QDir dataDir(dataPath());
    if (dir.absolutePath().indexOf(dataDir.absolutePath()) == 0
            && dir.absolutePath() != dataDir.absolutePath())
    {
        // safe to delete
        dir.removeRecursively();
    }
    CRIT(FileLogging) << "Fatal error! Did you just try to remove outside data path by mistake?";
}

void FileManager::makeDataDir(QString const& dirname)
{
    QDir dir;
    dir.mkdir(dataPath(dirname));
}

void FileManager::renameDataDir(QString const& dirname, QString const& newname)
{
    QDir dir;
    dir.rename(dataPath(dirname), dataPath(newname));
}

void FileManager::removeDataFile(QString const& filename)
{
    INFO(FileLogging) << filename;
    QFile::remove(dataPath(filename));
}

void FileManager::renameDataFile(QString const& oldname, QString const& newname)
{
    INFO(FileLogging) << oldname << newname;
    QFile::rename(dataPath(oldname), dataPath(newname));
}

