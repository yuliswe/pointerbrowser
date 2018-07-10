#ifndef TABSCONTROLLER_H
#define TABSCONTROLLER_H

#include <QObject>
#include <QList>
#include "tabsmodel.h"
#include <QPair>
#include <QSharedPointer>
#include "webpage.h"
#include "macros.h"

class BrowserController : public QObject
{
    Q_OBJECT

public:
    enum TabState {
        TabStateEmpty,
        TabStateOpen,
        TabStatePreview
    };
    Q_ENUM(TabState)
    enum WhenCreated {
        WhenCreatedSwitchToNew,
        WhenCreatedStayOnCurrent
    };
    Q_ENUM(WhenCreated)
    enum WhenExists {
        WhenExistsViewExisting,
        WhenExistsOpenNew
    };
    Q_ENUM(WhenExists)
    enum CurrentPageSearchState {
        CurrentPageSearchStateClosed,
        CurrentPageSearchStateBeforeSearch,
        CurrentPageSearchStateSearchingNext,
        CurrentPageSearchStateSearchingPrevious,
        CurrentPageSearchStateAfterSearch
    };
    Q_ENUM(CurrentPageSearchState)
//    enum TabsSearchState {
//        BeforeSearch,
//        Searching,
//        AfterSearch
//    };

protected: QSharedPointer<TabsModel> _open_tabs_ = QSharedPointer<TabsModel>::create();
protected: QSharedPointer<TabsModel> _preview_tabs_ = QSharedPointer<TabsModel>::create();
    PROP_RN_D(TabsModel*, open_tabs, _open_tabs_.data())
    PROP_RN_D(TabsModel*, preview_tabs, _preview_tabs_.data())

    PROP_RN_D(QString, home_url, "https://google.com")
    // current tab
    PROP_RN_D(TabState, current_tab_state, TabStateEmpty)
    PROP_RWN_D(Webpage*, current_tab_webpage, nullptr)
    PROP_RN_D(int, current_open_tab_index, -1)
    PROP_RN_D(int, current_preview_tab_index, -1)
    // tabs highlighting
    PROP_RN_D(int, current_open_tab_highlight_index, -1)
//    PROP_RN_D(bool, current_open_tab_active_highlight_flag, false) // if true, force highlight
    PROP_RWN_D(int, current_tab_search_highlight_index, -1)
//    PROP_RWN_D(bool, current_tab_search_active_highlight_mask, true) // if false, disable highlight
    // page search
    PROP_RN_D(bool, welcome_page_visible, true)
    PROP_RN_D(bool, current_page_search_visible, false)
    PROP_RN_D(QString, current_page_search_text, "")
    PROP_RN_D(bool, current_page_search_focus, false)
    PROP_RN_D(bool, current_page_search_count_visible, false)
    PROP_RN_D(int, current_page_search_count, 0)
    PROP_RN_D(int, current_page_search_current_index, -1)
    PROP_RN_D(CurrentPageSearchState, current_page_search_state, CurrentPageSearchStateClosed)

    // address bar
    PROP_RWN_D(int, address_bar_load_progress, 0)
public:
    BrowserController();

signals:

public slots:
    Q_INVOKABLE void newTab(TabState, const QString& url, WhenCreated, WhenExists);
    Q_INVOKABLE void viewTab(TabState, int i);
    Q_INVOKABLE void closeTab(TabState, int i);
    Q_INVOKABLE void closeTab(TabState, const QString& url);
    Q_INVOKABLE void showWelcomePage();
    Q_INVOKABLE void setCurrentPageSearchState(CurrentPageSearchState, QString words = "", int current = 0, int count = 0);
};

#endif // TABSCONTROLLER_H
