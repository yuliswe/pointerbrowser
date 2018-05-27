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

    signals:

    public slots:
        static QString dataPath();
        static QFile_ dataFile(QString file);
        static QFile_ qrcFile(QString file);
        static QString readQrcFileS(QString file);
        static QByteArray readQrcFileB(QString file);
        static void writeDataFileB(QString file, QByteArray contents);
        static void writeDataFileS(QString file, QString contents);
        static void appendDataFileB(QString file, QByteArray contents);
        static void appendDataFileS(QString file, QString contents);
        static QString readDataFileS(QString file);
        static QByteArray readDataFileB(QString file);
        static void defaultOpenUrl(QString file);
};

#endif // FILEMANAGER_H
