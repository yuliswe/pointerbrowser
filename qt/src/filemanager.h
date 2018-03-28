#ifndef FILEMANAGER_H
#define FILEMANAGER_H

#include <QObject>
#include <QString>

class FileManager : public QObject
{
        Q_OBJECT

    public:
        explicit FileManager(QObject *parent = nullptr);
        void static setupDirectories();
        static QString dataPath();

    signals:

    public slots:
        static QString readQrcFileS(QString file);
        static QByteArray readQrcFileB(QString file);
        static void saveFile(QString file, QByteArray contents);
        static QString readFileS(QString file);
        static QByteArray readFileB(QString file);
};

#endif // FILEMANAGER_H
