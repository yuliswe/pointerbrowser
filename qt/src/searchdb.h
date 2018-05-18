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
        Q_PROPERTY(TabsModel* searchResult READ searchResult NOTIFY searchResultChanged)

    public:
        explicit SearchDB();

    signals:
        void searchResultChanged();

    public slots:
        bool connect();
        void disconnect();
        bool execMany(const QStringList& lines);
        bool addWebpage(const QString& url);
        bool updateWebpage(const QString& url, const QString& property, const QVariant& value);
        bool addSymbols(const QString& url, const QStringList& symbols);
        Webpage_ findWebpage_(const QString& url) const;
        bool setBookmarked(const QString& url, bool bk);
        bool bookmarked(const QString& url) const;
        bool hasWebpage(const QString& url) const;
        bool removeWebpage(const QString& url);
        void search(const QString& word);
        QSqlRelationalTableModel* webpageTable() const;
        TabsModel* searchResult();
        bool execScript(QString filename);

    protected:
        QString _dbPath;
        QSqlDatabase _db;
        QRelTable_ _symbol;
        QRelTable_ _webpage;
        QRelTable_ _webpage_symbol;
        QString _currentWord;
        TabsModel _searchResult; // cache search function
};

#endif // SEARCHDB_H
