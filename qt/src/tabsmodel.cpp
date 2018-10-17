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
        return Webpage_(nullptr);
    }
    return _tabs[i];
}

Webpage* TabsModel::webpage(int i) const
{
    return webpage_(i).get();
}

void TabsModel::replaceModel(const Webpage_List& pages)
{
//    clear();
//    if (pages.isEmpty()) { return; }
//    emit beginInsertRows(QModelIndex(), 0, pages.count() - 1);
    _tabs = pages;
//    int n = pages.length();
//    for (int i = 0; i < n; i++) {
//        Webpage* p = pages[i].get();
//        QObject::connect(p, &Webpage::dataChanged, [=]() {
//            QModelIndex d;
//            bool found = false;
//            for (int j = 0; j < count(); j++) {
//                if (webpage(j) == p) {
//                    d = TabsModel::index(j,j);
//                    found = true;
//                    break;
//                }
//            }
//            if (found) {
//                emit this->dataChanged(d,d);
//            }
//        });
//    }
    emit endResetModel();
//    emit endInsertRows();
    emit countChanged();
}

void TabsModel::insertWebpage_(int idx, const Webpage_ page)
{
    if (idx < 0 || idx > _tabs.count()) { return; }
    emit beginInsertRows(QModelIndex(), idx, idx);
    _tabs.insert(idx, page);
    _tabs[idx] = page;
//    Webpage* p = page.get();
//    QObject::connect(p, &Webpage::dataChanged, [=]() {
//        QModelIndex d;
//        bool found = false;
//        for (int j = 0; j < count(); j++) {
//            if (webpage(j) == p) {
//                d = TabsModel::index(j,j);
//                found = true;
//                break;
//            }
//        }
//        if (found) {
//            emit this->dataChanged(d,d);
//        }
//    });
    emit endInsertRows();
    emit countChanged();
}

void TabsModel::insertTab(int idx, Url const& uri)
{
    Webpage_ page = shared<Webpage>(uri);
    insertWebpage_(idx, page);
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

int TabsModel::findTab(Webpage* w) {
    int i = 0;
    for (Webpage_ tab : _tabs) {
        if (tab.get() == w) {
            return i;
        }
        i++;
    }
    return -1;
}

//void TabsModel::saveTabs(void) {
//    qCInfo() << "TabsModel::saveTabs";
//    QJsonArray tabs;
//    for (Webpage_ tab : _tabs) {
//        tabs << tab->toQJsonObject();
//    }
//    QJsonDocument doc(tabs);
//    FileManager::writeDataFileB("open.json", doc.toJson());
//}

//void TabsModel::loadTabs(void) {
//    QByteArray contents = Global::fileManager->readDataFileB("open.json");
//    QJsonDocument doc = QJsonDocument::fromJson(contents);
//    QJsonArray jarr = doc.array();
//    qCInfo() << jarr;
//    qCInfo() << "TabsModel::loadTabs";
//    emit beginResetModel();
//    _tabs.clear();
//    for (QJsonValue jval : jarr) {
//        QJsonObject jobj = jval.toObject();
//        Webpage_ page_ = Webpage::fromQJsonObject(jobj);
//        _tabs << page_;
//    }
//    emit endResetModel();
//    emit countChanged();
//}

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

QHash<int, QByteArray> TabsModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[0] = "model";
    return roles;
}

void TabsModel::moveTab(int target, int moveBefore)
{
    QModelIndex parent;
    moveRows(parent, target, target, parent, moveBefore);
    emit_tf_tab_moved(target, moveBefore);
}

bool TabsModel::moveRows(const QModelIndex &sourceParent, int sourceRow, int count, const QModelIndex &destinationParent, int destinationChild)
{
//    if (sourceRow < 0 || destinationChild < 0
//            || sourceRow + count - 1 > _tabs.count()
//            || destinationChild + count - 1 > _tabs.count()
//            || (sourceRow == destinationChild && count == 1)) {
//        return false;
//    }
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
//Qt::ItemFlags TabsModel::flags(const QModelIndex &index) const
//{
//    return Qt::ItemIsEnabled | Qt::ItemIsSelectable | Qt::ItemIsDragEnabled | Qt::ItemIsDropEnabled;
//}

void TabsModel::clear() {
    if (_tabs.isEmpty()) { return; }
//    emit beginResetModel();
    emit beginRemoveRows(QModelIndex(), 0, _tabs.count() - 1);
    _tabs.clear();
//    emit endResetModel();
    emit endRemoveRows();
    emit countChanged();
}
