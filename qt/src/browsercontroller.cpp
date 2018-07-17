#include "browsercontroller.h"
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

BrowserController::BrowserController()
{
    showWelcomePage();
}

void BrowserController::newTab(TabState state,
                               const QString& uri,
                               WhenCreated newBehavior,
                               WhenExists whenExists)
{
    qInfo() << "BrowserController::newTab"
            << state
            << uri
            << newBehavior
            << whenExists;
    int idx = 0;
    if (state == TabStateOpen) {
        if (whenExists == WhenExists::WhenExistsViewExisting) {
            idx = _open_tabs->findTab(uri);
            if (idx == -1) {
                _open_tabs->insertTab(idx = 0, uri);
            }
        } else {
            _open_tabs->insertTab(idx = 0, uri);
        }
        if (newBehavior == WhenCreated::WhenCreatedSwitchToNew) {
            viewTab(state, idx);
        }
    } else if (state == TabStatePreview) {
        if (whenExists == WhenExists::WhenExistsViewExisting) {
            idx = _open_tabs->findTab(uri);
            if (idx > -1) {
                viewTab(TabStateOpen, idx);
                return;
            }
            idx = _preview_tabs->findTab(uri);
            if (idx == -1) {
                _preview_tabs->insertTab(idx = 0, uri);
            }
        } else {
            _preview_tabs->insertTab(idx = 0, uri);
        }
        if (newBehavior == WhenCreated::WhenCreatedSwitchToNew) {
            viewTab(state, idx);
        }
    }
}

// switch view
void BrowserController::viewTab(TabState state, int i)
{
    qInfo() << "BrowserController::viewTab" << i;
    if (i < 0) { i = 0; }
    Webpage* page = nullptr;
    if (state == TabStateOpen) {
        if (i >= _open_tabs->count()) { i = _open_tabs->count() - 1; }
        page = _open_tabs->webpage_(i).data();
        set_current_open_tab_index(i);
        set_current_tab_search_highlight_index(-1);
        set_current_preview_tab_index(-1);
    } else if (state == TabStatePreview) {
        if (i >= _preview_tabs->count()) { i = _preview_tabs->count() - 1; }
        page = _preview_tabs->webpage_(i).data();
        set_current_preview_tab_index(i);
        set_current_open_tab_index(-1);
    }
    Q_ASSUME(page);
    set_current_tab_state(state);
    set_current_tab_webpage(page);
    set_welcome_page_visible(false);
}

void BrowserController::closeTab(TabState state, int index)
{
    qInfo() << "BrowserController::closeTab" << state << index;
    if (state == TabStateOpen) {
        if (current_tab_state() == TabStateOpen) {
            if (current_open_tab_index() == index) {
                // when removing current tab
                // if there's one after, open that
                if (index + 1 < _open_tabs->count()) {
                    _open_tabs->removeTab(index);
                    viewTab(TabStateOpen, index);
                } // if there's one before, open that
                else if (index >= 1) {
                    _open_tabs->removeTab(index);
                    viewTab(TabStateOpen, index - 1);
                } // if this is the only one
                else {
                    _open_tabs->removeTab(index);
                    showWelcomePage();
                }
            } else if (current_open_tab_index() > index) {
                _open_tabs->removeTab(index);
                viewTab(TabStateOpen, current_open_tab_index() - 1);
            } else {
                _open_tabs->removeTab(index);
            }
            _preview_tabs->clear();
            set_current_tab_search_highlight_index(-1);
            set_current_preview_tab_index(-1);
        } else if (current_tab_state() == TabStatePreview) {
            _open_tabs->removeTab(index);
        }
    } else if (state == TabStatePreview) {
        if (_open_tabs->count() > 0) {
            viewTab(TabStateOpen, 0);
        } else {
            showWelcomePage();
        }
        // at the moment there is only one way to close a preview tab:
        // use ctrl+w when current view is a preview. in this case we
        // assume the user wants to close all preview tabs
        _preview_tabs->clear();
        set_current_tab_search_highlight_index(-1);
        set_current_preview_tab_index(-1);
    }
}

void BrowserController::closeTab(TabState state, const QString& uri)
{
    qInfo() << "BrowserController::closeTab" << state << uri;
    int idx = -1;
    if (state == TabStateOpen) {
        idx = _open_tabs->findTab(uri);
    } else if (state == TabStatePreview) {
        idx = _preview_tabs->findTab(uri);
    }
    return closeTab(state, idx);
}

void BrowserController::showWelcomePage()
{
    qInfo() << "BrowserController::showWelcomePage";
    set_current_open_tab_index(-1);
    set_current_preview_tab_index(-1);
    set_current_tab_search_highlight_index(-1);
    set_address_bar_load_progress(0);
    set_current_tab_state(TabStateEmpty);
    set_current_tab_webpage(nullptr);
    set_welcome_page_visible(true);
}

void BrowserController::setCurrentPageSearchState(CurrentPageSearchState state, QString words, int current, int count)
{
    qInfo() << "BrowserController::setCurrentPageSearchState"
            << words
            << state
            << current
            << count;
    set_current_page_search_state(state);
    set_current_page_search_text(words);
    set_current_page_search_count(count);
    set_current_page_search_current_index(count == 0 ? -1 : (current % count + count) % count);
    if (state == CurrentPageSearchStateClosed) {
        set_current_page_search_count_visible(false);
        set_current_page_search_focus(false);
        set_current_page_search_visible(false);
    } else if (state == CurrentPageSearchStateBeforeSearch) {
        set_current_page_search_visible(true);
        set_current_page_search_focus(true);
        set_current_page_search_count_visible(false);
    } else if (state == CurrentPageSearchStateAfterSearch) {
        set_current_page_search_count(count);
        set_current_page_search_count_visible(true);
    }
}

void BrowserController::loadLastOpen()
{
    QVariantList contents = QMLRegister::fileManager->readDataJsonFileA("open.json");
    qInfo() << "BrowserController::loadLastOpen";
    Webpage_List tabs;
    for (const QVariant& item : contents) {
        tabs << Webpage::fromQVariantMap(item.value<QVariantMap>());
    }
    _open_tabs_->replaceModel(tabs);
    if (open_tabs()->count() > 0) {
        viewTab(TabStateOpen, 0);
    }
}

void BrowserController::saveLastOpen() const
{
    QVariantList contents;
    int count = open_tabs()->count();
    TabsModel* open = open_tabs();
    for (int i = 0; i < count; i++) {
        contents << open->webpage_(i)->toQVariantMap();
        qDebug() << contents;
    }
    QMLRegister::fileManager->writeDataJsonFileA("open.json", contents);
}


void BrowserController::moveTab(TabState fromState, int fromIndex, TabState toState, int toIndex)
{
    qInfo() << "BrowserController::moveTab" << fromState << fromIndex << toState << toIndex;
    if (fromIndex < 0 || toIndex < 0
            || fromIndex > open_tabs()->count()
            || toIndex > open_tabs()->count()
            || fromIndex == toIndex - 1
            || fromIndex == toIndex) {
        return;
    }
    if (fromState == TabStateOpen && toState == TabStateOpen) {
        _open_tabs->moveTab(fromIndex, toIndex);
//        set_current_open_tab_highlight_index(toIndex);
        if (fromIndex <= toIndex) {
            viewTab(toState, toIndex - 1);
        } else {
            viewTab(toState, toIndex);
        }
    } else if (fromState == TabStateOpen && toState == TabStateOpen) {
        QMLRegister::searchDB->searchResult()->moveTab(fromIndex, toIndex);
    }
}
