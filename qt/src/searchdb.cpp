#include <QSqlDatabase>
#include <QSqlDriver>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QSqlField>
#include <QDebug>
#include <QCoreApplication>
#include <QSqlRelationalTableModel>
#include <QSharedPointer>
#include <QRegularExpression>
#include <QString>
#include <QMap>
#include <QtConcurrent>
#include <algorithm>
#include "searchdb.h"
#include "filemanager.h"
#include "webpage.h"
#include "qmlregister.h"
#include "tabsmodel.h"


SearchDB::SearchDB()
{
}

bool SearchDB::connect() {
    _db = QSqlDatabase::addDatabase("QSQLITE");
    _dbPath = FileManager::dataPath() + "search.db";
    qInfo() << "SearchDB: connecting" << _dbPath;
    _db.setDatabaseName(_dbPath);
    _db.setConnectOptions("QSQLITE_OPEN_READONLY");
    if (! _db.open()) {
        qFatal("SearchDB Error: connection with database failed");
    }
    qInfo() << "SearchDB: connection ok";
    _db.exec("PRAGMA journal_mode=WAL");
    /* SearchWorker setup */
    _searchWorker = SearchWorker_::create(_db, _searchWorkerThread, *QThread::currentThread());
    _searchWorkerThread.start();
    qRegisterMetaType<Webpage_List>();
    QObject::connect(this, &SearchDB::searchAsync, _searchWorker.data(), &SearchWorker::search);
    QObject::connect(this, &SearchDB::searchAsync, this, [=]() { this->set_searchInProgress(true); });
    QObject::connect(_searchWorker.data(), &SearchWorker::resultChanged, this, &SearchDB::setSearchResult);
    QObject::connect(_searchWorker.data(), &SearchWorker::searchStarted, this, [=]() {
        this->set_searchInProgress(true);
    });
    QObject::connect(_searchWorker.data(), &SearchWorker::searchFinished, this, [=]() {
        this->set_searchInProgress(false);
    });
    searchAsync("");
    /* UpdateWorker setup */
    _updateWorker = UpdateWorker_::create(_db, _updateWorkerThread, *QThread::currentThread());
    _updateWorkerThread.start();
    QObject::connect(this, &SearchDB::addSymbolsAsync, _updateWorker.data(), &UpdateWorker::addSymbols);
    QObject::connect(this, &SearchDB::addWebpageAsync, _updateWorker.data(), &UpdateWorker::addWebpage);
    QObject::connect(this, &SearchDB::updateSymbolAsync, _updateWorker.data(), &UpdateWorker::updateSymbol);
    QObject::connect(this, &SearchDB::updateWebpageAsync, _updateWorker.data(), &UpdateWorker::updateWebpage);
    QObject::connect(this, &SearchDB::execScriptAsync, _updateWorker.data(), &UpdateWorker::execScript);
    return true;
}

void SearchDB::disconnect() {
    _db.close();
    _searchWorkerThread.quit();
    _searchWorkerThread.wait();
    _updateWorkerThread.quit();
    _updateWorkerThread.wait();
    qInfo() << "SearchDB: disconnected";
}

bool UpdateWorker::execScript(const QString& filename)
{
    QString s = FileManager::readQrcFileS(filename);
    return execMany(s.replace("\n","").split(";", QString::SkipEmptyParts));
}

bool UpdateWorker::execMany(const QStringList& lines)
{
    for (const QString l : lines) {
        qInfo() << "UpdateWorker::execMany" << l;
        QSqlQuery query = _db.exec(l);
        if (query.lastError().isValid()) {
            qCritical() << "UpdateWorker::execMany error when executing"
                        << query.executedQuery()
                        << query.lastError();
            return false;
        }
    }
    return true;
}

bool UpdateWorker::updateWebpage(const QString& url, const QString& property, const QVariant& value)
{
    qInfo() << "UpdateWorker::updateWebpage" << property << value << url;
    QSqlQuery query(_db);
    query.prepare("UPDATE webpage SET " + property + " = ? WHERE url = '" + url + "'");
    query.addBindValue(value);
    if (! query.exec() || query.numRowsAffected() < 1) {
        qCritical() << "UpdateWorker::updateWebpage failed" << url << property << value
                    << query.numRowsAffected()
                    << query.executedQuery()
                    << query.lastError();
        return false;
    } else {
        qInfo() << "UpdateWorker::updateWebpage" << query.executedQuery();
    }
    return true;
}


bool UpdateWorker::updateSymbol(const QString &hash, const QString &property, const QVariant &value)
{
    qInfo() << "SearchDB::updateSymbol" << property << value << hash;
    QSqlQuery query(_db);
    query.prepare("UPDATE symbol SET " + property + " = :value WHERE hash = '" + hash +"'");
    query.bindValue(":value", value);
    if (! query.exec() || query.numRowsAffected() < 1) {
        qCritical() << "UpdateWorker::updateSymbol failed" << hash << property << value
                    << query.numRowsAffected()
                    << query.executedQuery()
                    << query.lastError();
        return false;
    } else {
        qInfo() << "UpdateWorker::updateSymbol" << query.executedQuery();
    }
    return true;
}


bool UpdateWorker::addSymbols(const QString& url, const QVariantMap& symbols)
{
    qInfo() << "UpdateWorker::addSymbols" << url << symbols;
    QSqlQuery query(_db);
    query.prepare("SELECT id FROM webpage WHERE url = :url");
    query.bindValue(":url", url);
    if (! query.exec() || ! query.first() || !query.isValid()) {
        qCritical() << "UpdateWorker::addSymbols didn't find the webpage" << url
                    << query.executedQuery()
                    << query.lastError();
        return false;
    }
    const QVariant wid = query.record().value("id");
    for (auto i = symbols.keyBegin();
         i != symbols.keyEnd();
         i++) {
        QString hash = (*i);
        QString text = symbols[hash].value<QString>();
        query.clear();
        query.prepare("INSERT INTO symbol (hash,text,visited) VALUES (:hash,:text,:visited)");
        query.bindValue(":hash", hash);
        query.bindValue(":text", text);
        query.bindValue(":visited", 0);
        if (query.exec() && query.numRowsAffected() > 0) {
            QVariant sid = query.lastInsertId();
            if (sid.isValid()) {
                query.clear();
                query.prepare("INSERT INTO webpage_symbol (webpage,symbol) VALUES (:webpage,:symbol)");
                query.bindValue(":symbol", sid);
                query.bindValue(":webpage", wid);
                if (query.exec() && query.numRowsAffected() > 0) {
                    qInfo() << "UpdateWorker::addSymbols inserted" << hash << text;
                } else {
                    qInfo() << "UpdateWorker::addSymbols failed to insert into webpage_symbol" << hash << text
                             << query.lastError();
                }
            } else {
                qCritical() << "UpdateWorker::addSymbols datatbase does not support QSqlQuery::lastInsertId()";
                return false;
            }
        } else {
            qCritical() << "UpdateWorker::addSymbols failed to insert to symbol" << hash << text
                        << query.lastError();
        }
    }
    query.clear();
    return true;
}

bool UpdateWorker::addWebpage(const QString& url)
{
    qInfo() << "UpdateWorker::addWebpage" << url;
    QSqlQuery query(_db);
    query.prepare("REPLACE INTO webpage (url, title, visited, html) VALUES (:url,'','',0)");
    query.bindValue(":url", url);
    if (! query.exec()) {
        qCritical() << "ERROR: UpdateWorker::addWebpage failed!" << query.lastError();
        return false;
    };
    return true;
}

bool SearchDB::removeWebpage(const QString& url)
{
    qInfo() << "SearchDB::removeWebpage" << url;
    return false;
}

Webpage_ SearchDB::findWebpage_(const QString& url) const
{
    qInfo() << "SearchDB::findWebpage_" << url;
    QSqlQuery query(_db);
    query.prepare("SELECT * FROM webpage WHERE url = ? LIMIT 1");
    query.addBindValue(url);
    if (! query.first()) {
        qCritical() << "SearchDB::findWebpage_ not found!" << url;
        return QSharedPointer<Webpage>(nullptr);
    }
    QSqlRecord r = query.record();
    qInfo() << "SearchDB::findWebpage_ found " << r;
    Webpage_ wp = Webpage_::create(url);
    wp->set_title(r.value("title").value<QString>());
    wp->set_visited(r.value("visited").value<int>());
    return wp;
}

QVariantMap SearchDB::findWebpage(const QString& url) const
{
    qInfo() << "SearchDB::findWebpage" << url;
    Webpage_ p = SearchDB::findWebpage_(url);
    if (p.isNull()) {
        qCritical() << "SearchDB::findWebpage not found!" << url;
        return QVariantMap();
    }
    return p->toQVariantMap();
}

bool SearchDB::hasWebpage(const QString& url) const
{
    QSqlQuery query(_db);
    query.prepare("SELECT url FROM webpage WHERE url = ? LIMIT 1");
    query.addBindValue(url);
    bool b = query.first();
    qInfo() << "SearchDB::hasWebpage" << url << b;
    return b;
}

SearchWorker::SearchWorker(const QSqlDatabase& db, QThread& _thread, QThread& _qmlThread)
    : _db(QSqlDatabase::cloneDatabase(db, "SearchWorker")), _qmlThread(&_qmlThread)
{
    this->moveToThread(&_thread);
    _db.setConnectOptions("QSQLITE_OPEN_READONLY");
    _db.open();
    _db.exec("PRAGMA journal_mode=WAL");
    qInfo() << "SearchWorker::SearchWorker initialized and moved to thread" << &_thread;
}
SearchWorker::~SearchWorker()
{
    _db.close();
}

UpdateWorker::UpdateWorker(const QSqlDatabase& db, QThread& _thread, QThread& _qmlThread)
    : _db(QSqlDatabase::cloneDatabase(db, "UpdateWorker")), _qmlThread(&_qmlThread)
{
    this->moveToThread(&_thread);
    _db.setConnectOptions();
    _db.open();
    _db.exec("PRAGMA journal_mode=WAL");
    qInfo() << "UpdateWorker::UpdateWorker initialized and moved to thread" << &_thread;
}

UpdateWorker::~UpdateWorker()
{
    if (! execScript("db/exit.sqlite3")) {
        qInfo() << "UpdateWorker::disconnect failed";
    }
    _db.close();
}

void SearchWorker::search(const QString& word)
{
    qInfo() << "SearchWorker::search" << word;
    Webpage_List pages;
    emit searchStarted();
    emit resultChanged(pages);
    QStringList ws = word.split(QRegularExpression(" "), QString::SkipEmptyParts);
    QString q;
    if (word == "") {
        q = QStringLiteral("SELECT DISTINCT webpage.id, url, COALESCE(title, '') as title, visited FROM webpage ORDER BY visited DESC LIMIT 50");
    } else {
        if (ws.length() == 0) { return; }
        /* WITH LEFT JOIN */
        q = QStringLiteral("SELECT DISTINCT * FROM (");
        q += QStringLiteral() +
            "SELECT " +
            "   url, title, symbol.visited AS visited, hash, symbol.text AS symbol " +
            " FROM webpage" +
            " INNER JOIN webpage_symbol ON webpage.id = webpage_symbol.webpage" +
            " INNER JOIN symbol ON symbol.id = webpage_symbol.symbol" +
            " WHERE ";
        for (auto w = ws.begin(); w != ws.end(); w++) {
            q += QStringLiteral() +
                 " (" +
                 "    INSTR(LOWER(text),LOWER('" + (*w) + "'))" +
                 "    OR INSTR(LOWER(hash),LOWER('" + (*w) + "'))" +
                 "    OR INSTR(LOWER(title),LOWER('" + (*w) + "'))" +
                 "    OR INSTR(LOWER(url),LOWER('" + (*w) + "'))" +
                 " )";
            if (w != ws.end() - 1) {
                q += " AND ";
            }
        }
        q += " UNION ";
        /* WITHOUT LEFT JOIN */
        q += QStringLiteral() +
            "SELECT " +
            "  url, title, visited, '' AS hash, '' AS symbol" +
            " FROM webpage WHERE ";
        for (auto w = ws.begin(); w != ws.end(); w++) {
            q += QStringLiteral() +
                 " (" +
                 "    INSTR(LOWER(title),LOWER('" + (*w) + "'))" +
                 "    OR INSTR(LOWER(url),LOWER('" + (*w) + "'))" +
                 " )";
            if (w != ws.end() - 1) {
                q += " AND ";
            }
        }
        q += ") ";
        q += " ORDER BY visited DESC";
        q += ", CASE WHEN LENGTH(symbol) = 0 THEN 99999 ELSE LENGTH(symbol) END ASC";
        q += ", CASE WHEN LENGTH(hash) = 0 THEN 99999 ELSE LENGTH(hash) END ASC";
        q += ", CASE WHEN LENGTH(title) = 0 THEN 99999 ELSE LENGTH(title) END ASC";
        q += ", LENGTH(url) ASC";
        q += " LIMIT 200";
    }
    qInfo() << "SearchWorker::search" << q;
    QSqlQuery r = _db.exec(q);
    if (r.lastError().isValid()) {
        qCritical() << "SearchWorker::search failed"
                    << q
                    << r.lastError();
        return;
    }
    r.first();
    QRegularExpression searchRegex(ws.join("|"), QRegularExpression::CaseInsensitiveOption);
    QRegularExpression slash("/");
    QRegularExpression protocal("^(.+://)");
    while (r.isValid()) {
        QSqlRecord record = r.record();
        QString url = record.value("url").value<QString>();
        QRegularExpressionMatch protocal_match = protocal.match(url);
        int url_domain_start = protocal_match.capturedLength();
        QStringList path = url.split(slash, QString::SkipEmptyParts);
        QString last = path.length() > 0 ? path[path.length() - 1] : "";
        int last_index = url.lastIndexOf(last);
        QString display_last = "./" + last + "  ";
        QString display_head = "";
        display_head += url.leftRef(last_index);
        // special case when at root domain
        if (last_index == url_domain_start) {
            display_head = url;
            if (path.length() >= 2) {
                display_last = path[1];
            } else {
                display_last = "./index";
            }
        }

        QString title = record.value("title").value<QString>();
        QString symbol = record.value("symbol").value<QString>();
        QString hash = record.value("hash").value<QString>();
        QString display_symbol = (0 < symbol.length()  && hash.length() < 32 ? "@"+symbol+"  " : "");
        QString display_hash = (0 < hash.length() && hash.length() < 32 ? "#"+hash+"  " : "");
        QString display_title = (title.length() > 0 ? title + "  " : "");
        QString display = display_symbol + display_hash + display_last + display_title + display_head;
        QStringList expanded_display;
        expanded_display << display_title
                         << display_symbol + display_hash + display_last
                         << display_head;
        Webpage_ wp = Webpage_::create(url);
        wp->set_title(title);
        wp->set_symbol(symbol);
        wp->set_hash(hash);
        wp->set_display(display);
        wp->set_expanded_display(expanded_display);
        pages << wp;
        wp->moveToThread(_qmlThread);
        r.next();
    }
    emit resultChanged(pages);
    emit searchFinished();
    qInfo() << "SearchWorker::search found" << pages.count();
}


TabsModel* SearchDB::searchResult()
{
    return &_searchResult;
}

void SearchDB::setSearchResult(const Webpage_List& results)
{
    _searchResult.replaceModel(results);
}


#define QPROP_FUNC(TYPE, PROP) \
    TYPE SearchDB::PROP() const { return _##PROP; } \
    void SearchDB::set_##PROP(TYPE x) { _##PROP = x; emit PROP##_changed(x); }

QPROP_FUNC(bool, searchInProgress)




