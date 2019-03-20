#ifndef FILEMANAGER_H
#define FILEMANAGER_H

#include <QtCore/QtCore>
#include "logging.hpp"

typedef QSharedPointer<QFile> QFile_;

class FileManager : public QObject
{
        Q_OBJECT
public:
    enum WhenExists {
        WhenExistsSkip,
        WhenExistsOverwrite
    };
    Q_ENUM(WhenExists)

    public:
        explicit FileManager(QObject *parent = nullptr);
        void static mkRootDataDir();
        void static rmRootDataDir();

    public slots:
        static QString dataPath();
        static QString dataPath(QString const& file);
        static QString qrcPath(QString const& file);
        static QFile_ dataFile(QString const& file);
        static QFile_ qrcFile(QString const& file);
        static QString readQrcFileS(QString const& file);
        static QByteArray readQrcFileB(QString const& file);
        static QVariantMap readQrcJsonFileM(QString const& file);
        static void writeDataFileB(QString const& file, const QByteArray& contents);
        static void writeDataFileS(QString const& file, QString const& contents);
        static void writeDataJsonFileM(QString const& file, const QVariantMap& contents);
        static void writeDataJsonFileA(QString const& file, const QVariantList& contents);
        static void appendDataFileB(QString const& file, const QByteArray& contents);
        static void appendDataFileS(QString const& file, QString const& contents);
        static QString readDataFileS(QString const& file);
        static QVariantMap readDataJsonFileM(QString const& file);
        static QVariantList readDataJsonFileA(QString const& file);
        static QByteArray readDataFileB(QString const& file);
        static void defaultOpenUrl(QString const& file);
        static QList<QFileInfo> readDirContents(QString const& dir);
        static bool copyDirContents(QString const& from, QString const& to, WhenExists);
        static int moveFileToDir(QString const& filepath, QString const& dirpath, QString const& newfilename = "");
        static QString makeFilename(QString filename);

        static void removeDataDir(QString const&);
        static void makeDataDir(QString const&);
        static void renameDataDir(QString const& oldname, QString const& newname);

        static void removeDataFile(QString const&);
        static void renameDataFile(QString const& oldname, QString const& newname);

        static QString bookmarksPath();
        static QString crawlerRulesPath();
        static QString searchDBPath();
};

#endif // FILEMANAGER_H
