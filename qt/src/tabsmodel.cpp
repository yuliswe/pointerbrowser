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

QVariant TabsModel::at(int i)
{
    QVariant v;
    v.setValue(_tabs[i].data());
    return v;
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
    emit beginInsertRows(QModelIndex(), idx, idx);
    _tabs.insert(idx, page);
    _tabs[idx] = page;
    emit endInsertRows();
    emit countChanged();
}

void TabsModel::insertTab(int idx, const QString& url)
{
    qDebug() << "TabsModel::insertTab" << idx << url;
    Webpage_ page = Webpage_::create(url);
    page->set_display(page->title().length() > 0 ? page->title() : page->url());
    page->set_expanded_display(QStringList{page->title().length() > 0 ? page->title() : page->url()});
    insertWebpage(idx, page);
}

void TabsModel::insertTab(int idx, const QVariantMap& map)
{
    qDebug() << "TabsModel::insertTab" << idx << map;
    Webpage_ page = Webpage_::create(map);
    page->set_display(page->title().length() > 0 ? page->title() : page->url());
    page->set_expanded_display(QStringList{page->title().length() > 0 ? page->title() : page->url()});
    insertWebpage(idx, page);
}

void TabsModel::updateTab(int index, QString property, QVariant value)
{
    qDebug() << "TabsModel::updateTab:" << property << value;
    Webpage_ page = _tabs[index];
    QByteArray ba = property.toLocal8Bit();
    const char *str = ba.data();
    QVariant current = page.data()->property(str);
    if (value == current) { return; }
    page.data()->setProperty(str, value);
    if (property == "title" || property == "url") {
        page->set_display(page->title().length() > 0 ? page->title() : page->url());
        page->set_expanded_display(QStringList{page->title().length() > 0 ? page->title() : page->url()});
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
        if (tab->open()) {
            tabs << tab->toQJsonObject();
        }
    }
    QJsonDocument doc(tabs);
    FileManager::writeDataFileB("open.json", doc.toJson());
}

void TabsModel::loadTabs(void) {
    QByteArray contents = QMLRegister::fileManager->readDataFileB("open.json");
    QJsonDocument doc = QJsonDocument::fromJson(contents);
    QJsonArray jarr = doc.array();
    qDebug() << jarr;
    qDebug() << "TabsModel::loadTabs";
    emit beginResetModel();
    _tabs.clear();
    for (QJsonValue jval : jarr) {
        QJsonObject jobj = jval.toObject();
        Webpage_ page_ = Webpage::fromQJsonObject(jobj);
        page_->_open = true;
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
