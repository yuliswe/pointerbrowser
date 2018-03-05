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
        static QString dataPath;

    signals:

    public slots:
        QString readFileQrc(QString file);
};

#endif // FILEMANAGER_H
