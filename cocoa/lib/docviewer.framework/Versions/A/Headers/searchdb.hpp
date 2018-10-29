#ifndef SEARCHDB_H
#define SEARCHDB_H

#include <QtSql/QtSql>
#include <QtCore/QtCore>
#include "webpage.hpp"
#include "tabsmodel.hpp"
#include "logging.hpp"
#include "macros.hpp"

typedef QSharedPointer<QSqlRelationalTableModel> QRelTable_;

class SearchDB;

class SearchWorker : public QObject
{
    friend class SearchDB;

    Q_OBJECT
    QSqlDatabase _db;
    QThread* _dataThread;

    PROP_DEF_BEGINS
    PROP_RN_D(QString, current_search_string, "")
    PROP_DEF_ENDS

public:
    explicit SearchWorker(const QSqlDatabase& db, QThread& workerThread, QThread& qmlThread);
    ~SearchWorker();

    METH_ASYNC_2(int, search, QString const&, int)

signals:
    void resultChanged(const Webpage_List& results, void const* sender);
    void searchStarted();
    void searchFinished();
};
typedef QSharedPointer<SearchWorker> SearchWorker_;

class UpdateWorker : public QObject
{
    Q_OBJECT
    QSqlDatabase _db;
    QThread* _qmlThread;

signals:
    void symbolsAdded(QString const& url, const QMap<QString,QString>& symbols);

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
    PROP_RN_D(QSharedPointer<QSet<Url>>, current_url_set, QSharedPointer<QSet<Url>>::create())
    PROP_RN_D(bool, is_searching, false)
    PROP_RN_D(QString, search_string, "")
    PROP_RN_D(int, search_limit, 200)
    PROP_DEF_ENDS

public:
    explicit SearchDB();
    bool connect();
    void disconnect();
    void searchAsync(QString const& words);

signals:
    void addSymbolsAsync(QString const& url, const QMap<QString,QString>& symbols);
    void addSymbolAsync(QString const& url, QString const& hash, QString const& text);
    bool addWebpageAsync(QString const& url);
    bool updateWebpageAsync(QString const& url, QString const& property, const QVariant& value);
    bool updateSymbolAsync(QString const& hash, QString const& property, const QVariant& value);
    void execScriptAsync(QString const& filename);

protected slots:
    bool hasWebpage(QString const& url) const;
    bool removeWebpage(QString const& url);
};


#endif // SEARCHDB_H
