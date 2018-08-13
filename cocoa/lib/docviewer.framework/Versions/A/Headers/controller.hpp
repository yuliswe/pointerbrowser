#ifndef TABSCONTROLLER_H
#define TABSCONTROLLER_H

#include <QtCore/QtCore>
#include "tabsmodel.hpp"
#include "webpage.hpp"
#include "macros.hpp"
#include "crawler.hpp"

class Controller : public QObject
{
    Q_OBJECT

public:
    virtual ~Controller() = default;

    enum TabState {
        TabStateEmpty,
        TabStateOpen,
        TabStatePreview,
        TabStateSearchResult
    };
    Q_ENUM(TabState)
    enum WhenCreated {
        WhenCreatedViewNew,
        WhenCreatedViewCurrent
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

    PROP_DEF_BEGINS
    PROP_RN_D(TabsModel_, open_tabs, shared<TabsModel>())
    PROP_RN_D(TabsModel_, preview_tabs, shared<TabsModel>())

    PROP_RN_D(QString, home_url, "https://www.google.com")
    PROP_RN_D(Webpage_, welcome_page, shared<Webpage>(QString("https://Welcome")))
    // current tab
    PROP_RN_D(TabState, current_tab_state, TabStateEmpty)
    PROP_N_D(Webpage*, current_tab_webpage, nullptr)
    PROP_RN_D(int, current_open_tab_index, -1)
    PROP_RN_D(int, current_preview_tab_index, -1)
    // tabs highlighting
    PROP_RN_D(int, current_open_tab_highlight_index, -1)
    PROP_RN_D(int, current_tab_search_highlight_index, -1)
    // welcome page
    PROP_RN_D(bool, welcome_page_visible, true)
    // page search
    PROP_RN_D(FindTextState, current_webpage_find_text_state, FindTextState{})

    // address bar
    PROP_RN_D(float, address_bar_load_progress, 0)
    PROP_RN_D(QString, address_bar_title, "")
    Url address_bar_url();

    // crawler
    PROP_RN_D(CrawlerRuleTable_, current_webpage_crawler_rule_table, CrawlerRuleTable_::create())
    SIG_TF_0(show_crawler_rule_table)
    SIG_TF_0(hide_crawler_rule_table)
    SIG_TF_0(enable_crawler_rule_table)
    SIG_TF_0(disable_crawler_rule_table)
    SIG_TF_1(show_crawler_rule_table_row_hint, int)
    SIG_TF_0(hide_crawler_rule_table_row_hint)

    METH_ASYNC_2(bool, currentTabWebpageCrawlerRuleTableModifyRule, int, CrawlerRule)
//    METH_ASYNC_1(bool, currentTabWebpageCrawlerRuleTableEnableRule, CrawlerRule)
//    METH_ASYNC_1(bool, currentTabWebpageCrawlerRuleTableDisableRule, CrawlerRule)
    METH_ASYNC_1(bool, currentTabWebpageCrawlerRuleTableInsertRule, CrawlerRule)
    METH_ASYNC_1(bool, currentTabWebpageCrawlerRuleTableRemoveRule, int)

    // UI calls these methods to inform controller user input
    // these can be used for UI code that's not awared of the global state
    METH_ASYNC_1(int, currentTabWebpageGo, QString const&)
    METH_ASYNC_0(int, currentTabWebpageStop)
    METH_ASYNC_0(int, currentTabWebpageBack)
    METH_ASYNC_0(int, currentTabWebpageForward)
    METH_ASYNC_0(int, currentTabWebpageRefresh)
    METH_ASYNC_0(int, currentTabWebpageFindTextHide)
    METH_ASYNC_0(int, currentTabWebpageFindTextShow)
    METH_ASYNC_1(int, currentTabWebpageFindTextNext, QString const&)
    METH_ASYNC_1(int, currentTabWebpageFindTextPrev, QString const&)
    METH_ASYNC_0(int, showCrawlerRuleTable)
    METH_ASYNC_0(int, hideCrawlerRuleTable)

    METH_ASYNC_2(bool, updateWebpageUrl, Webpage_, Url const&)
    METH_ASYNC_2(bool, updateWebpageTitle, Webpage_, QString const&)
    METH_ASYNC_2(bool, updateWebpageProgress, Webpage_, float)
    METH_ASYNC_2(bool, updateWebpageFindTextFound, Webpage_, int)

    PROP_DEF_ENDS

public:
    Controller();

    METH_ASYNC_0(int, newTab)
    METH_ASYNC_4(int, newTab, Controller::TabState, Url const&, Controller::WhenCreated, Controller::WhenExists)
    METH_ASYNC_2(int, viewTab, Controller::TabState, int)
    METH_ASYNC_4(int, moveTab, Controller::TabState, int, Controller::TabState, int)
    METH_ASYNC_0(int, closeTab)
    METH_ASYNC_2(int, closeTab, Controller::TabState, int)
    METH_ASYNC_2(int, closeTab, Controller::TabState, Url const&)
    int loadLastOpen();
    int saveLastOpen();
    void clearPreviews();

};

Q_DECLARE_METATYPE(Controller::TabState)
Q_DECLARE_METATYPE(Controller::WhenCreated)
Q_DECLARE_METATYPE(Controller::WhenExists)


#endif // TABSCONTROLLER_H
