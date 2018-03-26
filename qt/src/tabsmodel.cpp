#include <QString>
#include <QObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QUrl>
#include <QDebug>
#include <QAbstractListModel>
#include "qmlregister.h"
#include "tabsmodel.h"

TabsModel::TabsModel(QObject *parent) : QAbstractListModel(parent)
{

}

int TabsModel::count()
{
    return _tabs.length();
}

Webpage* TabsModel::tab(int i)
{
    return _tabs[i].data();
}

//QVariantList TabsModel::tabs() const
//{
//    QVariantList ls;
//    for (Webpage_ tab : _tabs) {
//        QVariant v;
//        v.setValue(tab.data());
//        ls << v;
//    }
//    return ls;
//}

void TabsModel::insertTab(int i, QString url, QString title, QString html)
{
    Webpage* page = new Webpage(url);
    QVariant v;
    v.setValue(page);
    insertRow(i);
    QModelIndex idx = TabsModel::index(i);
    setData(idx, v);
}

void TabsModel::updateTab(int index, QString property, QVariant value)
{
    Webpage_ page = _tabs[index];
    QByteArray ba = property.toLocal8Bit();
    const char *str = ba.data();
    page.data()->setProperty(str, value);
    QModelIndex i = TabsModel::index(index);
//    QVector<int> roles;
//    roles << 0;
    emit dataChanged(i,i);
}

int TabsModel::appendTab(QString url, QString title, QString html)
{
    Webpage_ page = QSharedPointer<Webpage>::create(url, title, html);
    _tabs.append(page);
    emit tabsChanged();
    int idx = _tabs.length() - 1;
    emit tabInserted(idx, page.data());
    return idx;
}

void TabsModel::removeTab(int idx)
{
    removeRow(idx);
}

int TabsModel::findTab(QString url) {
    int i = 0;
    for (Webpage_ tab : _tabs) {
        if (tab->url() == url) {
            return i;
        }
        i++;
    }
    return -1;
}

void TabsModel::saveTabs(void) {
    QJsonArray tabs;
    for (Webpage_ tab : _tabs) {
        tabs << tab->toQJsonObject();
    }
    QJsonDocument doc(tabs);
    QMLRegister::fileManager->saveFile("openTabs.json", doc.toJson());
}

void TabsModel::loadTabs(void) {
    QByteArray contents = QMLRegister::fileManager->readFileB("openTabs.json");
    QJsonDocument doc = QJsonDocument::fromJson(contents);
    QJsonArray jarr = doc.array();
    qDebug() << jarr;
    _tabs.clear();
    int idx = 0;
    qDebug() << "loadTabs: " << endl;
    for (QJsonValue jval : jarr) {
        QJsonObject jobj = jval.toObject();
        Webpage_ page_ = Webpage::fromQJsonObject(jobj);
        Webpage* page = page_.data();
        _tabs << Webpage::fromQJsonObject(jobj);
        emit tabInserted(idx, page);
        idx++;
    }
    emit tabsChanged();
}

void TabsModel::syncTabs(QVariantList tabs) {
    _tabs.clear();
    int idx = 0;
    for (QVariant tab : tabs) {
        Webpage* page = tab.value<Webpage*>();
        _tabs << QSharedPointer<Webpage>(page);
        emit tabInserted(idx, page);
        idx++;
    }
    emit tabsChanged();
}

QVariant TabsModel::data(const QModelIndex& idx, int role) const
{
    int row = idx.row();
    if (row < 0 || row >=_tabs.length()) {
        return QVariant();
    }
    Webpage_ p = _tabs[row];
    QVariant v;
    v.setValue(p.data());
    return v;
}

int TabsModel::rowCount(const QModelIndex &parent) const
{
    return _tabs.length();
}

bool TabsModel::setData(const QModelIndex &i, const QVariant &v, int role)
{
    if (i.row() >= _tabs.length()) { return false; }
    Webpage_ sptr = QSharedPointer<Webpage>(v.value<Webpage*>());
    _tabs[i.row()] = sptr;
    emit dataChanged(i,i);
    return true;
}

Qt::ItemFlags TabsModel::flags(const QModelIndex &index) const
{
    return Qt::ItemIsSelectable
            | Qt::ItemIsEditable
            | Qt::ItemIsEditable
            | Qt::ItemNeverHasChildren;
}

bool TabsModel::removeRows(int row, int count, const QModelIndex &parent)
{
    if (row >= _tabs.length()) { return false; }
    emit beginRemoveRows(parent, row, row);
    _tabs.removeAt(row);
    emit endRemoveRows();
    return true;
}

bool TabsModel::insertRows(int row, int count, const QModelIndex &parent)
{
    if (row > _tabs.length()) { return false; }
    emit beginInsertRows(parent, row, row);
    Webpage_ page = QSharedPointer<Webpage>(nullptr);
    _tabs.insert(row, page);
    emit endInsertRows();
    return true;
}

QHash<int, QByteArray> TabsModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[0] = "model";
    return roles;
}
