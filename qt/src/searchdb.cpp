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
    return execMany(s.split("\n"));
}

bool SearchDB::execMany(const QStringList& lines)
{
    for (const QString l : lines) {
        qDebug() << "SearchDB::execMany" << l;
        QSqlQuery query = _db.exec(l);
        QSqlError error = query.lastError();
        if (error.isValid()) {
            qDebug() << "SearchDB::execMany error when executing" << l << error.type() << error.text();
            return false;
        }
    }
    //    search(_currentWord);
    return true;
}

bool SearchDB::updateWebpage(const QString& url, const QString& property, const QVariant& value)
{
    qDebug() << "SearchDB::updateWebpage " << url << property << value;
    _webpage->setFilter("url = '" + url + "'");
    _webpage->select();
    if (_webpage->rowCount() == 0) {
        qDebug() << "SearchDB::updateWebpage didn't find the webpage" << url;
        return false;
    }
    QSqlRecord record = _webpage->record(0);
    record.setValue(property, value);
    if (! _webpage->setRecord(0, record)) {
        qDebug() << "SearchDB::updateWebpage failed" << url;
        return false;
    }
    _webpage->submitAll();
    //    search(_currentWord);
    return true;
}

bool SearchDB::addSymbols(const QString& url, const QVariantMap& symbols)
{

    qDebug() << "SearchDB::addSymbols " << url << symbols;
    _webpage->setFilter("url = '" + url + "'");
    _webpage->select();
    if (_webpage->rowCount() == 0) {
        qDebug() << "SearchDB::addSymbols didn't find the webpage";
        return false;
    }
    const QSqlRecord wpRecord = _webpage->record(0);
    for (auto i = symbols.keyBegin();
         i != symbols.keyEnd();
         i++) {
        QString hash = (*i);
        QString text = symbols[hash].value<QString>();
        _symbol->setFilter("hash = '" + hash + "' AND text = '"+ text +"'");
        _symbol->select();
        QSqlRecord syRecord;
        if (_symbol->rowCount() == 0) {
            qDebug() << "SearchDB::addSymbols create new symbol" << (*i);
            syRecord = _symbol->record();
            syRecord.setValue("hash", hash);
            syRecord.setValue("text", text);
            if (! _symbol->insertRecord(-1, syRecord)) {
                qDebug() << _symbol->lastError();
                continue;
            }
        }
        _symbol->submitAll();
        _symbol->select();
        if (_symbol->rowCount() == 0) {
            qDebug() << "SearchDB::addSymbols this should not have happened"
                     << _symbol->lastError();
            continue;
        }
        syRecord = _symbol->record(0);
        QSqlRecord rel = _webpage_symbol->record();
        rel.setValue("symbol", syRecord.value("id"));
        rel.setValue("webpage", wpRecord.value("id"));
        if (! _webpage_symbol->insertRecord(-1, rel)) {
            qDebug() << _webpage_symbol->lastError();
            continue;
        }
    }
    return _webpage_symbol->submitAll();
}

bool SearchDB::addWebpage(const QString& url)
{
    qDebug() << "SearchDB::addWebpage" << url;
    QSqlRecord wpRecord = _webpage->record();
    wpRecord.setValue("url", url);
    wpRecord.setValue("temporary", true);
    wpRecord.setValue("crawling", false);
    wpRecord.setValue("crawled", false);
    if (! (_webpage->insertRecord(-1, wpRecord)
           && _webpage->submitAll()))
    {
        qDebug() << "ERROR: SearchDB::addWebpage failed!" << _webpage->lastError();
        return false;
    };
    //    search(_currentWord);
    return true;
}

bool SearchDB::removeWebpage(const QString& url)
{
    qDebug() << "SearchDB::removeWebpage " << url;
    _webpage->setFilter("url = '" + url + "'");
    _webpage->select();
    if (_webpage->rowCount() == 0) {
        qDebug() << "SearchDB::removeWebpage didn't find the webpage";
        return false;
    }
    const QSqlRecord wpr = _webpage->record(0);
    _webpage_symbol->setFilter("webpage = '" + wpr.value("id").value<QString>() + "'");
    qDebug() << "SearchDB::removeWebpage removing _webpage_symbol where" << "webpage = '" + wpr.value("id").value<QString>() + "'";
    _webpage_symbol->select();
    if (_webpage_symbol->rowCount() > 0) {
        if (! _webpage_symbol->removeRows(0, _webpage_symbol->rowCount())) {
            qDebug() << "SearchDB::removeWebpage couldn't remove row from _webpage_symbol"
                     << _webpage_symbol->lastError();
            goto whenFailed;
        }
    }
    if (! _webpage->removeRows(0, _webpage->rowCount())) {
        qDebug() << "SearchDB::removeWebpage couldn't remove row from _webpage"
                 << _webpage->lastError();
        goto whenFailed;
    }
    _webpage->submitAll();
    return _webpage_symbol->submitAll();
whenFailed:
    qDebug() << "SearchDB::removeWebpage failed";
    _webpage->revertAll();
    _webpage_symbol->revertAll();
    return false;
}

Webpage_ SearchDB::findWebpage_(const QString& url) const
{
    qDebug() << "SearchDB::findWebpage_ " << url;
    const QString query = "url = '" + url + "'";
    _webpage->setFilter(query);
    _webpage->select();
    if (_webpage->rowCount() == 0) {
        qDebug() << "ERROR: SearchDB::findWebpage_ not found!" << url;
        return QSharedPointer<Webpage>(nullptr);
    }
    QSqlRecord r = _webpage->record(0);
    qDebug() << "SearchDB::findWebpage_ found " << r;
    Webpage_ wp = Webpage::create(url);
    wp->setTitle(r.value("title").value<QString>());
    wp->setTemporary(r.value("temporary").value<bool>());
    wp->setCrawling(r.value("crawling").value<bool>());
    wp->setCrawled(r.value("crawled").value<bool>());
    return wp;
}

QVariantMap SearchDB::findWebpage(const QString& url) const
{
    Webpage_ p = SearchDB::findWebpage_(url);
    if (p.isNull()) {
        qDebug() << "ERROR: SearchDB::findWebpage not found!" << url;
        return QVariantMap();
    }
    return p->toQVariantMap();

}

bool SearchDB::setBookmarked(const QString& url, bool bk)
{
    return updateWebpage(url, "temporary", ! bk);
}

bool SearchDB::bookmarked(const QString& url) const
{
    Webpage_ w = findWebpage_(url);
    if (w.isNull()) {
        return false;
    }
    return ! w->temporary();
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
        _webpage->setFilter("temporary = 0");
        _webpage->select();
        int upper = std::min(100, _webpage->rowCount());
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
                "SELECT DISTINCT webpage.id, url, title, hash, text FROM webpage" +
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
        q += " LIMIT 50";
        qDebug() << "SearchDB::search" << q;
        QSqlQuery r = _db.exec(q);
        if (r.lastError().isValid()) {
            qDebug() << "SearchDB::search failed" << r.lastError();
            return;
        }
        while (r.next()) {
            QSqlRecord record = r.record();
            QString url = record.value("url").value<QString>();
            QStringList path = url.split(QRegularExpression("/"), QString::SkipEmptyParts);
            QString last = path.length() > 0 ? path[path.length() - 1] : "";
            QString title = record.value("title").value<QString>();
            QString symbol = record.value("text").value<QString>();
            QString hash = record.value("hash").value<QString>();
            QString display =
                    (symbol.length() > 0 ? "@"+symbol+"  " : "") +
                    (hash.length() > 0 ? "#"+hash+"  " : "") +
                    (title.length() > 0 ? "\""+title+"\"" : "") +
                    (symbol.length() == 0 && hash.length() == 0 && title.length() == 0 ? "/"+last+"  " : "") +
                    (symbol.length() == 0 && hash.length() == 0 && title.length() == 0 ? ""+url+"  " : "");
            _searchResult.insertTab(0, url + (hash.length()>0 ? ("#"+hash) : ""));
            _searchResult.updateTab(0, "title", display);
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
