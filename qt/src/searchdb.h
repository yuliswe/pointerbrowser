#ifndef SEARCHDB_H
#define SEARCHDB_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlDriver>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlRelationalTableModel>
#include <QSharedPointer>
#include <QSemaphore>
#include <QThread>
#include "webpage.h"
#include "tabsmodel.h"

typedef QSharedPointer<QSqlRelationalTableModel> QRelTable_;

class SearchWorker : public QObject
{
    Q_OBJECT
    QSqlDatabase _db;
    QThread* _qmlThread;
public:
    explicit SearchWorker(const QSqlDatabase& db, QThread& workerThread, QThread& qmlThread);
public slots:
    void search(const QString& words);
signals:
    void resultChanged(const Webpage_List& results);
};

typedef QSharedPointer<SearchWorker> SearchWorker_;

class SearchDB : public QObject
{
    Q_OBJECT
    Q_PROPERTY(TabsModel* searchResult READ searchResult NOTIFY searchResultChanged)

public:
    explicit SearchDB();
    QSemaphore semaphore{1};
    QSemaphore searchSemaphore{1};

signals:
    void searchResultChanged();
    void searchAsyncCalled(const QString& words);

public slots:
    bool connect();
    void disconnect();
    bool execMany(const QStringList& lines);
    void searchAsync(const QString& words);
    bool addWebpage(const QString& url);
    bool addSymbols(const QString& url, const QVariantMap& symbols);
    bool addSymbols(const QSqlDatabase& db, const QString& url, const QVariantMap& symbols);
    void addSymbolsAsync(const QString url, const QVariantMap symbols);
    bool updateWebpage(const QString& url, const QString& property, const QVariant& value);
    bool updateSymbol(const QString& hash, const QString& property, const QVariant& value);
    Webpage_ findWebpage_(const QString& url) const;
    QVariantMap findWebpage(const QString& url) const;
    bool hasWebpage(const QString& url) const;
    bool removeWebpage(const QString& url);
    QSqlRelationalTableModel* webpageTable() const;
    TabsModel* searchResult();
    void setSearchResult(const Webpage_List& results);
    bool execScript(QString filename);

protected:
    QString _dbPath;
    QSqlDatabase _db;
    QRelTable_ _symbol;
    QRelTable_ _webpage;
    QRelTable_ _webpage_symbol;
    TabsModel _searchResult; // cache search function

    QThread _searchWorkerThread;
    SearchWorker_ _searchWorker;
};


#endif // SEARCHDB_H
