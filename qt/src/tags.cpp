#include "tags.hpp"
#include "controller.hpp"

int Controller::tagContainerInsertWebpageCopy(TagContainer_ container, int index, Webpage_ w, void const* sender)
{
    INFO(ControllerLogging) << container << index << w;
    set_tag_listing_last_cache(tag_listing_last_cache() + 1);
    container->insertWebpage(shared<Webpage>(w), index);
    container->saveToFile();
    return true;
}

int Controller::tagContainerMoveWebpage(TagContainer_ container, int from, int to, void const* sender)
{
    qCInfo(ControllerLogging) << "Controller::tagContainerMoveWebpage" << container << from << to;
    set_tag_listing_last_cache(tag_listing_last_cache() + 1);
    container->move(from, 1, to);
    container->saveToFile();
    return true;
}

int Controller::tagContainerRemoveWebpage(TagContainer_ container, Webpage_ w, void const* sender)
{
    return tagContainerRemoveWebpage(container, w, false, sender);
}

int Controller::tagContainerRemoveWebpage(TagContainer_ container, Webpage_ w, bool removeContainerIfEmpty, void const* sender)
{
    INFO(ControllerLogging) << container << w->title() << removeContainerIfEmpty;
    set_tag_listing_last_cache(tag_listing_last_cache() + 1);
    container->removeByUrl(w->url());
    container->saveToFile();
    // if the webpage is opened
    int index = workspace_tabs()->findTabByRefOrUrl(w);
    if (index >= 0)
    {
        // unless the webpage is also opened somewhere else
        // close the tab
        bool opened_in_other_workspace = false;
        for (int j = workspaces()->count() - 1; j >= 0; j--) {
            TagContainer_ other_container = workspaces()->get(j);
            if (container != other_container && other_container->containsUrl(w->url()))
            {
                opened_in_other_workspace = true;
                break;
            }
        }
        if (opened_in_other_workspace) {
            return true;
        }
        // if the current view is this tab, switch to a different tab
        if (current_tab_webpage()->url() == w->url()
                && current_tab_state() == TabStateWorkspace)
        {
            if (open_tabs()->count() > 0) {
                viewTab(TabStateOpen, 0);
            } else {
                viewTab(TabStateNull, -1);
            }
        }
        workspace_tabs()->removeTab(index);
    }
    // if then the container is empty, remove it forever
    if (removeContainerIfEmpty && container->count() == 0) {
        removeTagContainer(tags()->indexOf(container));
    }
    return true;
}

int Controller::indexOfTagContainerByTitle(QString const& title)
{
    static QString last_arg;
    static qint8 last_cache = -1;
    int foundAt = -1;
    if (last_cache == tag_listing_last_cache() && last_arg == title) { return foundAt; }
    last_arg = title;
    foundAt = -1;

    for (int i = tags()->count() - 1; i >= 0; i--) {
        if (tags()->get(i)->title() == title) {
            foundAt = i;
            break;
        }
    }
    return foundAt;
}

int Controller::createTagContainer(QString const& title, int index, Webpage_ w, void const* sender)
{
    INFO(ControllerLogging) << title << index << w;
    set_tag_listing_last_cache(tag_listing_last_cache() + 1);
    for (int i = tags()->count() - 1; i >= 0; i--) {
        if (tags()->get(i)->title() == title) {
            return false;
        }
    }
    TagContainer_ container = TagContainer_::create(title.isEmpty() ? "Untitled Tag" : title);
    container->insertWebpage(w, index);
    tags()->insert(container, index);
    container->saveToFile();
    saveTagsList();
    return true;
}

int Controller::removeTagContainer(int index, void const* sender)
{
    qCInfo(ControllerLogging) << "Controller::removeTagContainer" << index;
    set_tag_listing_last_cache(tag_listing_last_cache() + 1);
    TagContainer_ container = tags()->get(index);
    container->deleteFile();
    tags()->remove(index);
    saveTagsList();
    // if tag container is opened in workspace, remove
    int workspace_index = workspaces()->indexOf(container);
    if (workspace_index >= 0) {
        workspacesRemoveTagContainer(workspace_index);
    }
    return true;
}

int Controller::moveTagContainer(int from, int to, void const* sender)
{
    qCInfo(ControllerLogging) << "Controller::moveTagContainer" << from << to;
    set_tag_listing_last_cache(tag_listing_last_cache() + 1);
    tags()->move(from, 1, to);
    saveTagsList();
    return true;
}

int Controller::renameTagContainer(TagContainer_ target, QString const& name, void const* sender)
{
    qCInfo(ControllerLogging) << "Controller::renameTagContainer" << target << name;
    set_tag_listing_last_cache(tag_listing_last_cache() + 1);
    target->renameFile(name);
    saveTagsList();
    return true;
}

int Controller::reloadAllTags(void const* sender)
{
    set_tag_listing_last_cache(tag_listing_last_cache() + 1);
    INFO(ControllerLogging) << sender;
    QVariantList contents = FileManager::readDataJsonFileA("tags/tags.json");
    QList<TagContainer_> newls;
    for (const QVariant& item : contents) {
        TagContainer_ container = TagContainer_::create(item.value<QString>());
        container->reloadFromFile();
        newls << container;
    }
    tags()->resetModel(newls);
    return true;
}


void Controller::saveTagsList()
{
    set_tag_listing_last_cache(tag_listing_last_cache() + 1);
    qCInfo(ControllerLogging) << "Controller::saveTagsList";
    QVariantList contents;
    int count = tags()->count();
    for (int i = 0; i < count; i++) {
        contents << tags()->get(i)->title();
    }
    qCDebug(ControllerLogging) << "Controller::saveTagsList" << contents;
    FileManager::writeDataJsonFileA("tags/tags.json", contents);
}


void Controller::saveAllTags()
{
    set_tag_listing_last_cache(tag_listing_last_cache() + 1);
    qCInfo(ControllerLogging) << "Controller::saveAllTags";
    QVariantList contents;
    int count = tags()->count();
    for (int i = 0; i < count; i++) {
        contents << tags()->get(i)->title();
        tags()->get(i)->saveToFile();
    }
    qCDebug(ControllerLogging) << "Controller::saveAllTags" << contents;
    FileManager::writeDataJsonFileA("tags/tags.json", contents);
}


TagsCollection_ Controller::listTagsMatching(QString const& name)
{
    INFO(ControllerLogging) << name;
    static TagsCollection_ out = TagsCollection_::create();
    static QString last_arg;
    static qint8 last_cache = -1;
    if (last_cache == tag_listing_last_cache() && last_arg == name) { return out; }
    last_cache = tag_listing_last_cache();
    last_arg = name;
    out->clear();
    for (int i = tags()->count() - 1; i >= 0; i--)
    {
        if (tags()->get(i)->title().indexOf(name) != -1)
        {
            out->insert(tags()->get(i));
        }
    }
    return out;
}

std::pair<TagsCollection_,TagsCollection_> Controller::partitionTagsByUrl(Url const& u)
{
    INFO(ControllerLogging) << u;
    static Url last_arg;
    static qint8 last_cache = -1;
    static TagsCollection_ yes = TagsCollection_::create();
    static TagsCollection_ no = TagsCollection_::create();
    if (last_cache == tag_listing_last_cache() && last_arg == u) { return std::pair<TagsCollection_,TagsCollection_>{yes, no}; }
    last_arg = u;
    last_cache = tag_listing_last_cache();
    yes->clear();
    no->clear();
    for (int i = tags()->count() - 1; i >= 0; i--)
    {
        TagContainer_ container = tags()->get(i);
        if (container->containsUrl(u)) {
            yes->insert(container);
        } else {
            no->insert(container);
        }
    }
    return std::pair<TagsCollection_,TagsCollection_>{yes, no};
}

void TagContainer::deleteFile()
{
    FileManager::removeDataFile(filename());
}

int TagContainer::removeByUrl(Url const& u)
{
    int i = indexOfUrl(u);
    if (i != -1) {
        remove(i);
    }
    return i;
}

void TagContainer::saveToFile()
{
    qCInfo(ControllerLogging) << "TagContainer::saveToFile";
    QVariantList contents;
    for (int i = 0; i < count(); i++) {
        contents << get(i)->toQVariantMap();
    }
    qCDebug(ControllerLogging) << "TagContainer::saveToFile" << contents;
    FileManager::writeDataJsonFileA(filename(), contents);
}

void TagContainer::renameFile(QString const& name)
{
    QString oldpath = filename();
    set_title(name);
    QString newpath = filename();
    FileManager::renameDataFile(oldpath, newpath);
}

void TagContainer::reloadFromFile()
{
    QVariantList contents = FileManager::readDataJsonFileA(filename());
    QList<Webpage_> out;
    for (int i = contents.count() - 1; i >= 0; i--) {
        out << Webpage::fromQVariantMap(contents[i].value<QVariantMap>());
    }
    resetModel(out);
}

int TagContainer::indexOfUrl(Url const& u)
{
    for (int j = count() - 1; j >= 0; j--)
    {
        Webpage_ w = get(j);
        if (w->url() == u)
        {
            return j;
        }
    }
    return -1;
}

bool TagContainer::containsUrl(Url const& u)
{
    for (int j = count() - 1; j >= 0; j--)
    {
        Webpage_ w = get(j);
        if (w->url() == u)
        {
            return true;
        }
    }
    return false;
}

QString TagContainer::filename()
{
    return "tags/data/" + title() + ".json";
}

TagContainer::TagContainer(QString const& title)
    : BaseListModel<Webpage_>()
    , m_title(title)
{

}

void TagContainer::insertWebpage(Webpage_ w, int i)
{
    if (! containsUrl(w->url()))
    {
        insert(w, i);
    }
}

int Controller::workspacesInsertTagContainer(int index, TagContainer_ tag, void const* sender)
{
    INFO(ControllerLogging) << index << tag;
    if (workspaces()->indexOf(tag) >= 0) {
        return false;
    }
    set_tag_listing_last_cache(tag_listing_last_cache() + 1);
    workspaces()->insert(tag, index);
    saveLastOpen();
    return true;
}

int Controller::workspacesRemoveTagContainer(int index, void const* sender)
{
    INFO(ControllerLogging) << "Controller::workspacesRemoveTagContainer" << index;
    set_tag_listing_last_cache(tag_listing_last_cache() + 1);
    TagContainer_ container = workspaces()->get(index);
    // need to handle when viewing workspace tab is closed
    // close each tab in workspace_tabs matching this tag
    for (int i = container->count() - 1; i >= 0; i--) {
        Webpage_ w = container->get(i);
        int index = workspace_tabs()->findTabByRefOrUrl(w);
        // if the container has a tab that's opened in a workspace
        if (index >= 0)
        {
            // unless the tab is also opened by some other workspace
            // close this tab
            bool opened_in_other_workspace = false;
            for (int j = workspaces()->count() - 1; j >= 0; j--) {
                TagContainer_ other_container = workspaces()->get(j);
                if (container != other_container && other_container->containsUrl(w->url()))
                {
                    opened_in_other_workspace = true;
                    break;
                }
            }
            if (opened_in_other_workspace) {
                continue;
            }
            if (current_tab_webpage()->url() == w->url()
                    && current_tab_state() == TabStateWorkspace)
            {
                if (open_tabs()->count() > 0) {
                    viewTab(TabStateOpen, 0);
                } else {
                    viewTab(TabStateNull, -1);
                }
            }
            workspace_tabs()->removeTab(index);
        }
    }
    workspaces()->remove(index);
    saveLastOpen();
    return true;
}

int Controller::workspacesMoveTagContainer(int from, int to, void const* sender)
{
    INFO(ControllerLogging) << from << to;
    set_tag_listing_last_cache(tag_listing_last_cache() + 1);
    workspaces()->move(from, 1, to);
    saveLastOpen();
    return true;
}
