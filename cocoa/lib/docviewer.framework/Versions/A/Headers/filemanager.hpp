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

        Q_DECL_DEPRECATED static QString bookmarksFileName;
        Q_DECL_DEPRECATED static QString userSettingsFileName;
        Q_DECL_DEPRECATED static QString crawlerRulesFileName;
        Q_DECL_DEPRECATED static QString searchDBFileName;

    public slots:
        static QString dataPath();
        static QString dataPath(QString const& file);
        static QString qrcPath(QString const& file);
        static QFileInfo dataFile(QString const& file);
        static QFile_ qrcFile(QString const& file);
        static QString readQrcFileS(QString const& file);
        static QByteArray readQrcFileB(QString const& file);
        static QVariantMap readQrcJsonFileM(QString const& file);

        static void writeFileB(QFileInfo const& file, const QByteArray& contents);
        static QByteArray readFileB(QFileInfo const& file);
        static void writeJsonFileM(QFileInfo const& file, const QVariantMap& contents);
        static QVariantMap readJsonFileM(QFileInfo const& file);

        Q_DECL_DEPRECATED static void writeDataFileB(QString const& file, const QByteArray& contents);
        Q_DECL_DEPRECATED static void writeDataFileS(QString const& file, QString const& contents);
        Q_DECL_DEPRECATED static void writeDataJsonFileM(QString const& file, const QVariantMap& contents);
        Q_DECL_DEPRECATED static void writeDataJsonFileA(QString const& file, const QVariantList& contents);
        Q_DECL_DEPRECATED static QString readDataFileS(QString const& file);
        Q_DECL_DEPRECATED static QVariantMap readDataJsonFileM(QString const& file);
        Q_DECL_DEPRECATED static QVariantList readDataJsonFileA(QString const& file);
        Q_DECL_DEPRECATED static QByteArray readDataFileB(QString const& file);

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

        Q_DECL_DEPRECATED static QString bookmarksPath();
        static QFileInfo userSettingsFile();
        Q_DECL_DEPRECATED static QString crawlerRulesPath();
        Q_DECL_DEPRECATED static QString searchDBPath();
};

#endif // FILEMANAGER_H
