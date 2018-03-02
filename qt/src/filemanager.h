#ifndef FILEMANAGER_H
#define FILEMANAGER_H

#include <QObject>
#include <QString>
#include <QJsonDocument>
#include <QFile>
#include <QSharedPointer>
typedef QSharedPointer<QFile> QFile_;

class FileManager : public QObject
{
        Q_OBJECT

    public:
        explicit FileManager(QObject *parent = nullptr);
        void static mkDataDir();
        void static rmDataDir();
        void static rmDataFile(const QString&);

    signals:

    public slots:
        static QString dataPath();
        static QFile_ dataFile(const QString& file);
        static QFile_ qrcFile(const QString& file);
        static QString readQrcFileS(const QString& file);
        static QByteArray readQrcFileB(const QString& file);
        static void writeDataFileB(const QString& file, const QByteArray& contents);
        static void writeDataFileS(const QString& file, const QString& contents);
        static void appendDataFileB(const QString& file, const QByteArray& contents);
        static void appendDataFileS(const QString& file, const QString& contents);
        static QString readDataFileS(const QString& file);
        static QByteArray readDataFileB(const QString& file);
        static void defaultOpenUrl(const QString& file);
};

#endif // FILEMANAGER_H
