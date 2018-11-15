#include <QtCore/QtCore>
#include <iostream>
#include "docviewer.h"

using namespace std;

QString getLine()
{
    string u;
    QString txt;
    do {
        getline(std::cin, u);
        txt = QString::fromStdString(u).trimmed();
    } while (txt.isEmpty());
    return txt;
}

int main(int argc, char *argv[])
{
    QStringList ls;
    for (int i = 0; i < argc; i++) {
        ls << QString(argv[i]);
    }
    Global::startQCoreApplicationThread(argc, ls);

    while (cin.good()) {
        string c;
        cin >> c;
        if (c == "status") {
            int count = Global::controller->open_tabs()->count();
            cout << "Current open tabs:" << endl
                 << "- count: " << count << endl;
            for (int i = 0; i < count; i++) {
                if (i == Global::controller->current_open_tab_highlight_index()) {
                    cout << "*";
                } else {
                    cout << "-";
                }
                cout << " " << i << " "
                     << Global::controller->open_tabs()->webpage_(i)->title().toStdString()
                     << endl;
            }
            continue;
        }
        else if (c == "new") {
            cout << "Create new tab to home" << endl;
            Global::controller->newTabAsync();
            continue;
        }
        else if (c == "google") {
            cout << "Google search: waiting for text to search" << endl;
            string c;
            cin >> c;
            int i = Global::controller->newTabBlocking(Controller::TabStateOpen,
                                                            Global::controller->home_url(),
                                                            Controller::WhenCreatedViewNew,
                                                            Controller::WhenExistsViewExisting);
            Global::controller->currentTabWebpageGoAsync(QString::fromStdString(c));
            continue;
        }
        else if (c == "tab" || c == "view") {
            qInfo() << "View open tab ? (waiting for an int)";
            int i;
            cin >> i;
            int _i = Global::controller->viewTabBlocking(Controller::TabStateOpen, i);
            qInfo() << "Switched to tab" << _i;
            continue;
        }
        else if (c == "close") {
            qInfo() << "Close tab #? (waiting for an int)";
            int i;
            cin >> i;
            Global::controller->closeTabAsync(Controller::TabStateOpen, i);
            continue;
        }
        else if (c == "go" || c == "goto") {
            qInfo() << "Make current tab go to ? (waiting for a url)";
            Global::controller->currentTabWebpageGoAsync(getLine());
            continue;
        }
        else if (c == "search") {
            qInfo() << "Search in DB ? (waiting for a string)";
            Global::searchDB->searchAsync(getLine());
            continue;
        }
        else if (c == "rules") {
            qInfo() << *Global::controller->current_webpage_crawler_rule_table();
            continue;
        }
        else if (c == "rules-a") {
            qInfo() << "Add a url pattern? (waiting for a string)";
            CrawlerRule rule = CrawlerRule::fromString(getLine());
            Global::controller->currentTabWebpageCrawlerRuleTableInsertRuleAsync(rule);
            qInfo() << *Global::controller->current_webpage_crawler_rule_table();
            continue;
        }
        else if (c == "rules-r") {
            qInfo() << "Remove a url pattern? (waiting for an int)";
            qInfo() << *Global::controller->current_webpage_crawler_rule_table();
            int i;
            cin >> i;
            Global::controller->currentTabWebpageCrawlerRuleTableRemoveRuleAsync(i);
            qInfo() << *Global::controller->current_webpage_crawler_rule_table();
            continue;
        }
        else if (c == "rules-m") {
            qInfo() << "Modify which pattern? (waiting for index)";
            qInfo() << *Global::controller->current_webpage_crawler_rule_table();
            int idx;
            cin >> idx;
            qInfo() << "New url pattern? (waiting for a string)";
            CrawlerRule modified = CrawlerRule::fromString(getLine());
            Global::controller->currentTabWebpageCrawlerRuleTableModifyRuleAsync(idx, modified);
            qInfo() << *Global::controller->current_webpage_crawler_rule_table();
            continue;
        }
        else if (c == "rules-e") {
            qInfo() << "Enable which pattern? (waiting for index)";
            qInfo() << *Global::controller->current_webpage_crawler_rule_table();
            int idx;
            cin >> idx;
            CrawlerRule modified = Global::controller->current_webpage_crawler_rule_table()->rule(idx);
            modified.set_enabled(true);
            Global::controller->currentTabWebpageCrawlerRuleTableModifyRuleAsync(idx, modified);
            qInfo() << *Global::controller->current_webpage_crawler_rule_table();
            continue;
        }
        else if (c == "rules-d") {
            qInfo() << "Enable which pattern? (waiting for index)";
            qInfo() << *Global::controller->current_webpage_crawler_rule_table();
            int idx;
            cin >> idx;
            qInfo() << "New url pattern? (waiting for a string)";
            CrawlerRule modified = Global::controller->current_webpage_crawler_rule_table()->rule(idx);
            modified.set_enabled(false);
            Global::controller->currentTabWebpageCrawlerRuleTableModifyRuleAsync(idx, modified);
            qInfo() << *Global::controller->current_webpage_crawler_rule_table();
            continue;
        }
        else if (c == "links") {
            cout << "Retriving links in current webpage" << endl;
            Global::crawler->crawlAsync(UrlNoHash(Global::controller->current_tab_webpage()->url()));
            continue;
        }
        else if (c == "lsd") {
            cout << "Downloads:" << endl;
            Global::controller->download_files()->loadDirectoryContentsBlocking("/Users/ylilarry/Downloads");
            for (int i = 0; i < Global::controller->download_files()->count(); i++)
            {
                File_ f = Global::controller->download_files()->get(i);
                qInfo() << i << " " << *f;
            }
            continue;
        }
        else if (c == "tags") {
            cout << "Tags:" << endl;
            Global::controller->tags();
            for (int i = 0; i < Global::controller->tags()->count(); i++)
            {
                TagContainer_ container = Global::controller->tags()->get(i);
                qInfo() << container->title();
            }
            continue;
        }
        else if (c == "tags-c") {
            Global::controller->createTagContainerAsync("new tag", 0, Global::controller->current_tab_webpage());
            continue;
        }
        else if (c == "tags-r") {
            cout << "Remove a tag? (Waiting for an index.)" << endl;
            int index;
            cin >> index;
            Global::controller->removeTagContainerAsync(index);
            continue;
        }
        else if (c == "tags-n") {
            cout << "Rename a tag? (Waiting for a new name string.)" << endl;
            string name;
            cin >> name;
            TagContainer_ container = Global::controller->tags()->get(0);
            Global::controller->renameTagContainerAsync(container, QString::fromStdString(name));
            continue;
        }
        else if (c == "q" || c == "quit" || c == "exit") {
            qInfo() << "Exiting...";
            break;
        }
    }

    Global::stopQCoreApplicationThread();
}
