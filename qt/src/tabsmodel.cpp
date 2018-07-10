#include <QString>
#include <QObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QDebug>
#include <QAbstractListModel>
#include <QQmlEngine>
#include "qmlregister.h"
#include "tabsmodel.h"

TabsModel::TabsModel(QObject *parent) : QAbstractListModel(parent)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

int TabsModel::count() const
{
    return _tabs.length();
}

QVariant TabsModel::at(int i) const
{
    if (i < 0 || i >= _tabs.length()) {
        return QVariant();
    }
    QVariant v;
    v.setValue(_tabs[i].data());
    return v;
}

Webpage_ TabsModel::webpage_(int i) const
{
    if (i < 0 || i >= _tabs.length()) {
        return Webpage_(nullptr);
    }
    return _tabs[i];
}

void TabsModel::replaceModel(const Webpage_List& pages)
{
    emit beginResetModel();
    _tabs = pages;
    emit endResetModel();
    emit countChanged();
}

void TabsModel::insertWebpage(int idx, const Webpage_ page)
{
    if (idx < 0 || idx > _tabs.count()) { return; }
    emit beginInsertRows(QModelIndex(), idx, idx);
    _tabs.insert(idx, page);
    _tabs[idx] = page;
    emit endInsertRows();
    emit countChanged();
}

void TabsModel::insertTab(int idx, const QString& uri)
{
    qInfo() << "TabsModel::insertTab" << idx << uri;
    Webpage_ page = Webpage_::create(uri);
    insertWebpage(idx, page);
}

void TabsModel::insertTab(int idx, const QVariantMap& map)
{
    qInfo() << "TabsModel::insertTab" << idx << map;
    Webpage_ page = Webpage_::create(map);
    insertWebpage(idx, page);
}

void TabsModel::updateTab(int index, QString property, QVariant value)
{
    qInfo() << "TabsModel::updateTab:" << property << value;
    Webpage_ page = _tabs[index];
    QByteArray ba = property.toLocal8Bit();
    const char *str = ba.data();
    QVariant current = page.data()->property(str);
    if (value == current) { return; }
    page.data()->setProperty(str, value);
    if (property == "title" || property == "uri") {
        page->set_display(page->title().length() > 0 ? page->title() : page->uri());
        page->set_expanded_display(QStringList{page->title().length() > 0 ? page->title() : page->uri()});
    }
    QModelIndex i = TabsModel::index(index);
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

bool TabsModel::removeTab(const QString &uri)
{
    int i = findTab(uri);
    return removeTab(i);
}

int TabsModel::findTab(const QString& uri) {
    int i = 0;
    for (Webpage_ tab : _tabs) {
        if (tab->uri() == uri) {
            return i;
        }
        i++;
    }
    return -1;
}

void TabsModel::saveTabs(void) {
    qInfo() << "TabsModel::saveTabs";
    QJsonArray tabs;
    for (Webpage_ tab : _tabs) {
        tabs << tab->toQJsonObject();
    }
    QJsonDocument doc(tabs);
    FileManager::writeDataFileB("open.json", doc.toJson());
}

void TabsModel::loadTabs(void) {
    QByteArray contents = QMLRegister::fileManager->readDataFileB("open.json");
    QJsonDocument doc = QJsonDocument::fromJson(contents);
    QJsonArray jarr = doc.array();
    qInfo() << jarr;
    qInfo() << "TabsModel::loadTabs";
    emit beginResetModel();
    _tabs.clear();
    for (QJsonValue jval : jarr) {
        QJsonObject jobj = jval.toObject();
        Webpage_ page_ = Webpage::fromQJsonObject(jobj);
        _tabs << page_;
    }
    emit endResetModel();
    emit countChanged();
}

QVariant TabsModel::data(const QModelIndex& idx, int role) const
{
    Q_UNUSED(role)
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
    Q_UNUSED(parent)
    return _tabs.length();
}

QHash<int, QByteArray> TabsModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[0] = "model";
    return roles;
}

void TabsModel::clear() {
    emit beginResetModel();
    _tabs.clear();
    emit endResetModel();
    emit countChanged();
}
