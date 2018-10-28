#ifndef WEBPAGE_H
#define WEBPAGE_H

#include <QtCore/QtCore>
#include "macros.hpp"
#include "url.hpp"
#include "crawler.hpp"
#include "logging.hpp"


class Webpage;
typedef std::shared_ptr<Webpage> Webpage_;
typedef QList<Webpage_> Webpage_List;

struct FindTextState
{
    QString text = "";
    bool visiable = false;
    int found = -1;
    int current = -1;
};
typedef std::shared_ptr<FindTextState> FindTextState_;

QDebug& operator<<(QDebug&, const FindTextState&);

class Webpage : public QObject
{
    friend class Controller;
//    friend class TabsModel;
//    friend class SearchDB;
    friend class SearchWorker;
    Q_OBJECT

    void findNext(QString const&);
    void findPrev(QString const&);
    void findClear();

    int updateFindTextFound(int);

    int go(QString const&);
    int handleUrlChanged(Url const&, void const* = nullptr);
    bool crawlerRuleTableModifyRule(int, CrawlerRule&);
    bool crawlerRuleTableInsertRule(CrawlerRule&);
    bool crawlerRuleTableRemoveRule(int);
    bool crawlerRuleTableReloadFromSettings();

public:

    virtual ~Webpage();
    Webpage() = default;
    Webpage(QString const& url);
    Webpage(Url const& url);
    Webpage(Url const& uri, QString const& title, QString const& title_2, QString const& title_3);
    explicit Webpage(const QVariantMap&);

    QVariantMap toQVariantMap();
    static Webpage_ fromQVariantMap(const QVariantMap&);
    static QString errorPageHtml(QString const& message);

    PROP_DEF_BEGINS
    PROP_R_N_D(Url, url, QString(""))
    PROP_RwN_D(QString, title, "")
    PROP_RN_D(QString, title_2, "")
    PROP_RN_D(QString, title_3, "")
    PROP_RN_D(bool, is_blank, true)
    PROP_RN_D(bool, is_error, false)
    PROP_RN_D(QString, error, "")
    PROP_RWN_D(bool, can_go_forward, false)
    PROP_RWN_D(bool, can_go_back, false)
    PROP_RWN_D(float, load_progress, 0)
    PROP_RWN_D(QString, html, "")
    PROP_RN_D(FindTextState, find_text_state, FindTextState{})
    PROP_R_N_D(CrawlerRuleTable_, crawler_rule_table, CrawlerRuleTable_::create())
    PROP_DEF_ENDS

    METH_ASYNC_1(int, handleError, QString const&)
    METH_ASYNC_0(int, handleSuccess)

    // tells frontend (tf) to...
    SIG_TF_0(back)
    SIG_TF_0(forward)
    SIG_TF_0(refresh)
    SIG_TF_0(stop)
    SIG_TF_1(find_scroll_to_next_highlight, int)
    SIG_TF_1(find_scroll_to_prev_highlight, int)
    SIG_TF_0(find_clear)
    SIG_TF_1(find_highlight_all, QString const&)
};

Q_DECLARE_METATYPE(Webpage*)
Q_DECLARE_METATYPE(Webpage_)
#endif // WEBPAGE_H
