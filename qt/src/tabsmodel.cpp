#include <QString>
#include <QObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QUrl>
#include <QDebug>
#include <QAbstractListModel>
#include <QQmlEngine>
#include "qmlregister.h"
#include "tabsmodel.h"

TabsModel::TabsModel(QObject *parent) : QAbstractListModel(parent)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

int TabsModel::count()
{
    return _tabs.length();
}

Webpage* TabsModel::at(int i)
{
    return _tabs[i].data();
}

void TabsModel::insertTab(int idx, QString url, QString title, QString html)
{
    emit beginInsertRows(QModelIndex(), idx, idx);
    Webpage_ page = Webpage::create(url);
    QVariant v;
    v.setValue(page.data());
    _tabs.insert(idx, page);
    _tabs[idx] = page;
    emit endInsertRows();
    emit countChanged();
}

void TabsModel::updateTab(int index, QString property, QVariant value)
{
    Webpage_ page = _tabs[index];
    QByteArray ba = property.toLocal8Bit();
    const char *str = ba.data();
    QVariant current = page.data()->property(str);
    qDebug() << "TabsModel::updateTab:" << property << "from" << current << "to" << value << (value == current);
    if (value == current) { return; }
    page.data()->setProperty(str, value);
    QModelIndex i = TabsModel::index(index);
    //    QVector<int> roles;
    //    roles << 0;
    emit dataChanged(i,i);
}


bool TabsModel::removeTab(int row)
{
    if (row >= _tabs.length()) { return false; }
    emit beginRemoveRows(QModelIndex(), row, row);
    _tabs.removeAt(row);
    emit endRemoveRows();
    emit countChanged();
    return true;
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
    qDebug() << "TabsModel::saveTabs";
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
    int cnt = jarr.size();
    emit beginInsertRows(QModelIndex(), 0, cnt - 1);
    for (QJsonValue jval : jarr) {
        QJsonObject jobj = jval.toObject();
        Webpage_ page_ = Webpage::fromQJsonObject(jobj);
        Webpage* page = page_.data();
        _tabs << page_;
        //        emit tabInserted(idx, page);
        idx++;
    }
    emit endInsertRows();
    emit countChanged();
}

//void TabsModel::syncTabs(QVariantList tabs) {
//    _tabs.clear();
//    int idx = 0;
//    for (QVariant tab : tabs) {
//        Webpage* page = tab.value<Webpage*>();
//        _tabs << QSharedPointer<Webpage>(page);
//        emit tabInserted(idx, page);
//        idx++;
//    }
//    emit tabsChanged();
//}

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

//bool TabsModel::setData(const QModelIndex &i, const QVariant &v, int role)
//{
//    if (i.row() >= _tabs.length()) { return false; }
//    Webpage_ sptr = QSharedPointer<Webpage>(v.value<Webpage*>());
//    _tabs[i.row()] = sptr;
//    emit dataChanged(i,i);
//    return true;
//}

//Qt::ItemFlags TabsModel::flags(const QModelIndex &index) const
//{
//    return Qt::ItemIsSelectable
//            | Qt::ItemIsEditable
//            | Qt::ItemNeverHasChildren;
//}

//bool TabsModel::removeRows(int row, int count, const QModelIndex &parent)
//{
//    if (row >= _tabs.length()) { return false; }
//    emit beginRemoveRows(parent, row, row);
//    _tabs.removeAt(row);
//    emit endRemoveRows();
//    emit countChanged();
//    return true;
//}

//bool TabsModel::insertRows(int row, int count, const QModelIndex &parent)
//{
//    if (row > _tabs.length()) { return false; }
//    emit beginInsertRows(parent, row, row);
//    Webpage_ page = QSharedPointer<Webpage>(nullptr);
//    _tabs.insert(row, page);
//    emit endInsertRows();
//    emit countChanged();
//    return true;
//}

QHash<int, QByteArray> TabsModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[0] = "model";
    return roles;
}

void TabsModel::clear() {
    emit beginRemoveRows(QModelIndex(), 0, count());
    _tabs.clear();
    emit endRemoveRows();
    emit countChanged();
}
