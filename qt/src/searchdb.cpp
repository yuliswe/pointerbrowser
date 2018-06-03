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
    qDebug() << "libraryPaths:" << QCoreApplication::libraryPaths();
    _db = QSqlDatabase::addDatabase("QSQLITE");
    _dbPath = FileManager::dataPath() + "search.db";
    qDebug() << "SearchDB: connecting" << _dbPath;
    _db.setDatabaseName(_dbPath);
    if (! _db.open()) {
        qDebug() << "SearchDB Error: connection with database failed";
        return false;
    }
    qDebug() << "SearchDB: connection ok";

//    execMany(QStringList("PRAGMA foreign_keys = ON;"));

    _webpage = QSharedPointer<QSqlRelationalTableModel>::create(nullptr, _db);
    _webpage->setTable("webpage");
    _webpage->setEditStrategy(QSqlTableModel::OnManualSubmit);
    _symbol = QSharedPointer<QSqlRelationalTableModel>::create(nullptr, _db);
    _symbol->setTable("symbol");
    _symbol->setEditStrategy(QSqlTableModel::OnManualSubmit);
    _webpage_symbol = QSharedPointer<QSqlRelationalTableModel>::create(nullptr, _db);
    _webpage_symbol->setTable("webpage_symbol");
    _webpage_symbol->setEditStrategy(QSqlTableModel::OnManualSubmit);
    if (! _webpage->select()) {
        qDebug() << "cannot find table 'webpage'";
    } else {
        qDebug() << "found table 'webpage'";
    };
    if (! _symbol->select()) {
        qDebug() << "cannot find table 'symbol'";
    } else {
        qDebug() << "found table 'symbol'";
    };
    if (! _webpage_symbol->select()) {
        qDebug() << "cannot find table 'webpage_symbol'";
    } else {
        qDebug() << "found table 'webpage_symbol'";
    };
    search("");
    return true;
}

void SearchDB::disconnect() {
    if (! execScript("db/exit.sqlite3")) {
        qDebug() << "SearchDB::disconnect failed";
    }
    _db.close();
    qDebug() << "SearchDB: disconnected";
}

bool SearchDB::execScript(QString filename)
{
    QString s = FileManager::readQrcFileS(filename);
    return execMany(s.replace("\n","").split(";", QString::SkipEmptyParts));
}

bool SearchDB::execMany(const QStringList& lines)
{
    for (const QString l : lines) {
        qDebug() << "SearchDB::execMany" << l;
        QSqlQuery query = _db.exec(l);
        QSqlError error = query.lastError();
        if (error.isValid()) {
            qCritical() << "SearchDB::execMany error when executing" << l
                        << error;
            return false;
        }
    }
    return true;
}

bool SearchDB::updateWebpage(const QString& url, const QString& property, const QVariant& value)
{
    qDebug() << "SearchDB::updateWebpage" << property << value << url;
    _webpage->setFilter("url = '" + url + "'");
    _webpage->select();
    if (_webpage->rowCount() == 0) {
        qCritical() << "SearchDB::updateWebpage didn't find the webpage" << url
                    << _webpage->lastError();
        return false;
    }
    QSqlRecord record = _webpage->record(0);
    record.setValue(property, value);
    if (! _webpage->setRecord(0, record)) {
        qCritical() << "SearchDB::updateWebpage failed" << url
                    << _webpage->lastError();
        return false;
    }
    _webpage->submitAll();
    return true;
}


bool SearchDB::updateSymbol(const QString &hash, const QString &property, const QVariant &value)
{
    qDebug() << "SearchDB::updateSymbol" << property << value << hash;
    _symbol->setFilter("hash = '" + hash + "'");
    _symbol->select();
    if (_symbol->rowCount() == 0) {
        qCritical() << "SearchDB::updateSymbol didn't find the symbol" << hash
                    << _symbol->lastError();
        return false;
    }
    QSqlRecord record = _symbol->record(0);
    record.setValue(property, value);
    if (! _symbol->setRecord(0, record)) {
        qCritical() << "SearchDB::updateSymbol failed" << hash
                    << _symbol->lastError();
        return false;
    }
    _symbol->submitAll();
    return true;
}

void SearchDB::addSymbolsAsync(const QString& url, const QVariantMap& symbols)
{
    static QSemaphore sem(1);
    QtConcurrent::run([=]() {
        sem.acquire(1);
        SearchDB::addSymbols(url, symbols);
        sem.release(1);
    });
}

bool SearchDB::addSymbols(const QString& url, const QVariantMap& symbols)
{

    qDebug() << "SearchDB::addSymbols" << url << symbols;
    QSqlQuery query0;
    query0.prepare("SELECT id FROM webpage WHERE url = :url");
    query0.bindValue(":url", url);
    if (! query0.exec() || ! query0.first() || !query0.isValid()) {
        qCritical() << "SearchDB::addSymbols didn't find the webpage" << url
                    << query0.lastError();
        return false;
    }
    const QVariant wid = query0.record().value("id");
    for (auto i = symbols.keyBegin();
         i != symbols.keyEnd();
         i++) {
        QString hash = (*i);
        QString text = symbols[hash].value<QString>();
        query0.prepare("INSERT INTO symbol (hash,text,visited) VALUES (:hash,:text,:visited)");
        query0.bindValue(":hash", hash);
        query0.bindValue(":text", text);
        query0.bindValue(":visited", 0);
        if (query0.exec()) {
            QVariant sid = query0.lastInsertId();
            if (sid.isValid()) {
                query0.prepare("INSERT INTO webpage_symbol (webpage,symbol) VALUES (:webpage,:symbol)");
                query0.bindValue(":symbol", sid);
                query0.bindValue(":webpage", wid);
                if (query0.exec()) {
                    qDebug() << "SearchDB::addSymbols inserted" << hash << text;
                } else {
                    qDebug() << "SearchDB::addSymbols failed to insert into webpage_symbol" << hash << text
                             << query0.lastError();
                }
            } else {
                qCritical() << "SearchDB::addSymbols datatbase does not support QSqlQuery::lastInsertId()";
                return false;
            }
        } else {
            qCritical() << "SearchDB::addSymbols failed to insert to symbol" << hash << text
                        << query0.lastError();
        }
    }
    return true;
}

bool SearchDB::addWebpage(const QString& url)
{
    qDebug() << "SearchDB::addWebpage" << url;
    QSqlRecord wpRecord = _webpage->record();
    wpRecord.setValue("url", url);
    wpRecord.setValue("html", "");
    wpRecord.setValue("title", "");
    wpRecord.setValue("visited", 0);
    if (! (_webpage->insertRecord(-1, wpRecord)
           && _webpage->submitAll()))
    {
        qCritical() << "ERROR: SearchDB::addWebpage failed!" << _webpage->lastError();
        return false;
    };
    return true;
}

bool SearchDB::removeWebpage(const QString& url)
{
    qDebug() << "SearchDB::removeWebpage" << url;
    _webpage->setFilter("url = '" + url + "'");
    _webpage->select();
    if (_webpage->rowCount() == 0) {
        qCritical() << "SearchDB::removeWebpage didn't find the webpage" << url;
        return false;
    }
    const QSqlRecord wpr = _webpage->record(0);
    _webpage_symbol->setFilter("webpage = '" + wpr.value("id").value<QString>() + "'");
    qDebug() << "SearchDB::removeWebpage removing _webpage_symbol where" << "webpage = '" + wpr.value("id").value<QString>() + "'";
    _webpage_symbol->select();
    if (_webpage_symbol->rowCount() > 0) {
        if (! _webpage_symbol->removeRows(0, _webpage_symbol->rowCount())) {
            qCritical() << "SearchDB::removeWebpage couldn't remove row from _webpage_symbol"
                        << _webpage_symbol->lastError();
            goto whenFailed;
        }
    }
    if (! _webpage->removeRows(0, _webpage->rowCount())) {
        qCritical() << "SearchDB::removeWebpage couldn't remove row from _webpage"
                    << _webpage->lastError();
        goto whenFailed;
    }
    _webpage->submitAll();
    return _webpage_symbol->submitAll();
whenFailed:
    qCritical() << "SearchDB::removeWebpage failed";
    _webpage->revertAll();
    _webpage_symbol->revertAll();
    return false;
}

Webpage_ SearchDB::findWebpage_(const QString& url) const
{
    qDebug() << "SearchDB::findWebpage_" << url;
    const QString query = "url = '" + url + "'";
    _webpage->setFilter(query);
    _webpage->select();
    if (_webpage->rowCount() == 0) {
        qCritical() << "SearchDB::findWebpage_ not found!" << url;
        return QSharedPointer<Webpage>(nullptr);
    }
    QSqlRecord r = _webpage->record(0);
    qDebug() << "SearchDB::findWebpage_ found " << r;
    Webpage_ wp = Webpage_::create(url);
    wp->set_title(r.value("title").value<QString>());
    wp->set_visited(r.value("visited").value<int>());
    return wp;
}

QVariantMap SearchDB::findWebpage(const QString& url) const
{
    qDebug() << "SearchDB::findWebpage" << url;
    Webpage_ p = SearchDB::findWebpage_(url);
    if (p.isNull()) {
        qCritical() << "SearchDB::findWebpage not found!" << url;
        return QVariantMap();
    }
    return p->toQVariantMap();
}

bool SearchDB::hasWebpage(const QString& url) const
{
    const QString query = "url = '" + url + "'";
    _webpage->setFilter(query);
    _webpage->select();
    bool b = _webpage->rowCount() > 0;
    qDebug() << "SearchDB::hasWebpage" << url << b;
    return b;
}

void SearchDB::search(const QString& word)
{
    qDebug() << "SearchDB::search" << word;
    _currentWord = word;
    _searchResult.clear();
    if (word == "") {
        _webpage->setFilter("");
        _webpage->select();
        int upper = std::min(50, _webpage->rowCount());
        for (int i = 0; i < upper; i++) {
            QSqlRecord record = _webpage->record(i);
            QString url = record.value("url").value<QString>();
            QString title = record.value("title").value<QString>();
            _searchResult.insertTab(0, url);
            _searchResult.updateTab(0, "title", title);
        }
    } else {
        QStringList ws = word.split(QRegularExpression(" "), QString::SkipEmptyParts);
        if (ws.length() == 0) { return; }
        QString q = QStringLiteral() +
                    "SELECT DISTINCT" +
                    "   webpage.id, url, COALESCE(title, '') as title"
                    " , CASE WHEN hash IS NULL THEN webpage.visited ELSE symbol.visited END as visited" +
                    " , hash, COALESCE(symbol.text,'') as symbol" +
                    " FROM webpage" +
                    " LEFT JOIN webpage_symbol ON webpage.id = webpage_symbol.webpage" +
                    " LEFT JOIN symbol ON symbol.id = webpage_symbol.symbol" +
                    " WHERE ";
        for (auto w = ws.begin(); w != ws.end(); w++) {
            q += QStringLiteral() +
                 " (" +
                 "    INSTR(LOWER(symbol.text),LOWER('" + (*w) + "'))" +
                 "    OR INSTR(LOWER(symbol.hash),LOWER('" + (*w) + "'))" +
                 "    OR INSTR(LOWER(webpage.title),LOWER('" + (*w) + "'))" +
                 "    OR INSTR(LOWER(webpage.url),LOWER('" + (*w) + "'))" +
                 " )";
            if (w != ws.end() - 1) {
                q += " AND ";
            }
        }
        q += " ORDER BY visited DESC";
        q += ", CASE WHEN LENGTH(symbol.text) = 0 THEN 99999 ELSE LENGTH(symbol.text) END ASC";
        q += ", CASE WHEN LENGTH(symbol.hash) = 0 THEN 99999 ELSE LENGTH(symbol.hash) END ASC";
        q += ", CASE WHEN LENGTH(webpage.title) = 0 THEN 99999 ELSE LENGTH(webpage.title) END ASC";
        q += ", LENGTH(url) ASC";
        q += " LIMIT 50";
        qDebug() << "SearchDB::search" << q;
        QSqlQuery r = _db.exec(q);
        if (r.lastError().isValid()) {
            qCritical() << "SearchDB::search failed" << r.lastError();
            return;
        }
        r.first();
        QRegularExpression searchRegex(ws.join("|"), QRegularExpression::CaseInsensitiveOption);
        while (r.isValid()) {
            QSqlRecord record = r.record();
            qDebug() << "SearchDB::search found" << record;
            QString url = record.value("url").value<QString>();
            QStringList path = url.split(QRegularExpression("/"), QString::SkipEmptyParts);
            QString last = path.length() > 0 ? path[path.length() - 1] : "";
            QString title = record.value("title").value<QString>();
            QString symbol = record.value("symbol").value<QString>();
            QString hash = record.value("hash").value<QString>();
            QString display =
                    (symbol.length() > 0 ? "@"+symbol+"  " : "") +
                    (hash.length() > 0 ? "#"+hash+"  " : "") +
                    "/"+last+"  " +
                    (title.length() > 0 ? "\""+title+"\"" : "") +
                    (symbol.length() == 0 && hash.length() == 0 && title.length() == 0 ? ""+url+"  " : "");
            int i = _searchResult.count();
            Webpage_ wp = Webpage_::create(url);
            wp->set_title(title);
            wp->set_symbol(symbol);
            wp->set_hash(hash);
            wp->set_display(display);
            _searchResult.insertWebpage(i, wp);

//            _searchResult.updateTab(i, "title_matched", searchRegex.match(title).hasMatch());
//            _searchResult.updateTab(i, "symbol_matched", searchRegex.match(symbol).hasMatch());
//            _searchResult.updateTab(i, "hash_matched", searchRegex.match(hash).hasMatch());
//            _searchResult.updateTab(i, "url_matched", searchRegex.match(url).hasMatch());
            r.next();
        }
    }
    qDebug() << "SearchDB::search found" << _searchResult.count();
}

QSqlRelationalTableModel* SearchDB::webpageTable() const
{
    return _webpage.data();
}

TabsModel* SearchDB::searchResult()
{
    return &_searchResult;
}
