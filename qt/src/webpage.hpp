#ifndef WEBPAGE_H
#define WEBPAGE_H

#include <QtCore/QtCore>
#include "macros.hpp"
#include "url.hpp"
#include "crawler.hpp"
#include "logging.hpp"
#include "stringutils.hpp"

class Webpage;
typedef std::shared_ptr<Webpage> Webpage_;
typedef QList<Webpage_> Webpage_List;
class Controller;
class TabsModel;
typedef std::shared_ptr<TabsModel> TabsModel_;
class TagContainer;
typedef QSharedPointer<TagContainer> TagContainer_;

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
    friend class TabsModel;
//    friend class SearchDB;
    friend class SearchWorker;
    friend class Crawler;
    friend class TagContainer;
    Q_OBJECT

    void findNext(QString const&);
    void findPrev(QString const&);
    void findClear();

    int updateFindTextFound(int);

    int go(QString const&);
    int handleUrlDidChange(Url const&, void const* = nullptr);
    bool crawlerRuleTableModifyRule(int, CrawlerRule&);
    bool crawlerRuleTableInsertRule(CrawlerRule&);
    bool crawlerRuleTableRemoveRule(int);
    bool crawlerRuleTableReloadFromSettings();
    void highlightTitle(QSet<QString> const&);

public:

    enum LoadingState
    {
        LoadingStateBlank,
        LoadingStateError,
        LoadingStateLoaded,
        LoadingStateLoading,
        LoadingStateHttpUserConscentRequired
    };
    Q_ENUM(LoadingState)

    virtual ~Webpage();
    Webpage() = default;
    Webpage(Webpage_);
    Webpage(QString const& url);
    Webpage(Url const& url);
    Webpage(Url const& uri, QString const& title, QString const& title_2, QString const& title_3);
    explicit Webpage(const QVariantMap&);
    void loadUrl(Url const&);

    QVariantMap toQVariantMap();
    static Webpage_ fromQVariantMap(const QVariantMap&);
    static QString errorPageHtml(QString const& message);

    PROP_DEF_BEGINS
    PROP_R_N_D(Url, url, QString(""))
    PROP_R_N_D(QString, title, "")
    PROP_RN_D(RangeSet, title_highlight_range, RangeSet())
    PROP_RN_D(QString, title_2, "")
    PROP_RN_D(RangeSet, title_2_highlight_range, RangeSet())
    PROP_RN_D(QString, title_3, "")
    PROP_RN_D(RangeSet, title_3_highlight_range, RangeSet())

    PROP_RWN_D(Webpage::LoadingState, loading_state, Webpage::LoadingStateBlank)
    PROP_RWN_D(bool, is_secure, true)
    PROP_RN_D(bool, show_bookmark_on_blank, false)
    PROP_RN_D(bool, allow_http, false)
    PROP_RWN_D(bool, is_pdf, false)
    PROP_RWN_D(bool, is_for_download, false)
    PROP_RN_D(QString, error, "")
    PROP_RWN_D(bool, can_go_forward, false)
    PROP_RWN_D(uint, tab_state, 0)
    PROP_RWN_D(bool, can_go_back, false)
    PROP_RWN_D(float, load_progress, 0)
    PROP_RWN_D(void*, associated_frontend_webview_object, nullptr)
    PROP_RWN_D(void*, associated_frontend_tab_object, nullptr)
    PROP_RN_D(TabsModel*, associated_tabs_model, nullptr)
    PROP_RN_D(TagContainer*, associated_tag_container, nullptr)
    PROP_RWN_D(QString, offline_html, "")
    PROP_RWN_D(bool, should_use_offline_html, false)
    PROP_RN_D(FindTextState, find_text_state, FindTextState{})
    PROP_R_N_D(CrawlerRuleTable_, crawler_rule_table, CrawlerRuleTable_::create())
    PROP_DEF_ENDS

    METH_ASYNC_1(int, handleError, QString const&)
    METH_ASYNC_0(int, handleSuccess)
    METH_ASYNC_0(int, handleLoadingDidStart)

    // tells frontend (tf) to...
    SIG_TF_0(back)
    SIG_TF_0(forward)
    SIG_TF_0(refresh)
    SIG_TF_0(stop)
    SIG_TF_1(load, Url const&)
    SIG_TF_1(find_scroll_to_next_highlight, int)
    SIG_TF_1(find_scroll_to_prev_highlight, int)
    SIG_TF_0(find_clear)
    SIG_TF_1(find_highlight_all, QString const&)
};

Q_DECLARE_METATYPE(Webpage*)
Q_DECLARE_METATYPE(Webpage_)
Q_DECLARE_METATYPE(Webpage::LoadingState)
#endif // WEBPAGE_H
