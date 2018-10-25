#ifndef SEARCHDB_H
#define SEARCHDB_H

#include <QtSql/QtSql>
#include <QtCore/QtCore>
#include "webpage.hpp"
#include "tabsmodel.hpp"
#include "logging.hpp"

typedef QSharedPointer<QSqlRelationalTableModel> QRelTable_;

class SearchWorker : public QObject
{
    Q_OBJECT
    QSqlDatabase _db;
    QThread* _dataThread;
public:
    explicit SearchWorker(const QSqlDatabase& db, QThread& workerThread, QThread& qmlThread);
    ~SearchWorker();
public slots:
    void search(QString const& words);
signals:
    void resultChanged(const Webpage_List& results);
    void searchStarted();
    void searchFinished();
};
typedef QSharedPointer<SearchWorker> SearchWorker_;

class UpdateWorker : public QObject
{
    Q_OBJECT
    QSqlDatabase _db;
    QThread* _qmlThread;
public:
    explicit UpdateWorker(const QSqlDatabase& db, QThread& workerThread, QThread& qmlThread);
    ~UpdateWorker();
public slots:
    bool addSymbols(QString const& url, const QMap<QString,QString>& symbols);
    bool addSymbol(QString const& url, QString const& hash, QString const& text);
    bool addWebpage(QString const& url);
    bool updateWebpage(QString const& url, QString const& property, const QVariant& value);
    bool updateSymbol(QString const& hash, QString const& property, const QVariant& value);
    bool execScript(QString const& filename);
    bool execMany(const QStringList& lines);
};

typedef QSharedPointer<UpdateWorker> UpdateWorker_;

class SearchDB : public QObject
{
    Q_OBJECT

protected:
    QString _dbPath;
    QSqlDatabase _db;

    QThread _searchWorkerThread;
    SearchWorker_ _searchWorker;

    QThread _updateWorkerThread;
    UpdateWorker_ _updateWorker;

    PROP_DEF_BEGINS
    PROP_RN_D(TabsModel_, search_result, shared<TabsModel>())
    PROP_RN_D(bool, is_searching, false)
    PROP_DEF_ENDS

public:
    explicit SearchDB();
    bool connect();
    void disconnect();

signals:
    void searchAsync(QString const& words);
    void addSymbolsAsync(QString const& url, const QMap<QString,QString>& symbols);
    void addSymbolAsync(QString const& url, QString const& hash, QString const& text);
    bool addWebpageAsync(QString const& url);
    bool updateWebpageAsync(QString const& url, QString const& property, const QVariant& value);
    bool updateSymbolAsync(QString const& hash, QString const& property, const QVariant& value);
    void execScriptAsync(QString const& filename);

protected slots:
//    Webpage_ findWebpage_(QString const& url) const;
//    QVariantMap findWebpage(QString const& url) const;
    bool hasWebpage(QString const& url) const;
    bool removeWebpage(QString const& url);
};


#endif // SEARCHDB_H
