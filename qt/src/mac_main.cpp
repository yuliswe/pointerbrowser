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
            int i = Global::controller->newTabAsyncBlocking(Controller::TabStateOpen,
                                                            Global::controller->home_url(),
                                                            Controller::WhenCreatedViewNew,
                                                            Controller::WhenExistsViewExisting);
            Webpage_ w = Global::controller->open_tabs()->webpage_(i);
            w->goAsync(getLine());
            continue;
        }
        else if (c == "tab" || c == "view") {
            qCInfo() << "View open tab ? (waiting for an int)";
            int i;
            cin >> i;
            int _i = Global::controller->viewTabAsyncBlocking(Controller::TabStateOpen, i);
            qCInfo() << "Switched to tab" << _i;
            continue;
        }
        else if (c == "close") {
            qCInfo() << "Close tab #? (waiting for an int)";
            int i;
            cin >> i;
            Global::controller->closeTabAsync(Controller::TabStateOpen, i);
            continue;
        }
        else if (c == "go" || c == "goto") {
            qCInfo() << "Make current tab go to ? (waiting for a url)";
            Global::controller->currentTabWebpageGoAsync(getLine());
            continue;
        }
        else if (c == "search") {
            qCInfo() << "Search in DB ? (waiting for a string)";
            Global::searchDB->searchAsync(getLine());
            continue;
        }
        else if (c == "rules") {
            qCInfo() << *Global::controller->current_webpage_crawler_rule_table();
            continue;
        }
        else if (c == "rules-a") {
            qCInfo() << "Add a url pattern? (waiting for a string)";
            CrawlerRule rule = CrawlerRule::fromString(getLine());
            Global::controller->currentTabWebpageCrawlerRuleTableInsertRuleAsync(rule);
            qCInfo() << *Global::controller->current_webpage_crawler_rule_table();
            continue;
        }
        else if (c == "rules-r") {
            qCInfo() << "Remove a url pattern? (waiting for an int)";
            qCInfo() << *Global::controller->current_webpage_crawler_rule_table();
            int i;
            cin >> i;
            Global::controller->currentTabWebpageCrawlerRuleTableRemoveRuleAsync(i);
            qCInfo() << *Global::controller->current_webpage_crawler_rule_table();
            continue;
        }
        else if (c == "rules-m") {
            qCInfo() << "Modify which pattern? (waiting for index)";
            qCInfo() << *Global::controller->current_webpage_crawler_rule_table();
            int idx;
            cin >> idx;
            qCInfo() << "New url pattern? (waiting for a string)";
            CrawlerRule modified = CrawlerRule::fromString(getLine());
            Global::controller->currentTabWebpageCrawlerRuleTableModifyRuleAsync(idx, modified);
            qCInfo() << *Global::controller->current_webpage_crawler_rule_table();
            continue;
        }
        else if (c == "rules-e") {
            qCInfo() << "Enable which pattern? (waiting for index)";
            qCInfo() << *Global::controller->current_webpage_crawler_rule_table();
            int idx;
            cin >> idx;
            qCInfo() << "New url pattern? (waiting for a string)";
            CrawlerRule modified = Global::controller->current_webpage_crawler_rule_table()->rule(idx);
            modified.set_enabled(true);
            Global::controller->currentTabWebpageCrawlerRuleTableModifyRuleAsync(idx, modified);
            qCInfo() << *Global::controller->current_webpage_crawler_rule_table();
            continue;
        }
        else if (c == "rules-d") {
            qCInfo() << "Enable which pattern? (waiting for index)";
            qCInfo() << *Global::controller->current_webpage_crawler_rule_table();
            int idx;
            cin >> idx;
            qCInfo() << "New url pattern? (waiting for a string)";
            CrawlerRule modified = Global::controller->current_webpage_crawler_rule_table()->rule(idx);
            modified.set_enabled(false);
            Global::controller->currentTabWebpageCrawlerRuleTableModifyRuleAsync(idx, modified);
            qCInfo() << *Global::controller->current_webpage_crawler_rule_table();
            continue;
        }
        else if (c == "links") {
            cout << "Retriving links in current webpage" << endl;
//                            Webpage* w = Global::controller->current_tab_webpage();
//                            Global::controller->currentTabWebpageCrawlAsync();
            continue;
        }
        else if (c == "q" || c == "quit" || c == "exit") {
            qCInfo() << "Exiting...";
            break;
        }
    }

    Global::stopQCoreApplicationThread();
}
