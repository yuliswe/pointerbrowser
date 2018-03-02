#include <QtCore/QtCore>
#include <algorithm>
#include "searchdb.hpp"
#include "filemanager.hpp"
#include "webpage.hpp"
#include "global.hpp"
#include "tabsmodel.hpp"


QSqlDatabase SearchWorker::db()
{
    if (FileManager::searchDBPath() == ":memory:") {
        return QSqlDatabase::database("UpdateWorker");
    }
    return QSqlDatabase::database("SearchWorker");
}


QSqlDatabase UpdateWorker::db()
{
    return QSqlDatabase::database("UpdateWorker");
}

bool SearchDB::connect() {

    Q_ASSERT(QThread::currentThread() == Global::qCoreApplicationThread);

    /* UpdateWorker setup */
    update_worker()->moveToThread(update_worker_thread().get());
    update_worker_thread()->start();
    update_worker_thread()->setPriority(QThread::LowestPriority);
    update_worker()->connectBlocking();
    qCInfo(SearchDBLogging) << "UpdateWorker::UpdateWorker initialized and moved to its thread.";

    QObject::connect(update_worker().get(), &UpdateWorker::newEntriesWritten, [=]() {
        //        if (search_worker()->is_reading()) { return; }
        Webpage_ w = search_webpage();
        if (w) {
            search_worker()->searchForWebpageAsync(w, search_limit(), update_worker().get());
        } else {
            search_worker()->searchAsync(search_string(), search_limit(), update_worker().get());
        }
    });

    /* SearchWorker setup */
    if (FileManager::searchDBPath() == ":memory:") {
        search_worker()->moveToThread(update_worker_thread().get());
    } else {
        search_worker()->moveToThread(search_worker_thread().get());
        search_worker_thread()->start();
    }
    search_worker()->connectBlocking();
    qCInfo(SearchDBLogging) << "SearchWorker::SearchWorker initialized and moved to its thread";

    qRegisterMetaType<Webpage_List>();
    QObject::connect(search_worker().get(), &SearchWorker::resultChanged, this, [=](const Webpage_List& result, void const* sender) {
        qCDebug(SearchDBLogging) << "search result changed";
        if (sender == update_worker().get()) {
            qCDebug(SearchDBLogging) << "change was requested by UpdateWorker";
            // append new ones to back
            for (auto i = result.begin();
                 i != result.end() && search_result()->count() < search_limit();
                 i++)
            {
                Webpage_ w = *i;
                if (! current_url_set()->contains(w->url())) {
                    // found one that does not already exist
                    current_url_set()->insert(w->url());
                    search_result()->insertWebpage_(search_result()->count(), w);
                }
            }
        } else {
            qCDebug(SearchDBLogging) << "change was requested by user";
            // replace direclty
            search_result()->replaceModel(result);
            Global::controller->preview_tabs()->clear();
            // reset url set
            current_url_set()->clear();
            for (int i = 0; i < search_result()->count(); i++) {
                Webpage_ w = search_result()->webpage_(i);
                current_url_set()->insert(w->url());
            }
        }
    });
    return true;
}

void SearchDB::disconnect() {
    qCInfo(SearchDBLogging) << "SearchDB::disconnect";
    qCInfo(SearchDBLogging) << "SearchDB::db closed";
    search_worker()->disconnectBlocking();
    search_worker_thread()->quit();
    search_worker_thread()->wait();
    qCInfo(SearchDBLogging) << "SearchDB::SearchWorkerThread quit";
    update_worker()->disconnectBlocking();
    update_worker_thread()->quit();
    update_worker_thread()->wait();
    qCInfo(SearchDBLogging) << "SearchDB::UpdateWorkerThread quit";
    qCInfo(SearchDBLogging) << "SearchDB: disconnected";
}

bool UpdateWorker::execScript(QString const& filename, void const* sender)
{
    QString s = FileManager::readQrcFileS(filename);
    return execMany(s.replace("\n","").split(";", QString::SkipEmptyParts));
}

bool UpdateWorker::execMany(const QStringList& lines, void const* sender)
{
    for (QString const& l : lines) {
        qCInfo(SearchDBLogging) << "UpdateWorker::execMany" << l;
        QSqlQuery query = db().exec(l);
        if (query.lastError().isValid() || db().lastError().isValid()) {
            qCCritical(SearchDBLogging) << "UpdateWorker::execMany error when executing"
                                        << query.executedQuery()
                                        << query.lastError()
                                        << db().lastError().isValid();
            return false;
        }
    }
    return true;
}

bool UpdateWorker::updateWebpage(UrlNoHash const& url, QString const& property, const QVariant& value, void const* sender)
{
    qCInfo(SearchDBLogging) << "UpdateWorker::updateWebpage" << property << value << url;
    QSqlQuery query(db());
    query.prepare("UPDATE webpage SET " + property + " = ? WHERE url = '" + url.base() + "'");
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


bool UpdateWorker::updateSymbol(const QString &hash, const QString &property, const QVariant &value, void const* sender)
{
    qCInfo(SearchDBLogging) << "SearchDB::updateSymbol" << property << value << hash;
    QSqlQuery query(db());
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


bool UpdateWorker::addSymbol(UrlNoHash const& url, QString const& hash, QString const& text)
{
    QMap<QString,QString> map;
    map[hash] = text;
    return addSymbols(url, map);
}

bool UpdateWorker::addSymbols(UrlNoHash const& url, const QMap<QString,QString>& symbols, void const* sender)
{
    qCInfo(SearchDBLogging) << "UpdateWorker::addSymbols" << url.base() << symbols;
    // find id for webpage
    QSqlQuery query(db());
    query.prepare("SELECT id FROM webpage WHERE url = :url");
    query.bindValue(":url", url.base());
    if (! query.exec() || ! query.first() || !query.isValid()) {
        qCCritical(SearchDBLogging) << "UpdateWorker::addSymbols didn't find the webpage" << url
                                    << query.executedQuery()
                                    << query.lastError();
        return false;
    }
    const QVariant wid = query.record().value("id");
    qCDebug(SearchDBLogging) << "Find webpage url" << url.base() << "id" << wid.value<uint_least64_t>();
    // symbol table insertion begins
    QVariantList hash_ls;
    QVariantList text_ls;
    QVariantList visited_ls;
    qint64 visited = QDateTime::currentSecsSinceEpoch();
    query.prepare("INSERT INTO symbol (hash,text,visited) VALUES (:hash,:text,:visited)");
    for (auto i = symbols.keyBegin(); i != symbols.keyEnd(); i++)
    {
        QString hash = (*i);
        QString text = symbols[hash];
        // check if symbol already exists
        hash_ls << hash;
        text_ls << text;
        visited_ls << visited;
    }
    query.bindValue(":hash", hash_ls);
    query.bindValue(":text", text_ls);
    query.bindValue(":visited", text_ls);
    if (query.execBatch() && ! query.lastError().isValid()) {
        qCDebug(SearchDBLogging) << "UpdateWorker::addSymbols inserted" << query.numRowsAffected() << "rows";
    } else {
        qCCritical(SearchDBLogging) << "UpdateWorker::addSymbols failed to insert into symbol table"<< query.lastError();
    }
    // webpage_symbol table insertion begins
    query.prepare("INSERT INTO webpage_symbol (webpage,symbol) SELECT webpage.id, symbol.id FROM webpage,symbol WHERE webpage.url = :url AND symbol.hash = :hash AND symbol.text = :text");
    QVariantList url_ls;
    for (int i = 0; i < hash_ls.count(); i++) { url_ls << url.base(); }
    query.bindValue(":hash", hash_ls);
    query.bindValue(":text", text_ls);
    query.bindValue(":url", url_ls);
    if (query.execBatch() && ! query.lastError().isValid() && ! db().lastError().isValid()) {
        qCDebug(SearchDBLogging) << "UpdateWorker::addSymbols inserted into webpage_symbol" << query.numRowsAffected() << "rows";
    } else {
        qCCritical(SearchDBLogging) << "UpdateWorker::addSymbols failed to insert into webpage_symbol"
                                    << query.lastError();
    }

//    static qint64 last_called = -1;
//    if (QDateTime::currentSecsSinceEpoch() - last_called >= 1) {
//        emit newEntriesWritten();
//        last_called = QDateTime::currentSecsSinceEpoch();
//    }
    emit newEntriesWritten();
    return true;
}


bool UpdateWorker::addReferer(UrlNoHash const& from, const QStringStringMap& to, void const* sender)
{
    qCInfo(SearchDBLogging) << "UpdateWorker::addReferer" << from.base() << to;
    // find id for webpage
    QSqlQuery query(db());
    // insertion begins
    QVariantList to_urls;
    QVariantList from_urls;
    QVariantList to_text;
    query.prepare("INSERT INTO webpage_referer (webpage,referer,text) SELECT child.id, parent.id, :to_text FROM webpage child, webpage parent WHERE parent.url = :from_urls AND child.url = :to_urls");
    for (auto k = to.keyBegin(); k != to.keyEnd(); k++)
    {
        from_urls << from;
        to_urls << *k;
        to_text << to[*k].trimmed();
    }
    query.bindValue(":from_urls", from_urls);
    query.bindValue(":to_urls", to_urls);
    query.bindValue(":to_text", to_text);
    if (query.execBatch() && ! query.lastError().isValid()) {
        qCDebug(SearchDBLogging) << "UpdateWorker::addReferer inserted into webpage_referer table" << query.numRowsAffected();
    } else {
        qCCritical(SearchDBLogging) << "UpdateWorker::addReferer failed to insert into webpage_referer table"
                                    << query.lastError();
    }

//    static qint64 last_called = -1;
//    if (QDateTime::currentSecsSinceEpoch() - last_called >= 1) {
//        emit newEntriesWritten();
//        last_called = QDateTime::currentSecsSinceEpoch();
//    }
    emit newEntriesWritten();
    return true;
}


bool UpdateWorker::addWebpage(Webpage_ w, void const* sender)
{
    QList<Webpage_> ls;
    ls << w;
    return addWebpages(ls, sender);
}

bool UpdateWorker::addWebpage(UrlNoHash const& w, void const* sender)
{
    QSet<UrlNoHash> ls;
    ls << w;
    return addWebpages(ls, sender);
}

bool UpdateWorker::addWebpages(QSet<UrlNoHash> const& s, void const* sender)
{
    QList<Webpage_> ls;
    for (auto i = s.begin(); i != s.end(); i++)
    {
        Webpage_ w = shared<Webpage>(i->base());
        ls << w;
        qCDebug(SearchDBLogging) << "UpdateWorker::addWebpages add" << w->url();
    }
    return addWebpages(ls);
}

bool UpdateWorker::addWebpages(QList<Webpage_> const& ls, void const* sender)
{
    qCInfo(SearchDBLogging) << "UpdateWorker::addWebpages" << ls.count() << "pages: ";
    QSqlQuery query(db());
    QVariantList url_ls;
    QVariantList title_ls;
    QVariantList visited_ls;
    QVariantList html_ls;
    query.prepare("INSERT INTO webpage (url, title, visited, html) VALUES (:url,:title,'',0)");
    for (int i = 0; i < ls.count(); i++) {
        Webpage_ w = ls[i];
        url_ls << UrlNoHash(w->url()).base();
        title_ls << w->title();
        html_ls << "";
        visited_ls << 0;
        qCDebug(SearchDBLogging) << "UpdateWorker::addWebpage" << UrlNoHash(w->url()) << "pages: ";
    }
    query.bindValue(":url", url_ls);
    query.bindValue(":title", title_ls);
    query.bindValue(":visited", visited_ls);
    query.bindValue(":html", html_ls);
    if (query.execBatch() && ! query.lastError().isValid()) {
        qCDebug(SearchDBLogging) << "UpdateWorker::addWebpages added" << query.numRowsAffected() << "new webpages";
    } else {
        qCCritical(SearchDBLogging) << "ERROR: UpdateWorker::addWebpage failed" << query.lastError();
    }
    return true;
}

int SearchWorker::connect(void const* sender)
{
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", "SearchWorker");
    db.setDatabaseName(FileManager::searchDBPath());
    db.setConnectOptions("QSQLITE_OPEN_READONLY, QSQLITE_ENABLE_SHARED_CACHE");
    if (! db.open()) {
        qFatal("SearchWorker Error: connection with database failed");
    }
    qCInfo(SearchDBLogging) << "SearchWorker: connection ok";
    db.exec("PRAGMA journal_mode=WAL");
    return true;
}


int UpdateWorker::connect(void const* sender)
{
    qRegisterMetaType<QStringStringMap>();
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", "UpdateWorker");
    db.setDatabaseName(FileManager::searchDBPath());
    db.setConnectOptions("QSQLITE_ENABLE_SHARED_CACHE");
    if (! db.open()) {
        qFatal("UpdateWorker Error: connection with database failed");
    }
    qCInfo(SearchDBLogging) << "UpdateWorker: connection ok";
    db.exec("PRAGMA journal_mode=WAL");
    if (Global::isNewInstall) {
        execScript("db/dropAll.sqlite3");
    }
    execScript("db/setup.sqlite3");
    return true;
}

int SearchWorker::disconnect(void const* sender)
{
    db().close();
    return true;
}

int UpdateWorker::disconnect(void const* sender)
{
    if (! execScript("db/exit.sqlite3")) {
        qCInfo(SearchDBLogging) << "UpdateWorker::disconnect failed";
    }
    db().close();
    return true;
}

int SearchWorker::search(QString const& word, int search_limit, void const* sender)
{
    qCInfo(SearchDBLogging) << "SearchWorker::search" << word << sender;
    set_is_reading(true);
    set_current_search_string(word);
    emit resultChanged(QList<Webpage_>(), sender);
    QStringList ws = word.split(QRegularExpression(" "), QString::SkipEmptyParts);
    QString q;
    if (word == "") {
        emit resultChanged(QList<Webpage_>(), sender);
        set_is_reading(false);
        return true;
    }
    if (ws.length() == 0) { return true; }
    /* WITH LEFT JOIN */
    q = QStringLiteral("SELECT DISTINCT IFNULL(url,'') AS url, IFNULL(title,'') as title, IFNULL(hash,'') as hash, IFNULL(symbol,'') as symbol FROM (");
    q += QStringLiteral() +
         "SELECT " +
         "   url, title, symbol.visited AS visited, hash, symbol.text AS symbol " +
         " FROM webpage" +
         " LEFT JOIN webpage_symbol ON webpage.id = webpage_symbol.webpage" +
         " LEFT JOIN symbol ON symbol.id = webpage_symbol.symbol" +
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
    q += " ORDER BY url ASC, visited DESC";
    q += ", CASE WHEN LENGTH(symbol) = 0 THEN 99999 ELSE LENGTH(symbol) END ASC";
    q += ", CASE WHEN LENGTH(hash) = 0 THEN 99999 ELSE LENGTH(hash) END ASC";
    q += ", CASE WHEN LENGTH(title) = 0 THEN 99999 ELSE LENGTH(title) END ASC";
    q += " LIMIT " + QString::number(search_limit);

    qCInfo(SearchDBLogging) << "SearchWorker::search" << q;
    QSqlQuery r = db().exec(q);
    QList<Webpage_> pages = webpagesFromQuery(r);
    emit resultChanged(pages, sender);
    qCInfo(SearchDBLogging) << "SearchWorker::search found" << pages.count();
    set_is_reading(false);
    return true;
}

bool SearchWorker::custom_set_is_reading(bool const& reading, void const* sender)
{
    if (reading) {
        qCDebug(SearchDBLogging) << "SearchWorker::reading db..";
    } else {
        qCDebug(SearchDBLogging) << "SearchWorker::reading db done.";
    }
    return reading;
}

int SearchWorker::searchForWebpage(Webpage_ w, int search_limit, void const* sender)
{
    qCInfo(SearchDBLogging) << "SearchWorker::searchForWebpage" << w << sender;
    set_is_reading(true);
    emit resultChanged(QList<Webpage_>(), sender);
    QSqlQuery query(db());
    query.prepare("SELECT id FROM webpage WHERE url = :url");
    query.bindValue(":url", w->url().base());
    if (! query.exec() || ! query.first() || !query.isValid()) {
        qCCritical(SearchDBLogging) << "SearchWorker::searchForWebpage didn't find the webpage" << w->url()
                                    << query.executedQuery()
                                    << query.lastError();
        set_is_reading(false);
        return false;
    }
    QVariant pid = query.record().value("id");
    QString q;
    /* WITH LEFT JOIN */
    q = QStringLiteral() +
        "SELECT DISTINCT IFNULL(url,'') AS url, COALESCE(text,title,'') AS title, IFNULL(hash,'') AS hash, IFNULL(symbol,'') AS symbol " +
        " FROM ( SELECT url, text, title, NULL AS hash, NULL AS symbol " +
        "        FROM webpage_referer LEFT JOIN webpage ON webpage.id = webpage_referer.webpage " +
        "        WHERE referer = :pid " +
        "        UNION SELECT url, NULL AS text, title, symbol.text AS symbol, symbol.hash AS hash " +
        "        FROM webpage LEFT JOIN webpage_symbol on webpage_symbol.webpage = webpage.id " +
        "                     LEFT JOIN symbol ON symbol.id = webpage_symbol.symbol " +
        "        WHERE webpage.id = :pid ) " +
        " ORDER BY url ASC " +
        " LIMIT " + QString::number(search_limit);
    qCInfo(SearchDBLogging) << "SearchWorker::search" << q << pid;

    QSqlQuery r(db());
    r.prepare(q);
    r.bindValue(":pid", pid);
    r.exec();
    QList<Webpage_> pages = webpagesFromQuery(r);
    emit resultChanged(pages, sender);
    qCInfo(SearchDBLogging) << "SearchWorker::search found" << pages.count();
    set_is_reading(false);
    return true;
}

int SearchDB::search(QString const& words, void const* sender)
{
    qCInfo(SearchDBLogging) << "SearchDB::search" << words;
    set_search_string(words);
    set_search_webpage(nullptr);
    set_is_searching(true);
    search_worker()->searchAsync(words, search_limit());
    return true;
}

int SearchDB::searchForWebpage(Webpage_ w, void const* sender)
{
    qCInfo(SearchDBLogging) << "SearchDB::searchForWebpage" << w->url();
    set_search_string("");
    set_search_webpage(w);
    set_is_searching(true);
    search_worker()->searchForWebpageAsync(w, search_limit());
    return true;
}

QList<Webpage_> SearchWorker::webpagesFromQuery(QSqlQuery& r)
{
    QList<Webpage_> pages;
    if (r.lastError().isValid()) {
        qCCritical(SearchDBLogging) << "SearchWorker::search failed"
                                    << r.lastError();
        return pages;
    }
    r.first();
    QRegularExpression slash("/");
    QRegularExpression protocal("^(.+://)");
    while (r.isValid()) {
        QSqlRecord record = r.record();
        QString url = record.value("url").value<QString>();
        if (! Global::crawler->rule_table()->hasEnabledAndMatchedRuleForUrl(url))
        {
            qCDebug(SearchDBLogging) << "ignored an entry in" << Url(url).full() << "because it is filtered by crawler rule table";
            r.next();
            continue;
        }
        QRegularExpressionMatch protocal_match = protocal.match(url);
        int url_domain_start = protocal_match.capturedLength();
        QStringList path = url.split(slash, QString::SkipEmptyParts);
        QString last = path.length() > 0 ? path[path.length() - 1] : "";
        int last_index = url.lastIndexOf(last);
        QString display_filename = "/" + last + "  ";
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
        wp->moveToThread(Global::qCoreApplicationThread);
        pages << wp;
        r.next();
    }
    return pages;
}

