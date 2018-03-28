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
    _webpageTable->setEditStrategy(QSqlTableModel::OnFieldChange);
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
    qDebug() << record;
    qDebug() << _webpageTable->insertRecord(-1, record);
    return _webpageTable->submitAll();
}

void SearchDB::removeWebpage(const QString& url)
{
    const QString query = "url = " + url;
    _webpageTable->setFilter(query);
    _webpageTable->removeRow(0);
    _webpageTable->submitAll();
}

Webpage_ SearchDB::findWebpage(const QString& url)
{
    const QString query = "url = " + url;
    _webpageTable->setFilter(query);
    QSqlRecord record = _webpageTable->record(0);
    Webpage_ webpage = Webpage::create(url);
    return webpage;
}

void SearchDB::search(const QString& word)
{
    int upper = std::min(10, _webpageTable->rowCount());
    _searchResult.clear();
    for (int i = 0; i < upper; i++) {
        QSqlRecord record = _webpageTable->record(0);
        QString url = record.value("url").value<QString>();
//        Webpage_ page = Webpage::create(url);
        _searchResult.insertTab(0, url, "", "");
    }
    emit searchResultChanged();
}

QSqlRelationalTableModel* SearchDB::webpageTable() const
{
    return _webpageTable.data();
}

TabsModel* SearchDB::searchResult()
{
    return &_searchResult;
}
