#ifndef TABSCONTROLLER_H
#define TABSCONTROLLER_H

#include <QtCore/QtCore>
#include "tabsmodel.hpp"
#include "filelistmodel.hpp"
#include "webpage.hpp"
#include "macros.hpp"
#include "crawler.hpp"
#include "logging.hpp"
#include "tags.hpp"

class Controller : public QObject
{
    Q_OBJECT
    friend class Global;

public:
    virtual ~Controller() = default;

    enum TabState {
        TabStateNull,
        TabStateOpen,
        TabStatePreview,
        TabStateWorkspace,
        TabStateTagged,
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
    // tabs
    PROP_RN_D(TabsModel_, open_tabs, shared<TabsModel>())
    PROP_RN_D(TabsModel_, preview_tabs, shared<TabsModel>())
    PROP_RN_D(TabsModel_, workspace_tabs, shared<TabsModel>())
    PROP_RN_D(TabsModel_, bookmarks, shared<TabsModel>())
    PROP_RN_D(TagsCollection_, tags, TagsCollection_::create())
    PROP_RN_D(TagsCollection_, workspaces, TagsCollection_::create())

    PROP_RN_D(QString, home_url, "about:blank")
    PROP_RN_D(Webpage_, welcome_page, shared<Webpage>(QString("https://Welcome")))
    // current tab
    PROP_RN_D(TabState, current_tab_state, TabStateNull)
    PROP_RN_D(Webpage_, current_tab_webpage, nullptr)
    PROP_RWN_D(bool, current_tab_webpage_can_go_back, false)
    PROP_RWN_D(bool, current_tab_webpage_can_go_forward, false)
    PROP_RWN_D(bool, current_tab_webpage_is_blank, true)
    PROP_RN_D(int, current_open_tab_index, -1)
    PROP_RN_D(int, current_workspace_index, -1)
    PROP_RN_D(int, current_workspace_tab_index, -1)
    PROP_RN_D(int, current_preview_tab_index, -1)
    PROP_RN_D(int, current_search_result_tab_index, -1)
    PROP_RN_D(int, current_tab_webpage_associated_tabs_model_index, -1)
    // error page
    PROP_RN_D(bool, current_tab_webpage_is_error, false)
    // welcome page
    PROP_RN_D(bool, welcome_page_visible, true)
    // bookmark page
    PROP_RN_D(bool, bookmark_page_visible, false)
    // page search
    PROP_RN_D(FindTextState, current_webpage_find_text_state, FindTextState{})
    // tab search
    PROP_RN_D(QString, current_tab_search_word, "")
    // download
    PROP_RwN_D(bool, downloads_visible, false)
    PROP_RN_D(FileListModel_, downloading_files, FileListModel_::create())
    PROP_RN_D(FileListModel_, download_files, FileListModel_::create())
    // address bar
    PROP_RN_D(float, address_bar_load_progress, 0)
    PROP_RN_D(QString, address_bar_title, "")
    Url address_bar_url();

    // crawler
    PROP_RN_D(CrawlerRuleTable_, current_webpage_crawler_rule_table, CrawlerRuleTable_::create())
    PROP_RN_D(bool, crawler_rule_table_enabled, false)
    PROP_RwN_D(bool, crawler_rule_table_visible, false)
    SIG_TF_1(show_crawler_rule_table_row_hint, int)
    SIG_TF_0(hide_crawler_rule_table_row_hint)
    SIG_TF_0(close_all_popovers)

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
    METH_ASYNC_0(int, currentTabWebpageBookmark)
    METH_ASYNC_0(int, cycleNextTab)
    METH_ASYNC_0(int, cyclePrevTab)
    METH_ASYNC_1(int, searchTabs, QString const&)
    METH_ASYNC_0(int, showBookmarkPage)
    METH_ASYNC_0(int, hideBookmarkPage)

    METH_ASYNC_2(bool, handleWebpageUrlChanged, Webpage_, Url const&)
    METH_ASYNC_2(bool, updateWebpageFindTextFound, Webpage_, int)
    // downloads
    PROP_RWN_D(QString, downloads_dirpath, "")
    METH_ASYNC_1(int, handleFileDownloadFinished, File_)
    METH_ASYNC_1(int, handleFileDownloadStopped, File_)
    METH_ASYNC_2(File_, downloadFileFromUrlAndRename, Url, QString const&)

    // close tab
    PROP_RN_D(TabState, next_tab_state, TabStateNull)
    PROP_RN_D(int, next_tab_index, -1)

    // tags
    PROP_RN_D(qint8, tag_listing_last_cache, 0)

    PROP_DEF_ENDS

    int saveBookmarks();
    int insertBookmark(Webpage_, int);
    void Q_INVOKABLE onCurrentTabWebpagePropertyChanged(void const* address, void const* sender = nullptr);
    void helperCurrentTabWebpagePropertyChanged(Webpage_ w, void const* address, void const* sender);
    void setNextTabStateAndIndex(TabState state, int index);

    int loadLastOpen();
    int saveLastOpen();
    void clearPreviews();
    void saveAllTags();
    void saveTagsList();

public:
    Controller();

    METH_ASYNC_0(int, newTab)
    METH_ASYNC_4(int, newTab, Controller::TabState, Url const&, Controller::WhenCreated, Controller::WhenExists)
    METH_ASYNC_5(int, newTabByWebpage, int, Controller::TabState, Webpage_, Controller::WhenCreated, Controller::WhenExists)
    METH_ASYNC_5(int, newTabByWebpageCopy, int, Controller::TabState, Webpage_, Controller::WhenCreated, Controller::WhenExists)
    METH_ASYNC_5(int, newTab, int, Controller::TabState, Url const&, Controller::WhenCreated, Controller::WhenExists)
    METH_ASYNC_1(int, viewTab, Webpage_)
    METH_ASYNC_2(int, viewTab, Controller::TabState, int)
    METH_ASYNC_4(int, moveTab, Controller::TabState, int, Controller::TabState, int)
    METH_ASYNC_3(int, moveTab, Webpage_, Controller::TabState, int)
    METH_ASYNC_0(int, closeTab)
    METH_ASYNC_2(int, closeTab, Controller::TabState, int)
    METH_ASYNC_2(int, closeTab, Controller::TabState, Webpage_)
    METH_ASYNC_2(int, closeTab, Controller::TabState, Url const&)

    METH_ASYNC_0(int, reloadBookmarks)
    METH_ASYNC_1(int, removeBookmark, int)
    METH_ASYNC_2(int, renameBookmark, Webpage_, QString const&)
    METH_ASYNC_2(int, moveBookmark, int, int)

    int indexOfTagContainerByTitle(QString const&);
    METH_ASYNC_0(int, reloadAllTags)
    METH_ASYNC_3(int, tagContainerInsertWebpageCopy, TagContainer_, int, Webpage_)
    METH_ASYNC_3(int, tagContainerMoveWebpage, TagContainer_, int, int)
    METH_ASYNC_2(int, tagContainerRemoveWebpage, TagContainer_, Webpage_)
    METH_ASYNC_3(int, tagContainerRemoveWebpage, TagContainer_, Webpage_, bool)
    METH_ASYNC_3(int, createTagContainerByWebpage, QString const&, int, Webpage_)
    METH_ASYNC_3(int, createTagContainerByWebpageCopy, QString const&, int, Webpage_)
    METH_ASYNC_1(int, removeTagContainer, int)
    METH_ASYNC_2(int, moveTagContainer, int, int)
    METH_ASYNC_2(int, renameTagContainer, TagContainer_, QString const&)

    METH_ASYNC_2(int, workspacesInsertTagContainer, int, TagContainer_)
    METH_ASYNC_2(int, workspacesMoveTagContainer, int, int)
    METH_ASYNC_1(int, workspacesRemoveTagContainer, int)

    TagsCollection_ listTagsMatching(QString const&);
    std::pair<TagsCollection_,TagsCollection_> partitionTagsByUrl(Url const&);

    METH_ASYNC_0(int, closeAllPopovers)
};

Q_DECLARE_METATYPE(Controller::TabState)
Q_DECLARE_METATYPE(Controller::WhenCreated)
Q_DECLARE_METATYPE(Controller::WhenExists)


#endif // TABSCONTROLLER_H
