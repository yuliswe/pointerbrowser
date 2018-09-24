#ifndef CRAWLERDELEGATE_H
#define CRAWLERDELEGATE_H

#include <QtCore/QtCore>
#include "url.hpp"
#include "macros.hpp"

extern QLoggingCategory CrawlerRuleLogging;
extern QLoggingCategory CrawlerRuleTableLogging;
extern QLoggingCategory CrawlerLogging;

class Webpage;
class Crawler;
class CrawlerRuleTable;
class Controller;

class CrawlerRule : public QObject
{
    Q_OBJECT

    PROP_DEF_BEGINS
    PROP_RN_D(Url, domain, QStringLiteral(""))
    PROP_N_D(QString, friendly, QStringLiteral(""))
    PROP_RWN_D(bool, enabled, false)
    PROP_RWN_D(bool, matched, false)
    PROP_RN_D(bool, valid, false)
    PROP_RN_D(QRegularExpression, regex, QRegularExpression{})
    PROP_DEF_ENDS

public:
    CrawlerRule() = default;
    CrawlerRule(CrawlerRule&);
    CrawlerRule(CrawlerRule const&);
    static CrawlerRule fromString(QString const&);
    static CrawlerRule defaultRuleForDomain(Url const&);
    QString toString();
    bool matchUrl(Url const&);
    virtual ~CrawlerRule() = default;
};

Q_DECLARE_METATYPE(CrawlerRule)
uint qHash(CrawlerRule&);
bool operator==(CrawlerRule&, CrawlerRule&);
QDebug& operator<<(QDebug&, CrawlerRule&);

class CrawlerRuleTable : public QObject
{
    Q_OBJECT
    friend Webpage;
    friend CrawlerRule;
    friend Crawler;
    friend Controller;

    PROP_DEF_BEGINS
    PROP_RN_D(QSharedPointer<QSet<CrawlerRule>>, rules, QSharedPointer<QSet<CrawlerRule>>::create())
    PROP_RN_D(Url, domain, Url{})
    PROP_DEF_ENDS

protected:
    static QSharedPointer<CrawlerRuleTable> defaultTableForDomain(Url const&);
//    static bool domainExistsInSettings(Url const&);
    void writePartialTableToSettings();
    static QSharedPointer<CrawlerRuleTable> readPartialTableFromSettings(Url const&);
    static QSharedPointer<CrawlerRuleTable> readEntireTableFromSettings();
    void replaceRulesForDomains(CrawlerRuleTable*);
    bool insertRule(CrawlerRule&);
    bool removeRule(int);
//    void modifyRule(CrawlerRule&, CrawlerRule&);
    bool modifyRule(int, CrawlerRule&);
    void updateAssociatedUrl(Url const&);
    bool hasEnabledAndMatchedRuleForUrl(Url const&);

public:
    CrawlerRuleTable() = default;
    CrawlerRuleTable(CrawlerRuleTable&);
    CrawlerRuleTable(CrawlerRuleTable const&);
    virtual ~CrawlerRuleTable() = default;
    int rulesCount();
    CrawlerRule rule(int);
};

typedef QSharedPointer<CrawlerRuleTable> CrawlerRuleTable_;
Q_DECLARE_METATYPE(CrawlerRuleTable)
QDebug& operator<<(QDebug&, CrawlerRuleTable&);
QDebug operator<<(QDebug, CrawlerRuleTable);

struct HtmlLink {
    UrlNoHash url;
    QString text;
    QString hash;
};
uint qHash(const HtmlLink&);
bool operator==(const HtmlLink&, const HtmlLink&);
QDebug& operator<<(QDebug&, const HtmlLink&);
Q_DECLARE_METATYPE(HtmlLink)

class CrawlerDelegate : public QObject {
    Q_OBJECT
protected:
    QThread m_delegate_thread;
public:
    CrawlerDelegate() = default;
    virtual ~CrawlerDelegate();
    static QPair<QString,QSet<HtmlLink>> parseHtml(QString const& html, const UrlNoHash& baseUri);
    QThread* thread();
public slots:
    virtual bool loadUrl(const UrlNoHash&) = 0;
signals:
    void urlLoaded(QString const& html);
    void urlFailed();
};

typedef std::shared_ptr<CrawlerDelegate> CrawlerDelegate_;

class CrawlerDelegateFactory : public QObject {
    Q_OBJECT
public:
    virtual ~CrawlerDelegateFactory() = default;
    virtual CrawlerDelegate_ newCrawlerDelegate_() = 0;
};

typedef QSharedPointer<CrawlerDelegateFactory> CrawlerDelegateFactory_;

class Crawler : public QObject {
    Q_OBJECT
    size_t m_max_num_threads;
    size_t m_critical_depth;
    QSet<UrlNoHash> m_waiting_url;
    QSet<UrlNoHash> m_processing_url;
    QSet<UrlNoHash> m_done_url;
    QList<CrawlerDelegate_> m_delegate_list;
    CrawlerDelegateFactory_ m_delegate_factory;
    QMap<UrlNoHash, int> m_url_depth_map;
    // all private members should be on this thread
    // the thread itself is on the main thread
    QThread* const m_crawler_thread;
    QString m_rules_file = "discovery.json";

    PROP_DEF_BEGINS
    PROP_RN_D(CrawlerRuleTable_, rule_table, CrawlerRuleTable::readEntireTableFromSettings())
    PROP_DEF_ENDS

    enum CrawlAction {
        SaveUrlTitle,
        SaveUrlTitleAndSymbols,
        SaveUrlTitleAndSymbolsThenCrawlSublinks
    };

    bool shouldEnqueueUrl(const UrlNoHash&);
    CrawlAction actionForUrl(const UrlNoHash& url);

public:
    Crawler(CrawlerDelegateFactory_ delegateFactory, size_t maxNumThreads, size_t criticalDepth);
    ~Crawler();
    void crawlAsync(const UrlNoHash&);
    METH_ASYNC_0(int, updateRulesFromSettings)

protected slots:
    void dequeue(const UrlNoHash& url);
    void markUrlDone(const UrlNoHash& url);
    void markUrlDone(const QSet<UrlNoHash>& uri);
    void markUrlFailed(const UrlNoHash& url);
    // A url is "done" if its symbols are all added to the DB,
    // and all its sublinks are added to the DB. The sublinks'
    // symbols may or may not have been added to the DB.
    bool urlIsDone(const UrlNoHash&);
    bool urlIsWaiting(const UrlNoHash&);
    bool urlIsBeingProcessed(const UrlNoHash&);
    int urlDepth(const UrlNoHash& url);
    void setUrlDepth(const UrlNoHash& url, int depth);
    void enqueue(const QSet<UrlNoHash>& uri, int depth);
    void enqueue(const UrlNoHash& url, int depth);
    void spawnMore();
    void spawnOne();

    void processParseResult(const UrlNoHash&, QString const&, const QSet<UrlNoHash>&, const QSet<HtmlLink>&);
    static bool isProbablySymbol(const HtmlLink&, const UrlNoHash&);
};

//Q_DECLARE_METATYPE(Crawler)

#endif // CRAWLERDELEGATE_H
