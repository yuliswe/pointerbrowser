#include "tabscontroller.h"
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

TabsController::TabsController()
{
    reset();
}

void TabsController::newTab(TabState state,
                            const QString& url,
                            bool switchToView,
                            bool usePrevious)
{
    int idx = 0;
    if (state == TabState::Open) {
        if (usePrevious) {
            idx = _open_tabs->findTab(url);
            if (idx == -1) {
                _open_tabs->insertTab(0, url);
            }
        } else {
            _open_tabs->insertTab(0, url);
        }
    } else if (state == TabState::Preview) {
        _preview_tabs->insertTab(0, url);
    }
    if (switchToView) { viewTab(state, idx); }
}

// switch view
void TabsController::viewTab(TabState state, int i)
{
    Webpage* page = nullptr;
    if (state == TabState::Open) {
        page = _open_tabs->webpage_(i).data();
    } else if (state == TabState::Preview) {
        page = _preview_tabs->webpage_(i).data();
    }
    Q_ASSUME(page);
    set_current_index(i);
    set_current_state(state);
    set_current_webpage(page);
}

void TabsController::closeTab(TabState state, int index)
{
    if (state == TabState::Open) {
        _preview_tabs.clear();
        if (current_index() == index) {
            // when removing current tab
            // if there's one after, open that
            if (index + 1 < _open_tabs->count()) {
                _open_tabs->removeTab(index);
                viewTab(TabState::Open, index);
            } // if there's one before, open that
            else if (index >= 1) {
                _open_tabs->removeTab(index);
                viewTab(TabState::Open, index - 1);
            } // if this is the only one
            else {
                _open_tabs->removeTab(index);
                reset();
            }
        } else if (current_index() > index) {
            _open_tabs->removeTab(index);
            viewTab(TabState::Open, current_index() - 1);
        } else {
            _open_tabs->removeTab(index);
        }
    } else if (state == TabState::Preview) {
        if (_open_tabs->count() > 0) {
            viewTab(TabState::Open, 0);
        } else {
            reset();
        }
    }
}

void TabsController::closeTab(TabState state, const QString& url)
{
    int idx = -1;
    if (state == TabState::Open) {
        idx = _open_tabs->findTab(url);
    } else if (state == TabState::Preview) {
        idx = _preview_tabs->findTab(url);
    }
    return closeTab(state, idx);
}

void TabsController::reset()
{
    set_current_index(-1);
    set_current_state(TabState::Empty);
    set_current_webpage(nullptr);
}

