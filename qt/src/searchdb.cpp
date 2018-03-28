#include <QSqlDatabase>
#include <QSqlDriver>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QDebug>
#include <QCoreApplication>
#include <QSqlRelationalTableModel>
#include <algorithm>
#include "searchdb.h"
#include "filemanager.h"
#include "webpage.h"
#include "qmlregister.h"

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
    _webpageTable.setTable("webpage");
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


bool SearchDB::addWebpage(const Webpage_& webpage)
{
    QSqlRecord record;
    record.setValue("url", webpage->url());
    return _webpageTable.insertRecord(-1, record);
}

void SearchDB::removeWebpage(const QString& url)
{
    const QString query = "url = " + url;
    _webpageTable.setFilter(query);
    _webpageTable.removeRow(0);
    _webpageTable.submitAll();
}

Webpage_ SearchDB::findWebpage(const QString& url)
{
    const QString query = "url = " + url;
    _webpageTable.setFilter(query);
    QSqlRecord record = _webpageTable.record(0);
    Webpage_ webpage = Webpage::create(url);
    return webpage;
}

QList<Webpage_> SearchDB::search(const QString& word) const
{
    int upper = std::min(10, _webpageTable.rowCount());
    QList<Webpage_> pages;
    for (int i = 0; i < upper; i++) {
        QSqlRecord record = _webpageTable.record(0);
        QString url = record.value("url").value<QString>();
        Webpage_ page = Webpage::create(url);
        pages << page;
    }
    return pages;
}
