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
    _webpageTable = QSharedPointer<QSqlRelationalTableModel>::create(nullptr, _db);
    _webpageTable->setTable("webpage");
    _webpageTable->setEditStrategy(QSqlTableModel::OnManualSubmit);
    if (! _webpageTable->select()) {
        qDebug() << "cannot find table webpage";
    } else {
        qDebug() << "found table webpage";
    };
    emit webpageTableChanged();
    search("");
}

void SearchDB::disconnect() {
    _db.close();
    qDebug() << "SearchDB: disconnected";
}

bool SearchDB::execMany(const QStringList& lines)
{
    for (const QString l : lines) {
        QSqlQuery query = _db.exec(l);
        QSqlError error = query.lastError();
        if (error.isValid()) {
            qDebug() << "Error in searchDB.setup" << endl
                     << error.type() << " " << error.text() << endl;
            return false;
        }
    }
    return true;
}


bool SearchDB::addWebpage(const QString& url)
{
    QSqlRecord record = _webpageTable->record();
    record.setGenerated("id", true);
    record.setValue("url", url);
    qDebug() << "SearchDB::addWebpage " << record;
    qDebug() << _webpageTable->insertRecord(-1, record);
    if (_webpageTable->submitAll()) {
        search(_currentWord);
        return true;
    } else {
        return false;
    }
}

void SearchDB::removeWebpage(const QString& url)
{
    qDebug() << "SearchDB::removeWebpage " << url;
    const QString query = "url = '" + url + "'";
    _webpageTable->setFilter(query);
    int count = _webpageTable->rowCount();
    qDebug() << "SearchDB::removeWebpage " << count;
    _webpageTable->removeRows(0, count);
    _webpageTable->submitAll();
    qDebug() << "SearchDB::removeWebpage " << _webpageTable->rowCount();
    _webpageTable->select();
    search(_currentWord);
}

Webpage_ SearchDB::findWebpage(const QString& url) const
{
    qDebug() << "SearchDB::findWebpage " << url;
    const QString query = "url = '" + url + "'";
    _webpageTable->setFilter(query);
    //    _webpageTable->select();
    if (_webpageTable->rowCount() == 0) {
        return QSharedPointer<Webpage>(nullptr);
    }
    QSqlRecord record = _webpageTable->record(0);
    qDebug() << "SearchDB::findWebpage found " << record;
    Webpage_ webpage = Webpage::create(url);
    return webpage;
}

bool SearchDB::hasWebpage(const QString& url) const
{
    return findWebpage(url).data() != nullptr;
}

void SearchDB::search(const QString& word)
{
    _currentWord = word;
    if (word == "") {
        _webpageTable->setFilter("");
    }
    _webpageTable->select();
    int upper = std::min(10, _webpageTable->rowCount());
    _searchResult.clear();
    for (int i = 0; i < upper; i++) {
        QSqlRecord record = _webpageTable->record(i);
        qDebug() << "SearchDB::search " << record;
        QString url = record.value("url").value<QString>();
        //        Webpage_ page = Webpage::create(url);
        _searchResult.insertTab(0, url, "", "");
    }
}

QSqlRelationalTableModel* SearchDB::webpageTable() const
{
    return _webpageTable.data();
}

TabsModel* SearchDB::searchResult()
{
    return &_searchResult;
}
