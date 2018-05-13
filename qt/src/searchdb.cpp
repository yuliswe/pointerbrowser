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
    qDebug() << "libraryPaths:" << QCoreApplication::libraryPaths () << endl;
    _db = QSqlDatabase::addDatabase("QSQLITE");
    _dbPath = FileManager::dataPath() + "search.db";
    qDebug() << "SearchDB: connecting" << _dbPath << endl;
    _db.setDatabaseName(_dbPath);
    if (! _db.open()) {
        qDebug() << "SearchDB Error: connection with database failed";
        return false;
    }
    qDebug() << "SearchDB: connection ok";
    QString script = FileManager::readQrcFileS("searchDB.setup");
    QStringList lines = script.split(";");
    execMany(lines);
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
    QStringList ls;
    ls << "DELETE FROM webpage_symbol WHERE webpage IN (SELECT id FROM webpage WHERE temporary = 1);"
       << "DELETE FROM webpage WHERE temporary = 1;"
       << "DELETE FROM symbol WHERE id NOT IN (SELECT symbol FROM webpage_symbol);";
    if (! execMany(ls)) {
        qDebug() << "SearchDB::disconnect failed";
    }
    _db.close();
    qDebug() << "SearchDB: disconnected";
}

bool SearchDB::execMany(const QStringList& lines)
{
    for (const QString l : lines) {
        QSqlQuery query = _db.exec(l);
        QSqlError error = query.lastError();
        if (error.isValid()) {
            qDebug() << "SearchDB::execMany error when executing" << l << error.type() << error.text();
            return false;
        }
    }
    return true;
}

bool SearchDB::updateWebpage(const QString& url, const QString& property, const QVariant& value)
{
    qDebug() << "SearchDB::updateWebpage " << url << property << value;
    _webpage->setFilter("url = '" + url + "'");
    _webpage->select();
    if (_webpage->rowCount() == 0) {
        qDebug() << "SearchDB::setTemporary didn't find the webpage";
        return false;
    }
    QSqlRecord record = _webpage->record(0);
    record.setValue(property, value);
    if (! _webpage->setRecord(0, record)) {
        qDebug() << "SearchDB::setTemporary failed";
        return false;
    }
    _webpage->submitAll();
    search(_currentWord);
    return true;
}

bool SearchDB::addSymbols(const QString& url, const QStringList& symbols)
{

    qDebug() << "SearchDB::addSymbols " << url << symbols;
    _webpage->setFilter("url = '" + url + "'");
    _webpage->select();
    if (_webpage->rowCount() == 0) {
        qDebug() << "SearchDB::addSymbols didn't find the webpage";
        return false;
    }
    const QSqlRecord wpRecord = _webpage->record(0);
    for (QString s : symbols) {
        _symbol->setFilter("symbol = '" + s + "'");
        _symbol->select();
        QSqlRecord syRecord;
        if (_symbol->rowCount() == 0) {
            qDebug() << "SearchDB::addSymbols create new symbol" << s;
            syRecord = _symbol->record();
            syRecord.setValue("symbol", s);
            if (! _symbol->insertRecord(-1, syRecord)) {
                goto addSymbolsFailed;
            }
            _symbol->submitAll();
        }
        _symbol->select();
        if (_symbol->rowCount() == 0) {
            qDebug() << "SearchDB::addSymbols this should not have happened";
            goto addSymbolsFailed;
        }
        syRecord = _symbol->record(0);
        QSqlRecord rel = _webpage_symbol->record();
        rel.setValue("symbol", syRecord.value("id"));
        rel.setValue("webpage", wpRecord.value("id"));
        if (! _webpage_symbol->insertRecord(-1, rel)) {
            goto addSymbolsFailed;
        }
    }
    return _webpage_symbol->submitAll();

addSymbolsFailed:
    qDebug() << "SearchDB::addSymbols failed";
    _symbol->revertAll();
    _webpage_symbol->revertAll();
    return false;
}

bool SearchDB::addWebpage(const QString& url)
{
    qDebug() << "SearchDB::addWebpage " << url;
    QSqlRecord wpRecord = _webpage->record();
    wpRecord.setValue("url", url);
    wpRecord.setValue("temporary", true);
    if (! _webpage->insertRecord(-1, wpRecord)) {
        return false;
    };
    _webpage->submitAll();
    search(_currentWord);
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

Webpage_ SearchDB::findWebpage(const QString& url) const
{
    qDebug() << "SearchDB::findWebpage " << url;
    const QString query = "url = '" + url + "'";
    _webpage->setFilter(query);
    _webpage->select();
    if (_webpage->rowCount() == 0) {
        return QSharedPointer<Webpage>(nullptr);
    }
    QSqlRecord r = _webpage->record(0);
    qDebug() << "SearchDB::findWebpage found " << r;
    Webpage_ wp = Webpage::create(url);
    wp->setTitle(r.value("title").value<QString>());
    wp->setTemporary(r.value("temporary").value<bool>());
    return wp;
}

bool SearchDB::isBookmarked(const QString& url) const
{
    Webpage_ w = findWebpage(url);
    if (w.isNull()) {
        return false;
    }
    return ! w->temporary();
}

bool SearchDB::hasWebpage(const QString& url) const
{
    return findWebpage(url).data() != nullptr;
}

void SearchDB::search(const QString& word)
{
    qDebug() << "SearchDB::search" << word;
    _currentWord = word;
    if (word == "") {
        _webpage->setFilter("temporary = 0");
        _webpage->select();
        int upper = std::min(100, _webpage->rowCount());
        _searchResult.clear();
        for (int i = 0; i < upper; i++) {
            QSqlRecord record = _webpage->record(i);
            QString url = record.value("url").value<QString>();
            QString title = record.value("title").value<QString>();
            _searchResult.insertTab(0, url);
            _searchResult.updateTab(0, "title", title);
        }
    } else {
        QStringList ws = word.split(QRegularExpression(" "));
        QStringList qsl;
        for (QString w : ws) {
            qsl << QString("SELECT DISTINCT webpage.id, webpage.url, webpage.title from webpage ") +
                   "INNER JOIN webpage_symbol ON webpage.id = webpage_symbol.webpage " +
                   "INNER JOIN symbol ON symbol.id = webpage_symbol.symbol " +
                   "WHERE INSTR(LOWER(symbol.symbol),LOWER('" + w + "')) > 0";
        }
        QString qs = qsl.join(" INTERSECT ") + ";";
        qDebug() << "SearchDB::search" << qs;
        QSqlQuery q = _db.exec(qs);
        if (q.lastError().isValid()) {
            qDebug() << "SearchDB::search failed" << q.lastError();
            return;
        }
        _searchResult.clear();
        while (q.next()) {
            QSqlRecord record = q.record();
            QString url = record.value("url").value<QString>();
            QString title = record.value("title").value<QString>();
            _searchResult.insertTab(0, url);
            _searchResult.updateTab(0, "title", title);
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
