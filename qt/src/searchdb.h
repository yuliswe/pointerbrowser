#ifndef SEARCHDB_H
#define SEARCHDB_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlDriver>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlRelationalTableModel>
#include "webpage.h"

class SearchDB : public QObject
{
        Q_OBJECT
    public:
        explicit SearchDB();
    signals:

    public slots:
        bool connect();
        void disconnect();
        bool execMany(const QStringList& lines);
        bool addWebpage(const Webpage_& webpage);
        Webpage_ findWebpage(const QString& url);
        void removeWebpage(const QString& url);
        QList<Webpage_> search(const QString& word) const;

    protected:
        QString _dbPath;
        QSqlDatabase _db;
        QSqlRelationalTableModel _indexTable;
        QSqlRelationalTableModel _webpageTable;

};

#endif // SEARCHDB_H
