#ifndef FILEMANAGER_H
#define FILEMANAGER_H

#include <QtCore/QtCore>
#include "logging.hpp"

typedef QSharedPointer<QFile> QFile_;

class FileManager : public QObject
{
        Q_OBJECT

    public:
        explicit FileManager(QObject *parent = nullptr);
        void static mkDataDir();
        void static rmDataDir();
        void static rmDataFile(QString const&);

    signals:

    public slots:
        static QString dataPath();
        static QString dataPath(QString const& file);
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
//        static void moveDirContents(QString const& from, QString const& to);
        static int moveFileToDir(QString const& filepath, QString const& dirpath, QString const& newfilename = "");

        static QString bookmarksPath();
        static QString crawlerRulesPath();
};

#endif // FILEMANAGER_H
