#include <QtCore/QtCore>
#include "controller.hpp"
#include "global.hpp"
#include "tabsmodel.hpp"

Controller::Controller()
{
    viewTab(TabStateNull, -1);
}

int Controller::newTab(void const* sender)
{
    return Controller::newTab(0, TabStateOpen,
                              home_url(),
                              WhenCreatedViewNew,
                              WhenExistsOpenNew,
                              sender);
}

int Controller::newTab(TabState state,
                       Url const& uri,
                       WhenCreated newBehavior,
                       WhenExists whenExists,
                       void const* sender)
{
    return newTab(0, state, uri, newBehavior, whenExists, sender);
}

int Controller::newTab(int index,
                       TabState state,
                       Webpage_ webpage,
                       WhenCreated newBehavior,
                       WhenExists whenExists,
                       void const* sender)
{
    qCInfo(ControllerLogging) << "BrowserController::newTab"
                              << state
                              << webpage->url().full()
                              << newBehavior
                              << whenExists;
    int idx = 0;
    webpage->set_tab_state(state);
    if (state == TabStateOpen) {
        bool inserted = false;
        if (whenExists == WhenExistsViewExisting) {
            idx = open_tabs()->findTab(webpage->url());
            if (idx == -1) {
                open_tabs()->insertWebpage_(idx = index, webpage);
                inserted = true;
            }
        } else {
            open_tabs()->insertWebpage_(idx = index, webpage);
            inserted = true;
        }
        if (newBehavior == WhenCreatedViewNew) {
            viewTab(state, idx);
        } else if (newBehavior == WhenCreatedViewCurrent) {
            if (current_tab_state() == TabStateOpen) {
                if (inserted) {
                    viewTab(TabStateOpen, current_open_tab_index() + 1);
                }
            }
        }
        if (inserted) {
            saveLastOpen();
        }
    } else if (state == TabStatePreview) {
        if (whenExists == WhenExistsViewExisting) {
            if ((idx = preview_tabs()->findTab(webpage->url())) > -1) {
                if (newBehavior == WhenCreatedViewNew) {
                    viewTab(TabStatePreview, idx);
                }
                return idx;
            } else {
                preview_tabs()->insertWebpage_(idx = index, webpage);
                if (newBehavior == WhenCreatedViewNew) {
                    viewTab(state, idx);
                }
                return idx;
            }
        } else if (whenExists == WhenExistsOpenNew) {
            preview_tabs()->insertWebpage_(idx = index, webpage);
            if (newBehavior == WhenCreatedViewNew) {
                viewTab(state, idx);
            }
            return idx;
        }
    }
    return idx;
}

int Controller::newTab(int index,
                       TabState state,
                       Url const& uri,
                       WhenCreated newBehavior,
                       WhenExists whenExists,
                       void const* sender)
{
    return newTab(index, state, shared<Webpage>(uri), newBehavior, whenExists, sender);
}

// switch view
int Controller::viewTab(TabState state, int i, void const* sender)
{
    qCInfo(ControllerLogging) << "BrowserController::viewTab" << state << i << sender;
    if (current_tab_state() == state
            && state == TabStateOpen
            && 0 <= i && i < open_tabs()->count()
            && current_tab_webpage().get() == open_tabs()->webpage_(i).get()
            && current_open_tab_index() == i)
    {
        return 0;
    }
    if (current_tab_state() == state
            && state == TabStatePreview
            && 0 <= i && i < preview_tabs()->count()
            && current_tab_webpage().get() == preview_tabs()->webpage_(i).get()
            && current_preview_tab_index() == i)
    {
        return 0;
    }
    static Webpage_ old_page = nullptr;
    closeAllPopovers();
    // disconnect from old
    if (old_page != nullptr) {
        QObject::disconnect(old_page.get(), &Webpage::propertyChanged, this, &Controller::onCurrentTabWebpagePropertyChanged);
        old_page = nullptr;
    }
    if (state == TabStateNull) {
        Webpage_ empty_page = shared<Webpage>();
        old_page = nullptr;
        helperCurrentTabWebpagePropertyChanged(empty_page, nullptr, sender);
        set_current_open_tab_index(-1,sender);
        set_current_open_tab_highlight_index(-1,sender);
        set_current_preview_tab_index(-1,sender);
        set_current_tab_search_highlight_index(-1,sender);
        set_current_tab_state(TabStateNull);
        set_current_tab_webpage(empty_page,sender);
        if (current_tab_search_word().isEmpty()) {
            Global::searchDB->search_result()->clear();
        }
        return -1;
    }
    if (i < 0) { i = 0; }
    Webpage_ page = nullptr;
    if (state == TabStateOpen) {
        if (open_tabs()->count() == 0) {
            return viewTab(TabStateNull, -1);
        }
        if (i >= open_tabs()->count()) { i = open_tabs()->count() - 1; }
        page = open_tabs()->webpage_(i);
    } else if (state == TabStatePreview) {
        if (preview_tabs()->count() == 0) {
            return viewTab(TabStateNull, -1);
        }
        if (i >= preview_tabs()->count()) { i = preview_tabs()->count() - 1; }
        page = preview_tabs()->webpage_(i);
    }
    Q_ASSERT(page != nullptr);
    helperCurrentTabWebpagePropertyChanged(page, nullptr, sender);
    set_current_tab_state(state);
    if (state == TabStateOpen) {
        set_current_open_tab_index(i,sender);
        set_current_open_tab_highlight_index(i,sender);
        set_current_tab_search_highlight_index(-1,sender);
        set_current_preview_tab_index(-1,sender);
        if (current_tab_search_word().isEmpty()) {
            Global::searchDB->searchForWebpageAsync(page);
        }
    } else if (state == TabStatePreview) {
        set_current_preview_tab_index(i,sender);
        set_current_open_tab_index(-1,sender);
        set_current_open_tab_highlight_index(-1,sender);
    }
    set_current_tab_webpage(page,sender);
    // set up load progress watcher
    QObject::connect(page.get(), &Webpage::propertyChanged, this, &Controller::onCurrentTabWebpagePropertyChanged);
    old_page = page;
    return i;
}

Url Controller::address_bar_url()
{
    if (current_tab_webpage()) {
        return current_tab_webpage()->url();
    }
    return Url();
}

int Controller::closeTab(TabState state, int index, void const* sender)
{
    qCInfo(ControllerLogging) << "BrowserController::closeTab" << state << index;
    if (state == TabStateOpen) {
        if (current_tab_state() == TabStateOpen) {
            if (current_open_tab_index() == index) {
                // when removing current tab
                // if there's one after, open that
                if (index + 1 < open_tabs()->count()) {
                    open_tabs()->removeTab(index);
                    viewTab(TabStateOpen, index);
                } // if there's one before, open that
                else if (index >= 1) {
                    open_tabs()->removeTab(index);
                    viewTab(TabStateOpen, index - 1);
                } // if this is the only one
                else {
                    open_tabs()->removeTab(index);
                    viewTab(TabStateNull, -1);
                }
            } else if (current_open_tab_index() > index) {
                open_tabs()->removeTab(index);
                viewTab(TabStateOpen, current_open_tab_index() - 1);
            } else {
                open_tabs()->removeTab(index);
            }
            set_current_tab_search_highlight_index(-1);
            set_current_preview_tab_index(-1);
        } else if (current_tab_state() == TabStatePreview) {
            open_tabs()->removeTab(index);
        }
        saveLastOpen();
    } else if (state == TabStatePreview) {
        if (open_tabs()->count() > 0) {
            viewTab(TabStateOpen, 0);
        } else {
            viewTab(TabStateNull, -1);
        }
        // at the moment there is only one way to close a preview tab:
        // use ctrl+w when current view is a preview. in this case we
        // assume the user wants to close all preview tabs
        clearPreviews();
        set_current_tab_search_highlight_index(-1);
        set_current_preview_tab_index(-1);
    }
    return 0;
}

int Controller::closeTab(TabState state, Url const& uri, void const* sender)
{
    qCInfo(ControllerLogging) << "BrowserController::closeTab" << state << uri;
    int idx = -1;
    if (state == TabStateOpen) {
        idx = open_tabs()->findTab(uri);
    } else if (state == TabStatePreview) {
        idx = preview_tabs()->findTab(uri);
    }
    return closeTab(state, idx);
}

int Controller::closeTab(void const* sender)
{
    qCInfo(ControllerLogging) << "Controller::closeTab()";
    if (current_tab_state() == TabState::TabStateNull)
    {
        qCDebug(ControllerLogging) << "No current tab";
        return 0;
    }
    if (current_tab_state() == TabState::TabStateOpen)
    {
        Q_ASSERT(current_open_tab_index() >= 0);
        closeTab(TabState::TabStateOpen, current_open_tab_index());
        return 0;
    }
    if (current_tab_state() == TabState::TabStatePreview)
    {
        Q_ASSERT(current_preview_tab_index() >= 0);
        closeTab(TabState::TabStatePreview, current_preview_tab_index());
        return 0;
    }
    return 0;
}

int Controller::loadLastOpen()
{
    QVariantList contents = FileManager::readDataJsonFileA("open.json");
    qCInfo(ControllerLogging) << "BrowserController::loadLastOpen";
    Webpage_List tabs;
    for (const QVariant& item : contents) {
        tabs << Webpage::fromQVariantMap(item.value<QVariantMap>());
    }
    open_tabs()->replaceModel(tabs);
    if (open_tabs()->count() > 0) {
        viewTab(TabStateOpen, 0);
    }
    return 0;
}

int Controller::saveLastOpen()
{
    QVariantList contents;
    int count = open_tabs()->count();
    for (int i = 0; i < count; i++) {
        contents << open_tabs()->webpage_(i)->toQVariantMap();
    }
    FileManager::writeDataJsonFileA("open.json", contents);
    return 0;
}

int Controller::moveTab(TabState fromState, int fromIndex, TabState toState, int toIndex, void const* sender)
{
    qCInfo(ControllerLogging) << "BrowserController::moveTab" << fromState << fromIndex << toState << toIndex;
    if (fromIndex < 0 || toIndex < 0
            || fromIndex > open_tabs()->count()
            || toIndex > open_tabs()->count()
            || fromIndex == toIndex - 1
            || fromIndex == toIndex) {
        return 0;
    }
    if (fromState == TabStateOpen && toState == TabStateOpen) {
        open_tabs()->moveTab(fromIndex, toIndex);
        if (fromIndex <= toIndex) {
            viewTab(toState, toIndex - 1);
        } else {
            viewTab(toState, toIndex);
        }
        return 0;
    } else if (fromState == TabStateSearchResult && toState == TabStateOpen) {
        //        Global::searchDB->search_result()->moveTab(fromIndex, toIndex);
        return 0;
    }
    return 0;
}

int Controller::currentTabWebpageGo(QString const& u, void const* sender)
{
    qCInfo(ControllerLogging) << "BrowserController::currentTabWebpageGo" << u;
    closeAllPopovers();
    if (u.isEmpty()) { return false; }
    Webpage_ p = current_tab_webpage();
    if (p.get() && current_tab_state() == TabStateOpen) {
        p->go(u);
    } else {
        newTab(TabStateOpen, Url::fromAmbiguousText(u), WhenCreatedViewNew, WhenExistsOpenNew);
    }
    saveLastOpen();
    return 0;
}


int Controller::currentTabWebpageBack(void const* sender)
{
    qCInfo(ControllerLogging) << "BrowserController::currentTabWebpageBack";
    closeAllPopovers();
    Webpage_ p = current_tab_webpage();
    if (p.get()) {
        emit p->emit_tf_back();
        p->findClear();
        if (current_tab_search_word().isEmpty() && current_tab_state() == TabStateOpen) {
            Global::searchDB->searchForWebpageAsync(p);
        }
    } else {
        qCInfo(ControllerLogging) << "no current tab";
    }
    saveLastOpen();
    return 0;
}

int Controller::currentTabWebpageForward(void const* sender)
{
    qCInfo(ControllerLogging) << "BrowserController::currentTabWebpageForward";
    closeAllPopovers();
    Webpage_ p = current_tab_webpage();
    if (p.get()) {
        emit p->emit_tf_forward();
        p->findClear();
        if (current_tab_search_word().isEmpty() && current_tab_state() == TabStateOpen) {
            Global::searchDB->searchForWebpageAsync(p);
        }
    } else {
        qCInfo(ControllerLogging) << "no current tab";
    }
    saveLastOpen();
    return 0;
}

int Controller::currentTabWebpageStop(void const* sender)
{
    qCInfo(ControllerLogging) << "BrowserController::currentTabWebpageStop";
    closeAllPopovers();
    Webpage_ p = current_tab_webpage();
    if (p.get()) {
        emit p->emit_tf_stop();
    } else {
        qCInfo(ControllerLogging) << "no current tab";
    }
    return 0;
}

int Controller::currentTabWebpageRefresh(void const* sender)
{
    qCInfo(ControllerLogging) << "BrowserController::currentTabWebpageRefresh";
    closeAllPopovers();
    Webpage_ p = current_tab_webpage();
    if (p.get()) {
        emit p->emit_tf_refresh();
        p->findClear();
        Global::crawler->crawlAsync(UrlNoHash(p->url()));
        if (current_tab_search_word().isEmpty() && current_tab_state() == TabStateOpen) {
            Global::searchDB->searchForWebpageAsync(p);
        }
    } else {
        qCInfo(ControllerLogging) << "no current tab";
    }
    return 0;
}

bool Controller::handleWebpageUrlChanged(Webpage_ p, Url const& url, void const* sender)
{
    qCInfo(ControllerLogging) << "Controller::handleWebpageUrlChanged" << p << url;
    p->handleUrlChanged(url, sender);
    Global::crawler->crawlAsync(UrlNoHash(p->url()));
    Webpage_ w = current_tab_webpage();
    if (p == w && current_tab_search_word().isEmpty()
            && current_tab_state() == TabStateOpen)
    {
        Global::searchDB->searchForWebpageAsync(p);
    }
    saveLastOpen();
    return true;
}

bool Controller::updateWebpageFindTextFound(Webpage_ wp, int found, void const* sender)
{
    qCInfo(ControllerLogging) << "Controller::updateFindTextFound" << wp << found;
    wp->updateFindTextFound(found);
    return true;
}

void Controller::clearPreviews()
{
    if (current_tab_state() == TabStatePreview) {
        if (open_tabs()->count() > 0) {
            viewTab(TabStateOpen, 0);
        } else {
            viewTab(TabStateNull, -1);
        }
    }
    preview_tabs()->clear();
}

int Controller::currentTabWebpageFindTextNext(QString const& txt, void const* sender)
{
    if (current_tab_webpage()) {
        current_tab_webpage()->findNext(txt);
    } else {
        qCInfo(ControllerLogging) << "no current tab";
    }
    return 0;
}

int Controller::currentTabWebpageFindTextPrev(QString const& txt, void const* sender)
{
    if (current_tab_webpage()) {
        current_tab_webpage()->findPrev(txt);
    } else {
        qCInfo(ControllerLogging) << "no current tab";
    }
    return 0;
}

int Controller::currentTabWebpageFindTextShow(void const* sender)
{
    if (current_tab_webpage()) {
        if (current_tab_webpage()->is_blank()) {
            qCInfo(ControllerLogging) << "tab page is blank";
            return -1;
        }
        FindTextState state = current_webpage_find_text_state();
        state.visiable = true;
        current_tab_webpage()->set_find_text_state(state);
        if (! state.text.isEmpty()) {
            current_tab_webpage()->emit_tf_find_highlight_all(state.text);
        }
    } else {
        qCInfo(ControllerLogging) << "no current tab";
    }
    return 0;
}

int Controller::currentTabWebpageFindTextHide(void const* sender)
{
    if (current_tab_webpage()) {
        FindTextState state = current_webpage_find_text_state();
        state.visiable = false;
        current_tab_webpage()->set_find_text_state(state);
        current_tab_webpage()->emit_tf_find_clear();
    } else {
        qCInfo(ControllerLogging) << "no current tab";
    }
    return 0;
}

bool Controller::currentTabWebpageCrawlerRuleTableInsertRule(CrawlerRule rule, void const* sender)
{
    qCInfo(ControllerLogging) << "Controller::currentTabWebpageCrawlerRuleTableInsertRule" << rule;
    if (! current_tab_webpage()) {
        qCInfo(ControllerLogging) << "no current tab";
        return false;
    }
    if (! current_tab_webpage()->crawlerRuleTableInsertRule(rule)) {
        if (crawler_rule_table_visible()) {
            emit_tf_show_crawler_rule_table_row_hint(current_webpage_crawler_rule_table()->rulesCount());
        }
        return false;
    }
    emit_tf_hide_crawler_rule_table_row_hint();
    current_tab_webpage()->crawler_rule_table()->writePartialTableToSettings();
    Global::crawler->updateRulesFromSettingsAsync();
    return true;
}


bool Controller::currentTabWebpageCrawlerRuleTableRemoveRule(int idx, void const* sender)
{
    if (! current_tab_webpage()) {
        qCInfo(ControllerLogging) << "no current tab";
        return false;
    }
    emit_tf_hide_crawler_rule_table_row_hint();
    if (! current_tab_webpage()->crawlerRuleTableRemoveRule(idx)) {
        return false;
    }
    current_tab_webpage()->crawler_rule_table()->writePartialTableToSettings();
    Global::crawler->updateRulesFromSettingsAsync();
    return true;
}

bool Controller::currentTabWebpageCrawlerRuleTableModifyRule(int old, CrawlerRule modified, void const* sender)
{
    if (! current_tab_webpage()) {
        qCInfo(ControllerLogging) << "no current tab";
        return false;
    }
    if (! current_tab_webpage()->crawlerRuleTableModifyRule(old, modified)) {
        if (crawler_rule_table_visible()) {
            emit_tf_show_crawler_rule_table_row_hint(old);
        }
        return false;
    }
    emit_tf_hide_crawler_rule_table_row_hint();
    current_tab_webpage()->crawler_rule_table()->writePartialTableToSettings();
    Global::crawler->updateRulesFromSettingsAsync();
    return true;
}

bool Controller::custom_set_crawler_rule_table_visible(bool const& visible, void const* sender)
{
    if (visible) {
        qCInfo(ControllerLogging) << "Controller::showCrawlerRuleTable";
        if (current_tab_webpage() == nullptr) {
            qCritical(ControllerLogging) << "Controller::showCrawlerRuleTable no current tab";
            return false;
        }
        if (current_tab_webpage()->is_blank()) {
            qCritical(ControllerLogging) << "Controller::showCrawlerRuleTable current tab is blank";
            return false;
        }
        set_downloads_visible(false);
        current_tab_webpage()->crawlerRuleTableReloadFromSettings();
    } else {
        // for better user experience, when crawler rule table is closed, reload searches
        Webpage_ w = current_tab_webpage();
        if (crawler_rule_table_visible() && w != nullptr) {
            Global::crawler->crawlAsync(UrlNoHash(w->url()));
            if (current_tab_search_word().isEmpty()) {
                Global::searchDB->searchForWebpageAsync(w);
            } else {
                Global::searchDB->searchAsync(Global::controller->current_tab_search_word());
            }

        }
        emit_tf_hide_crawler_rule_table_row_hint();
    }
    return visible;
}

int Controller::searchTabs(QString const& words, void const* sender)
{
    qCInfo(ControllerLogging) << "Controller::searchTabs" << words;
    set_current_tab_search_word(words);
    clearPreviews();
    if (words.isEmpty() && current_tab_webpage() != nullptr) {
        Global::searchDB->searchForWebpageAsync(current_tab_webpage());
        return 0;
    }
    Global::searchDB->searchAsync(words);
    return 0;
}

int Controller::saveBookmarks()
{
    qCInfo(ControllerLogging) << "BrowserController::saveBookmarks";
    QVariantList contents;
    int count = bookmarks()->count();
    for (int i = 0; i < count; i++) {
        contents << bookmarks()->webpage_(i)->toQVariantMap();
    }
    qCDebug(ControllerLogging) << "BrowserController::saveBookmarks" << contents;
    FileManager::writeDataJsonFileA("bookmarks.json", contents);
    return count;
}

int Controller::loadBookmarks()
{
    QVariantList contents = FileManager::readDataJsonFileA("bookmarks.json");
    qCInfo(ControllerLogging) << "BrowserController::loadBookmarks";
    Webpage_List tabs;
    for (const QVariant& item : contents) {
        tabs << Webpage::fromQVariantMap(item.value<QVariantMap>());
    }
    bookmarks()->replaceModel(tabs);
    return tabs.count();
}

int Controller::currentTabWebpageBookmark(void const* sender)
{
    if (current_tab_webpage()) {
        insertBookmark(current_tab_webpage(), 0);
    } else {
        qCInfo(ControllerLogging) << "no current tab";
    }
    return 0;
}

int Controller::insertBookmark(Webpage_ w, int idx = 0)
{
    qCInfo(ControllerLogging) << "BrowserController::insertBookmark" << w << idx;
    if (bookmarks()->findTab(w->url()) >= 0) {
        qCCritical(ControllerLogging) << "BrowserController::insertBookmark: bookmark already exists";
        return -1;
    }
    bookmarks()->insertWebpage_(idx, w);
    saveBookmarks();
    return idx;
}

int Controller::removeBookmark(int idx, void const* sender)
{
    qCInfo(ControllerLogging) << "BrowserController::removeBookmark" << idx;
    bookmarks()->removeTab(idx);
    saveBookmarks();
    return idx;
}

int Controller::moveBookmark(int from, int to, void const* sender)
{
    qCInfo(ControllerLogging) << "BrowserController::moveBookmark" << from << to;
    bookmarks()->moveTab(from, to);
    saveBookmarks();
    return to;
}

int Controller::showBookmarkPage(void const*sender)
{
    qCInfo(ControllerLogging) << "BrowserController::showBookmarkPage";
    loadBookmarks();
    set_bookmark_page_visible(true);
    return 0;
}

int Controller::hideBookmarkPage(void const*sender)
{
    qCInfo(ControllerLogging) << "BrowserController::hideBookmarkPage";
    set_bookmark_page_visible(false);
    return 0;
}


int Controller::renameBookmark(Webpage_ wp, QString const& title, void const* sender)
{
    qCInfo(ControllerLogging) << "Controller::renameBookmark" << wp << title;
    wp->set_title(title);
    saveBookmarks();
    return 0;
}

int Controller::showNextOpenTab(void const* sender)
{
    qCInfo(ControllerLogging) << "Controller::showNextTab";
    if (open_tabs()->count() == 0) {
        return -1;
    }
    if (current_open_tab_index() + 1 < open_tabs()->count()) {
        return viewTab(TabStateOpen, current_open_tab_index() + 1, sender);
    }
    return viewTab(TabStateOpen, 0, sender);
}

int Controller::showPrevOpenTab(void const* sender)
{
    qCInfo(ControllerLogging) << "Controller::showPrevTab";
    if (open_tabs()->count() == 0) {
        return -1;
    }
    if (current_open_tab_index() - 1 >= 0) {
        return viewTab(TabStateOpen, current_open_tab_index() - 1, sender);
    }
    return viewTab(TabStateOpen, open_tabs()->count() - 1, sender);
}

bool Controller::custom_set_downloads_visible(const bool& visible, void const* sender)
{
    if (visible && ! downloads_dirpath().isEmpty()) {
        set_crawler_rule_table_visible(false, sender);
        download_files()->loadDirectoryContents(downloads_dirpath());
    }
    return visible;
}

File_ Controller::downloadFileFromUrlAndRename(Url const& url, QString const& filename, void const* sender)
{
    qCInfo(ControllerLogging) << "Controller::downloadFileFromUrlAndRename" << url << filename;
    // check if already downloaded
    for (int i = 0; i < download_files()->count(); i++)
    {
        File_ file = download_files()->get(i);
        if (file->download_url() == url)
        {
            qCCritical(ControllerLogging) << "Already downloaded" << filename;
            set_downloads_visible(true);
            return file;
        }
    }
    // check if there's one we can resume
    for (int i = 0; i < downloading_files()->count(); i++)
    {
        File_ file = downloading_files()->get(i);
        if (file->download_url() == url)
        {
            if (file->downloading()) {
                set_downloads_visible(true);
                qCDebug(ControllerLogging) << "Already downloading" << filename;
                return file;
            }
            file->set_downloading(true);
            set_downloads_visible(true);
            file->emit_tf_download_resume();
            qCDebug(ControllerLogging) << "Resuming file download" << filename;
            return file;
        }
    }
    qCDebug(ControllerLogging) << "Downloading new file" << filename;
    File_ file = File_::create();
    file->set_download_url(url);
    file->set_save_as_filename(filename);
    file->set_downloading(true);
    file->set_percentage(0);
    downloading_files()->insert(file);
    set_downloads_visible(true);
    file->emit_tf_download_resume();
    qCDebug(ControllerLogging) << "Download started." << filename;
    return file;
}

int Controller::handleFileDownloadFinished(File_ tmpfile, void const* sender)
{
    qCInfo(ControllerLogging) << "handleFileDownloadFinished" << tmpfile;
    QString save_as_filename = tmpfile->save_as_filename();
    while (FileManager::moveFileToDir(tmpfile->absoluteFilePath(), downloads_dirpath(), save_as_filename) == 2)
    {
        save_as_filename.prepend("New ");
    }
    downloading_files()->remove(tmpfile);
    set_downloads_visible(true);
    return true;
}

int Controller::handleFileDownloadStopped(File_ file, void const* sender)
{
    qCInfo(ControllerLogging) << "handleFileDownloadStopped" << file;
    file->set_downloading(false);
    file->emit_tf_download_stop();
    downloading_files()->remove(file);
    set_downloads_visible(true);
    return true;
}

int Controller::closeAllPopovers(void const* sender)
{
    set_downloads_visible(false, sender);
    set_crawler_rule_table_visible(false, sender);
    return true;
}

void Controller::onCurrentTabWebpagePropertyChanged(void const* a, void const* sender)
{
    return helperCurrentTabWebpagePropertyChanged(current_tab_webpage(), a, sender);
}

void Controller::helperCurrentTabWebpagePropertyChanged(Webpage_ w, void const* a, void const* sender)
{
    if (!a || w->is_load_progress_change(a)) { set_address_bar_load_progress(w->load_progress()); }
    if (!a || w->is_title_change(a)) { set_address_bar_title(w->title()); }
    if (!a || w->is_find_text_state_change(a)) { set_current_webpage_find_text_state(w->find_text_state()); }
    if (!a || w->is_crawler_rule_table_change(a)) { set_current_webpage_crawler_rule_table(w->crawler_rule_table()); }
    if (!a || w->is_is_blank_change(a)) {
        set_bookmark_page_visible(w->is_blank());
        set_current_tab_webpage_is_blank(w->is_blank());
        set_crawler_rule_table_enabled(! w->is_blank());
        if (w->is_blank()) {
            showBookmarkPage();
        } else {
            hideBookmarkPage();
        }
    }
    if (!a || w->is_can_go_back_change(a)) { set_current_tab_webpage_can_go_back(w->can_go_back()); }
    if (!a || w->is_can_go_forward_change(a)) { set_current_tab_webpage_can_go_forward(w->can_go_forward()); }
    if (!a || w->is_is_error_change(a)) { set_current_tab_webpage_is_error(w->is_error()); }
}

