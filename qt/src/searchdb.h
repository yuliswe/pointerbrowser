#ifndef SEARCHDB_H
#define SEARCHDB_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlDriver>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlRelationalTableModel>
#include <QSharedPointer>
#include "webpage.h"
#include "tabsmodel.h"

typedef QSharedPointer<QSqlRelationalTableModel> QRelTable_;

class SearchDB : public QObject
{
        Q_OBJECT
        Q_PROPERTY(QSqlRelationalTableModel* webpageTable READ webpageTable NOTIFY webpageTableChanged)
        Q_PROPERTY(TabsModel* searchResult READ searchResult NOTIFY searchResultChanged)


    public:
        explicit SearchDB();

    signals:
        void webpageTableChanged();
        void searchResultChanged();

    public slots:
        bool connect();
        void disconnect();
        bool execMany(const QStringList& lines);
        bool addWebpage(const QString& url);
        Webpage_ findWebpage(const QString& url);
        void removeWebpage(const QString& url);
        void search(const QString& word);
        QSqlRelationalTableModel* webpageTable() const;
        TabsModel* searchResult();

    protected:
        QString _dbPath;
        QSqlDatabase _db;
        QRelTable_ _indexTable;
        QRelTable_ _webpageTable;
        TabsModel _searchResult; // cache search function
};

#endif // SEARCHDB_H
