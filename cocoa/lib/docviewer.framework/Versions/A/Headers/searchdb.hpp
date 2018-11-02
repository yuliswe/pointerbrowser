#ifndef SEARCHDB_H
#define SEARCHDB_H

#include <QtSql/QtSql>
#include <QtCore/QtCore>
#include "webpage.hpp"
#include "tabsmodel.hpp"
#include "logging.hpp"
#include "macros.hpp"
#include "filemanager.hpp"

typedef QSharedPointer<QSqlRelationalTableModel> QRelTable_;

class SearchDB;

class SearchWorker : public QObject
{
    friend class SearchDB;

    Q_OBJECT

    PROP_DEF_BEGINS
    PROP_RN_D(QString, current_search_string, "")
    PROP_R_N_D(bool, is_reading, false)
    PROP_DEF_ENDS

    QList<Webpage_> webpagesFromQuery(QSqlQuery&);

    public:
    METH_ASYNC_0(int,connect)
    METH_ASYNC_0(int,disconnect)
    QSqlDatabase db();

    METH_ASYNC_2(int, search, QString const&, int)
    METH_ASYNC_2(int, searchForWebpage, Webpage_, int)
    Q_SIGNAL void resultChanged(const Webpage_List& results, void const* sender);

};
typedef QSharedPointer<SearchWorker> SearchWorker_;

typedef QMap<QString,QString> QStringStringMap;
Q_DECLARE_METATYPE(QStringStringMap)

class UpdateWorker : public QObject
{
    friend class SearchDB;

    Q_OBJECT
    PROP_DEF_BEGINS
    PROP_DEF_ENDS

signals:
    void newEntriesWritten();
protected:
    bool addSymbol(UrlNoHash const& url, QString const& hash, QString const& text);

public:
    METH_ASYNC_0(int,connect)
    METH_ASYNC_0(int,disconnect)
    QSqlDatabase db();


    METH_ASYNC_2(bool, addSymbols, UrlNoHash const&, QStringStringMap const&)
    METH_ASYNC_2(bool, addReferer, UrlNoHash const&, QStringStringMap const&)
    METH_ASYNC_1(bool, addWebpages, QList<Webpage_> const&)
    METH_ASYNC_1(bool, addWebpages, QSet<UrlNoHash> const&)
    METH_ASYNC_1(bool, addWebpage, Webpage_)
    METH_ASYNC_1(bool, addWebpage, UrlNoHash const&)

    METH_ASYNC_3(bool, updateWebpage, UrlNoHash const&, QString const&, const QVariant&)
    METH_ASYNC_3(bool, updateSymbol, QString const&, QString const&, const QVariant&)
    METH_ASYNC_1(bool, execScript, QString const&)
    METH_ASYNC_1(bool, execMany, QStringList const&)
};

typedef QSharedPointer<UpdateWorker> UpdateWorker_;

class SearchDB : public QObject
{
    Q_OBJECT

protected:
    PROP_DEF_BEGINS
    PROP_RN_D(QSharedPointer<QThread>, search_worker_thread, QSharedPointer<QThread>::create())
    PROP_RN_D(QSharedPointer<QThread>, update_worker_thread, QSharedPointer<QThread>::create())
    PROP_RN_D(SearchWorker_, search_worker, SearchWorker_::create())
    PROP_RN_D(UpdateWorker_, update_worker, UpdateWorker_::create())

    PROP_RN_D(TabsModel_, search_result, shared<TabsModel>())
    PROP_RN_D(QSharedPointer<QSet<Url>>, current_url_set, QSharedPointer<QSet<Url>>::create())
    PROP_RN_D(bool, is_searching, false)
    PROP_RN_D(Webpage_, search_webpage, nullptr)
    PROP_RN_D(QString, search_string, "")
    PROP_RN_D(int, search_limit, 200)
    PROP_DEF_ENDS

    public:
    bool connect();
    void disconnect();
    METH_ASYNC_1(int, search, QString const&)
    METH_ASYNC_1(int, searchForWebpage, Webpage_)
};


#endif // SEARCHDB_H
