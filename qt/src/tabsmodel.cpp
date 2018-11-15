#include <QtCore/QtCore>
#include "global.hpp"
#include "tabsmodel.hpp"

TabsModel::TabsModel(QObject *parent) : QAbstractListModel(parent)
{
//    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
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
    v.setValue(_tabs[i].get());
    return v;
}

Webpage_ TabsModel::webpage_(int i) const
{
    if (i < 0 || i >= _tabs.length()) {
        qCritical(WebpageLogging) << "array index out of range" << i << "/" << count();
        return shared<Webpage>();
    }
    return _tabs[i];
}

void TabsModel::replaceModel(const Webpage_List& new_pages)
{
    emit beginResetModel();
    for (int i = _tabs.count() - 1; i >= 0; i--) {
        if (_tabs[i]->associated_container() == this) {
            _tabs[i]->set_associated_container(nullptr);
            _tabs[i]->disconnect();
        }
    }
    _tabs = new_pages;
    for (int i = _tabs.count() - 1; i >= 0; i--) {
        _tabs[i]->set_associated_container(this);
    }
    emit endResetModel();
    emit countChanged();
}

void TabsModel::insertWebpage_(int idx, const Webpage_ page)
{
    if (idx < 0 || idx > _tabs.count()) { return; }
    emit beginInsertRows(QModelIndex(), idx, idx);
    page->set_associated_container(this);
    _tabs.insert(idx, page);
    _tabs[idx] = page;
    emit endInsertRows();
    emit countChanged();
}

//void TabsModel::insertTab(int idx, Url const& uri)
//{
//    Webpage_ page = shared<Webpage>(uri);
//    insertWebpage_(idx, page);
//}

bool TabsModel::removeTab(int row)
{
    if (row >= _tabs.length()) { return false; }
    emit beginRemoveRows(QModelIndex(), row, row);
    if (_tabs[row]->associated_container() == this) {
        _tabs[row]->set_associated_container(nullptr);
        _tabs[row]->disconnect();
    }
    _tabs.removeAt(row);
    emit endRemoveRows();
    emit countChanged();
    return true;
}

bool TabsModel::removeTab(const Url &uri)
{
    int i = findTab(uri);
    return removeTab(i);
}

int TabsModel::findTab(Url const& uri) {
    int i = 0;
    for (Webpage_ tab : _tabs) {
        if (tab->url() == uri) {
            return i;
        }
        i++;
    }
    return -1;
}

int TabsModel::findTab(Webpage_ w) {
    int i = 0;
    for (Webpage_ tab : _tabs) {
        if (tab == w) {
            return i;
        }
        i++;
    }
    return -1;
}

int TabsModel::findTabByRefOrUrl(Webpage_ w) {
    int i = 0;
    for (Webpage_ tab : _tabs) {
        if (tab == w || w->url() == tab->url()) {
            return i;
        }
        i++;
    }
    return -1;
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
    v.setValue(p.get());
    return v;
}

int TabsModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return _tabs.length();
}

void TabsModel::moveTab(int target, int moveBefore)
{
    QModelIndex parent;
    moveRows(parent, target, target, parent, moveBefore);
    emit_tf_tab_moved(target, moveBefore);
}

bool TabsModel::moveRows(const QModelIndex &sourceParent, int sourceRow, int count, const QModelIndex &destinationParent, int destinationChild)
{
    if (! beginMoveRows(sourceParent, sourceRow, count, destinationParent, destinationChild))
    {
        return false;
    }
    Webpage_ row = _tabs.at(sourceRow);
    _tabs.insert(destinationChild, row);
    if (destinationChild <= sourceRow) {
        _tabs.removeAt(sourceRow + 1);
    } else {
        _tabs.removeAt(sourceRow);
    }
    emit endMoveRows();
    return true;
}

void TabsModel::clear() {
    if (_tabs.isEmpty()) { return; }
    emit beginResetModel();
    for (int i = _tabs.count() - 1; i >= 0; i--) {
        if (_tabs[i]->associated_container() == this) {
            _tabs[i]->set_associated_container(nullptr);
            _tabs[i]->disconnect();
        }
    }
    _tabs.clear();
    emit endResetModel();
    emit countChanged();
}

