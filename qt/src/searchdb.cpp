#include <QtCore/QtCore>
#include <algorithm>
#include "searchdb.hpp"
#include "filemanager.hpp"
#include "webpage.hpp"
#include "global.hpp"
#include "tabsmodel.hpp"

QLoggingCategory SearchDBLogging("SearchDB");

SearchDB::SearchDB()
{
}

bool SearchDB::connect() {
    _db = QSqlDatabase::addDatabase("QSQLITE");
    _dbPath = FileManager::dataPath() + "search.db";
    qCInfo(SearchDBLogging) << "SearchDB: connecting" << _dbPath;
    _db.setDatabaseName(_dbPath);
    _db.setConnectOptions("QSQLITE_OPEN_READONLY");
    if (! _db.open()) {
        qFatal("SearchDB Error: connection with database failed");
    }
    qCInfo(SearchDBLogging) << "SearchDB: connection ok";
    _db.exec("PRAGMA journal_mode=WAL");
    /* SearchWorker setup */
    _searchWorker = SearchWorker_::create(_db, _searchWorkerThread, *QThread::currentThread());
    _searchWorkerThread.start();
    qRegisterMetaType<Webpage_List>();
    QObject::connect(this, &SearchDB::searchAsync, _searchWorker.data(), &SearchWorker::search);
    QObject::connect(this, &SearchDB::searchAsync, this, [=]() { this->set_is_searching(true); });
    QObject::connect(_searchWorker.data(), &SearchWorker::resultChanged, this, [=](const Webpage_List& result) {
        // will this be a race condition?
        this->search_result()->replaceModel(result);
        Global::controller->clearPreviews();
    });
    QObject::connect(_searchWorker.data(), &SearchWorker::searchStarted, this, [=]() {
        this->set_is_searching(true);
    });
    QObject::connect(_searchWorker.data(), &SearchWorker::searchFinished, this, [=]() {
        this->set_is_searching(false);
    });
    /* UpdateWorker setup */
    _updateWorker = UpdateWorker_::create(_db, _updateWorkerThread, *QThread::currentThread());
    _updateWorkerThread.start();
    QObject::connect(this, &SearchDB::addSymbolsAsync, _updateWorker.data(), &UpdateWorker::addSymbols);
    QObject::connect(this, &SearchDB::addSymbolAsync, _updateWorker.data(), &UpdateWorker::addSymbol);
    QObject::connect(this, &SearchDB::addWebpageAsync, _updateWorker.data(), &UpdateWorker::addWebpage);
    QObject::connect(this, &SearchDB::updateSymbolAsync, _updateWorker.data(), &UpdateWorker::updateSymbol);
    QObject::connect(this, &SearchDB::updateWebpageAsync, _updateWorker.data(), &UpdateWorker::updateWebpage);
    QObject::connect(this, &SearchDB::execScriptAsync, _updateWorker.data(), &UpdateWorker::execScript);
    return true;
}

void SearchDB::disconnect() {
    qCInfo(SearchDBLogging) << "SearchDB::disconnect";
    _db.close();
    qCInfo(SearchDBLogging) << "SearchDB::db closed";
    _searchWorkerThread.quit();
    _searchWorkerThread.wait();
    qCInfo(SearchDBLogging) << "SearchDB::SearchWorkerThread quit";
    _updateWorkerThread.quit();
    _updateWorkerThread.wait();
    qCInfo(SearchDBLogging) << "SearchDB::UpdateWorkerThread quit";
    qCInfo(SearchDBLogging) << "SearchDB: disconnected";
}

bool UpdateWorker::execScript(QString const& filename)
{
    QString s = FileManager::readQrcFileS(filename);
    return execMany(s.replace("\n","").split(";", QString::SkipEmptyParts));
}

bool UpdateWorker::execMany(const QStringList& lines)
{
    for (QString const& l : lines) {
        qCInfo(SearchDBLogging) << "UpdateWorker::execMany" << l;
        QSqlQuery query = _db.exec(l);
        if (query.lastError().isValid()) {
            qCCritical(SearchDBLogging) << "UpdateWorker::execMany error when executing"
                        << query.executedQuery()
                        << query.lastError();
            return false;
        }
    }
    return true;
}

bool UpdateWorker::updateWebpage(QString const& url, QString const& property, const QVariant& value)
{
    qCInfo(SearchDBLogging) << "UpdateWorker::updateWebpage" << property << value << url;
    Q_ASSUME(url.indexOf("#") == -1);
    QSqlQuery query(_db);
    query.prepare("UPDATE webpage SET " + property + " = ? WHERE url = '" + url + "'");
    query.addBindValue(value);
    if (! query.exec() || query.numRowsAffected() < 1) {
        qCCritical(SearchDBLogging) << "UpdateWorker::updateWebpage failed" << url << property << value
                    << query.numRowsAffected()
                    << query.executedQuery()
                    << query.lastError();
        return false;
    } else {
        qCInfo(SearchDBLogging) << "UpdateWorker::updateWebpage" << query.executedQuery();
    }
    return true;
}


bool UpdateWorker::updateSymbol(const QString &hash, const QString &property, const QVariant &value)
{
    qCInfo(SearchDBLogging) << "SearchDB::updateSymbol" << property << value << hash;
    QSqlQuery query(_db);
    query.prepare("UPDATE symbol SET " + property + " = :value WHERE hash = '" + hash +"'");
    query.bindValue(":value", value);
    if (! query.exec() || query.numRowsAffected() < 1) {
        qCCritical(SearchDBLogging) << "UpdateWorker::updateSymbol failed" << hash << property << value
                    << query.numRowsAffected()
                    << query.executedQuery()
                    << query.lastError();
        return false;
    } else {
        qCInfo(SearchDBLogging) << "UpdateWorker::updateSymbol" << query.executedQuery();
    }
    return true;
}


bool UpdateWorker::addSymbol(QString const& url, QString const& hash, QString const& text)
{
    QMap<QString,QString> map;
    map[hash] = text;
    return addSymbols(url, map);
}

bool UpdateWorker::addSymbols(QString const& url, const QMap<QString,QString>& symbols)
{
    qCInfo(SearchDBLogging) << "UpdateWorker::addSymbols" << url << symbols;
    Q_ASSUME(url.indexOf("#") == -1);
    QSqlQuery query(_db);
    query.prepare("SELECT id FROM webpage WHERE url = :url");
    query.bindValue(":url", url);
    if (! query.exec() || ! query.first() || !query.isValid()) {
        qCCritical(SearchDBLogging) << "UpdateWorker::addSymbols didn't find the webpage" << url
                    << query.executedQuery()
                    << query.lastError();
        return false;
    }
    const QVariant wid = query.record().value("id");
    for (auto i = symbols.keyBegin();
         i != symbols.keyEnd();
         i++) {
        QString hash = (*i);
        QString text = symbols[hash];
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
                    qCInfo(SearchDBLogging) << "UpdateWorker::addSymbols inserted" << hash << text;
                } else {
                    qCInfo(SearchDBLogging) << "UpdateWorker::addSymbols failed to insert into webpage_symbol" << hash << text
                             << query.lastError();
                }
            } else {
                qCCritical(SearchDBLogging) << "UpdateWorker::addSymbols datatbase does not support QSqlQuery::lastInsertId()";
                return false;
            }
        } else {
            qCCritical(SearchDBLogging) << "UpdateWorker::addSymbols failed to insert to symbol" << hash << text
                        << query.lastError();
        }
    }
    query.clear();
    return true;
}

bool UpdateWorker::addWebpage(QString const& url)
{
    qCInfo(SearchDBLogging) << "UpdateWorker::addWebpage" << url;
    Q_ASSUME(url.indexOf("#") == -1);
    QSqlQuery query(_db);
    query.prepare("REPLACE INTO webpage (url, title, visited, html) VALUES (:url,'','',0)");
    query.bindValue(":url", url);
    if (! query.exec()) {
        qCCritical(SearchDBLogging) << "ERROR: UpdateWorker::addWebpage failed!" << query.lastError();
        return false;
    };
    return true;
}

bool SearchDB::removeWebpage(QString const& url)
{
    qCInfo(SearchDBLogging) << "SearchDB::removeWebpage" << url;
    Q_ASSUME(url.indexOf("#") == -1);
    return false;
}

Webpage_ SearchDB::findWebpage_(QString const& url) const
{
    qCInfo(SearchDBLogging) << "SearchDB::findWebpage_" << url;
    Q_ASSUME(url.indexOf("#") == -1);
    QSqlQuery query(_db);
    query.prepare("SELECT * FROM webpage WHERE url = ? LIMIT 1");
    query.addBindValue(url);
    if (! query.first()) {
        qCCritical(SearchDBLogging) << "SearchDB::findWebpage_ not found!" << url;
        return Webpage_(nullptr);
    }
    QSqlRecord r = query.record();
    qCInfo(SearchDBLogging) << "SearchDB::findWebpage_ found " << r;
    Webpage_ wp = shared<Webpage>(url);
//    wp->set_title(r.value("title").value<QString>());
//    wp->set_visited(r.value("visited").value<int>());
    return wp;
}

QVariantMap SearchDB::findWebpage(QString const& url) const
{
    qCInfo(SearchDBLogging) << "SearchDB::findWebpage" << url;
    Q_ASSUME(url.indexOf("#") == -1);
    Webpage_ p = SearchDB::findWebpage_(url);
    if (p.get() == nullptr) {
        qCCritical(SearchDBLogging) << "SearchDB::findWebpage not found!" << url;
        return QVariantMap();
    }
    return p->toQVariantMap();
}

bool SearchDB::hasWebpage(QString const& url) const
{
    qCInfo(SearchDBLogging) << "SearchDB::hasWebpage" << url;
    Q_ASSUME(url.indexOf("#") == -1);
    QSqlQuery query(_db);
    query.prepare("SELECT url FROM webpage WHERE url = ? LIMIT 1");
    query.addBindValue(url);
    bool b = query.first();
    qCInfo(SearchDBLogging) << "SearchDB::hasWebpage" << url << b;
    return b;
}

SearchWorker::SearchWorker(const QSqlDatabase& db, QThread& _thread, QThread& _qmlThread)
    : _db(QSqlDatabase::cloneDatabase(db, "SearchWorker")), _dataThread(&_qmlThread)
{
    this->moveToThread(&_thread);
    _db.setConnectOptions("QSQLITE_OPEN_READONLY");
    _db.open();
    _db.exec("PRAGMA journal_mode=WAL");
    qCInfo(SearchDBLogging) << "SearchWorker::SearchWorker initialized and moved to thread" << &_thread;
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
    qCInfo(SearchDBLogging) << "UpdateWorker::UpdateWorker initialized and moved to thread" << &_thread;
}

UpdateWorker::~UpdateWorker()
{
    if (! execScript("db/exit.sqlite3")) {
        qCInfo(SearchDBLogging) << "UpdateWorker::disconnect failed";
    }
    _db.close();
}

void SearchWorker::search(QString const& word)
{
    qCInfo(SearchDBLogging) << "SearchWorker::search" << word;
    Webpage_List pages;
    emit searchStarted();
    emit resultChanged(pages);
    QStringList ws = word.split(QRegularExpression(" "), QString::SkipEmptyParts);
    QString q;
    if (word == "") {
        emit resultChanged(pages);
        emit searchFinished();
        return;
//        q = QStringLiteral("SELECT DISTINCT webpage.id, url, COALESCE(title, '') as title, visited FROM webpage ORDER BY visited DESC LIMIT 50");
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
    qCInfo(SearchDBLogging) << "SearchWorker::search" << q;
    QSqlQuery r = _db.exec(q);
    if (r.lastError().isValid()) {
        qCCritical(SearchDBLogging) << "SearchWorker::search failed"
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
        QString display_filename = "./" + last + "  ";
        QString display_partial_url = "";
        display_partial_url += url.leftRef(last_index);
        // special case when at root domain
        if (last_index == url_domain_start) {
            display_partial_url = url;
            if (path.length() >= 2) {
                display_filename = path[1];
            } else {
                display_filename = "./index";
            }
        }

        QString title = record.value("title").value<QString>();
        QString symbol = record.value("symbol").value<QString>();
        QString hash = record.value("hash").value<QString>();
        QString display_symbol = (0 < symbol.length() && hash.length() < 32 ? "@"+symbol+"  " : "");
        QString display_hash = (0 < hash.length() && hash.length() < 32 ? "#"+hash+"  " : "");
        QString display_title = (title.length() > 0 ? title + "  " : "");
        QString display = display_symbol + display_hash + display_filename + display_title + display_partial_url;
        QStringList expanded_display;
        expanded_display << display_title
                         << display_symbol + display_hash + display_filename
                         << display_partial_url;
        Webpage_ wp = shared<Webpage>(Url(url + "#" + hash), display_title, display_symbol + display_hash + display_filename, display_partial_url);
        wp->moveToThread(_dataThread);
        pages << wp;
        r.next();
    }
    emit resultChanged(pages);
    emit searchFinished();
    qCInfo(SearchDBLogging) << "SearchWorker::search found" << pages.count();
}





