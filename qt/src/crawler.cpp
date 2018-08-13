#include "crawler.hpp"
#include "global.hpp"
#include <gq/Document.h>
#include <gq/Node.h>

uint qHash(const HtmlLink& link)
{
    return qHash(link.hash) ^ qHash(link.text) ^ qHash(link.url);
}

bool operator==(const HtmlLink& a, const HtmlLink& b)
{
    return a.hash == b.hash && a.text == b.text && a.url == b.url;
}

QDebug& operator<<(QDebug& out, CrawlerRule& rule)
{
    return out << "CrawlerRule" << rule.toString() << ","
               << "domain:" << rule.domain() << ","
               << "valid:" << rule.valid() << ","
               << "regex:" << rule.regex() << ","
               << "enabled:" << rule.enabled() << ","
               << "matched:" << rule.matched();
}

QDebug& operator<<(QDebug& out, CrawlerRuleTable& table)
{
    out << "CrawlerRuleTable" << &table << table.domain() << endl;
    for (CrawlerRule rule : *table.rules())
    {
        out << rule << endl;
    }
    return out;
}

QDebug operator<<(QDebug out, CrawlerRuleTable table)
{
    out << "CrawlerRuleTable" << &table << table.domain() << endl;
    for (CrawlerRule rule : *table.rules())
    {
        out << rule << endl;
    }
    return out;
}

Crawler::Crawler(CrawlerDelegateFactory_ delegateFactory,
                 size_t maxNumThreads,
                 size_t criticalDepth)
    : m_max_num_threads(maxNumThreads)
    , m_critical_depth(criticalDepth)
    , m_delegate_factory(delegateFactory)
    , m_crawler_thread(new QThread)
{
    moveToThread(m_crawler_thread);
    m_delegate_factory->moveToThread(m_crawler_thread);
    m_crawler_thread->start();
}

Crawler::~Crawler()
{
//    m_crawler_thread->quit();
//    delete m_crawler_thread;
}

CrawlerDelegate::~CrawlerDelegate()
{
//    m_delegate_thread.quit();
//    m_delegate_thread.wait();
}

void Crawler::crawlAsync(const UrlNoHash& url)
{
    qInfo() << "Crawler::crawlAsync" << url;
    qInfo() << this->thread()->isRunning() << Global::qCoreApplicationThread->isRunning();
    QMetaObject::invokeMethod(this, "enqueue", Qt::QueuedConnection,
                              Q_ARG(const UrlNoHash&, url),
                              Q_ARG(int, 0));
}

void Crawler::enqueue(const UrlNoHash& uri, int depth)
{
    Q_ASSERT(thread() == QThread::currentThread());
    QSet<UrlNoHash> set;
    set << uri;
    enqueue(set, depth);
}

void Crawler::enqueue(const QSet<UrlNoHash>& urls, int depth)
{
    qInfo() << "Crawler::enqueue" << urls.size() << "links level" << depth;
    QSet<UrlNoHash> filtered;
    for (const UrlNoHash& u : urls)
    {
        int originalDepth = urlDepth(u);
        setUrlDepth(u, depth);
        if (shouldEnqueueUrl(u)) {
            filtered.insert(u);
        } else {
            setUrlDepth(u, originalDepth);
        }
    }
    m_waiting_url.unite(filtered);
    qDebug() << "Crawler::enqueue" << urls.size() << "links" << filtered.size() << "added";

    // spawn a new thread
    spawnMore();
}

// A url is "done" if its symbols are all added to the DB,
// and all its sublinks are added to the DB. The sublinks'
// symbols may or may not have been added to the DB.
bool Crawler::urlIsDone(const UrlNoHash& url)
{
    return m_done_url.contains(url);
}

int Crawler::urlDepth(const UrlNoHash& url)
{
    if (m_url_depth_map.contains(url)) {
        return m_url_depth_map[url];
    }
    return -1;
}

void Crawler::setUrlDepth(const UrlNoHash& url, int depth)
{
    if (depth == -1) {
        m_url_depth_map.remove(url);
        return;
    }
    int current_depth = urlDepth(url);
    if (current_depth == -1) {
        m_url_depth_map[url] = depth;
    } else {
        m_url_depth_map[url] = std::min(depth, current_depth);
    }
}

bool Crawler::urlIsWaiting(const UrlNoHash& url)
{
    return m_waiting_url.contains(url);
}

bool Crawler::urlIsBeingProcessed(const UrlNoHash& url)
{
    return m_processing_url.contains(url);
}

bool Crawler::shouldEnqueueUrl(const UrlNoHash& url)
{
    if (urlIsWaiting(url)) {
        qDebug() << "Crawler::shouldEnqueueUrl skip url because it is in the waiting list" << url;
        return false;
    }
    if (urlIsBeingProcessed(url)) {
        qDebug() << "Crawler::shouldEnqueueUrl skip url because it is being processed" << url;
        return false;
    }
    if (urlIsDone(url)) {
        qDebug() << "Crawler::shouldEnqueueUrl skip url because it is done" << url;
        return false;
    }
    if (urlDepth(url) > m_critical_depth) {
        qDebug() << "Crawler::shouldEnqueueUrl skip url because it is too deep" << url;
        return false;
    }
    if (! rule_table()->hasEnabledAndMatchedRuleForUrl(url)) {
        qDebug() << "Crawler::shouldEnqueueUrl skip url because it is not whitelisted" << url;
        return false;
    }
    return true;
}

Crawler::CrawlAction Crawler::actionForUrl(const UrlNoHash& url)
{
    Q_ASSERT(urlDepth(url) >= 0);
    Q_ASSERT(urlDepth(url) <= m_critical_depth);
    if (urlDepth(url) == m_critical_depth) {
        return SaveUrlTitleAndSymbols;
    }
    return SaveUrlTitleAndSymbolsThenCrawlSublinks;
}

void Crawler::markUrlDone(const UrlNoHash& uri)
{
    QSet<UrlNoHash> set;
    set << uri;
    markUrlDone(set);
}


void Crawler::markUrlFailed(const UrlNoHash& url)
{
    m_waiting_url.remove(url);
    m_processing_url.remove(url);
    m_url_depth_map.remove(url);
}

void Crawler::markUrlDone(const QSet<UrlNoHash>& urls)
{
    m_waiting_url.subtract(urls);
    m_processing_url.subtract(urls);
    m_done_url.unite(urls);
    for (const UrlNoHash& u : urls)
    {
        int r = m_url_depth_map.remove(u);
        if (r != 1) {
            qDebug() << u;
        }
        Q_ASSERT(r == 1);
    }
}

void Crawler::dequeue(const UrlNoHash& uri)
{
    qInfo() << "Crawler::dequeue" << uri;
    m_waiting_url.remove(uri);
}

int Crawler::updateRulesFromSettings()
{
    qInfo() << "Crawler::updateRules";
//    rule_table()->replaceRulesForDomains(other.get());
    set_rule_table(CrawlerRuleTable::readEntireTableFromSettings());
    return 0;
}

QThread* CrawlerDelegate::thread()
{
    return &m_delegate_thread;
}

void Crawler::spawnMore()
{
    while (m_delegate_list.length() < m_max_num_threads
           && ! m_waiting_url.isEmpty())
    {
        spawnOne();
    }
    qDebug() << "Crawler status -"
             << "done:" << m_done_url.size()
             << "processing:" << m_processing_url.size()
             << "waiting:" << m_waiting_url.size()
             << "threads:" << m_delegate_list.size()
             << "maps:" << m_url_depth_map.size();
    Q_ASSERT(m_waiting_url.size() + m_processing_url.size() == m_url_depth_map.size());
//    if (m_waiting_url.isEmpty()
//            && m_processing_url.isEmpty()
//            && m_delegate_list.isEmpty())
//    {
//        qDebug() << m_url_depth_map;
//        qDebug() << m_done_url;
//        m_done_url.clear();
//    }
}

void Crawler::spawnOne()
{
    qInfo() << "Crawler::spawnOne";
    if (m_waiting_url.isEmpty()) {
        qInfo() << "Crawler queue is empty";
        return;
    }
    CrawlerDelegate_ delegate_ = m_delegate_factory->newCrawlerDelegate_();
    CrawlerDelegate* delegate = delegate_.get();
    UrlNoHash url = *m_waiting_url.begin();
    m_waiting_url.remove(url);
    m_processing_url.insert(url);
    m_delegate_list.append(delegate_);
    QObject::connect(delegate->thread(), &QThread::started, delegate, [=]() {
        delegate->loadUrl(url);
    });

    QObject::connect(delegate->thread(), &QThread::finished, this, [=]() {
        int count = m_delegate_list.count();
        int ridx = -1;
        for (int i = 0; i < count; i++) {
            if (m_delegate_list[i].get() == delegate) {
                ridx = i;
                break;
            }
        }
        Q_ASSERT(ridx >= 0);
        m_delegate_list.removeAt(ridx);
        this->spawnMore();
    });

    QObject::connect(delegate, &CrawlerDelegate::urlLoaded, delegate, [=](QString const& html) {
        QPair<QString,QSet<HtmlLink>> parse = CrawlerDelegate::parseHtml(html, url);
        QString const& title = parse.first;
        const QSet<HtmlLink>& links = parse.second;
        QSet<UrlNoHash> hrefs;
        for (const HtmlLink& link : links) {
            hrefs.insert(link.url);
        }
        qDebug() << "Crawler found" << hrefs.count() << "links in" << url << title;
        QMetaObject::invokeMethod(this, "processParseResult",
                                  Q_ARG(const UrlNoHash&, url),
                                  Q_ARG(QString const&, title),
                                  Q_ARG(const QSet<UrlNoHash>&, hrefs),
                                  Q_ARG(const QSet<HtmlLink>&, links));
        delegate->thread()->quit();
    });

    QObject::connect(delegate, &CrawlerDelegate::urlFailed, delegate, [=]() {
        delegate->thread()->quit();
        QMetaObject::invokeMethod(this, "markUrlFailed", Q_ARG(const UrlNoHash&, url));
    });

    delegate->thread()->start();
}

bool Crawler::isProbablySymbol(const HtmlLink& link, const UrlNoHash& base)
{
    if (link.hash.length() > 0
            && link.hash.length() < 32
            && link.text.length() > 0
            && link.text.length() < 32
            && link.url == base)
    {
        return true;
    }
    return false;
}

void Crawler::processParseResult(const UrlNoHash& base, QString const& title, const QSet<UrlNoHash>& sublinks, const QSet<HtmlLink>& links)
{
    qInfo() << "Crawler::processParseResult" << base;
    int current_depth = urlDepth(base);
    if (actionForUrl(base) == SaveUrlTitleAndSymbols
            || actionForUrl(base) == SaveUrlTitleAndSymbolsThenCrawlSublinks)
    {
        Global::searchDB->addWebpageAsync(base.base());
        for (const HtmlLink& link : links)
        {
            if (Crawler::isProbablySymbol(link, base))
            {
                qDebug() << "symbol found" << link;
                Global::searchDB->addWebpageAsync(link.url.base());
                Global::searchDB->addSymbolAsync(link.url.base(), link.hash, link.text);
                Global::searchDB->updateWebpageAsync(link.url.base(), "title", title);
            }
        }
    }
    if (actionForUrl(base) == SaveUrlTitleAndSymbolsThenCrawlSublinks) {
        enqueue(sublinks, current_depth + 1);
    }
    markUrlDone(base);
}

QPair<QString,QSet<HtmlLink>> CrawlerDelegate::parseHtml(QString const& html, const UrlNoHash& baseUrl)
{
    QPair<QString,QSet<HtmlLink>> output;
    CDocument doc;
    doc.parse(html.toStdString());
    CSelection a = doc.find("a");
    CSelection t = doc.find("title");
    if (t.nodeNum() > 0)
    {
        QString title = QString::fromStdString(t.nodeAt(0).text());
        if (title.length() > 0)
        {
            output.first = title;
        }
    }
    QString scheme = baseUrl.scheme();
    QString host = baseUrl.authority();
    for (size_t i = 0; i < a.nodeNum(); i++) {
        CNode n = a.nodeAt(i);
        HtmlLink link;
        QString href = QString::fromStdString(n.attribute("href"));
        if (href.isEmpty()) { continue; }
        QString text = QString::fromStdString(n.text());
        UrlNoHash url(href);
        if (! url.isValid()) { continue; }
        if (url.scheme().isEmpty()) {
            UrlNoHash newUrl;
            if (url.path().isEmpty()) {
                newUrl = baseUrl;
            } else if (url.path()[0] == "/") {
                newUrl = baseUrl.adjusted(QUrl::RemovePath);
            } else {
                newUrl = baseUrl.adjusted(QUrl::RemoveFilename);
            }
            newUrl.setPath(newUrl.path() + url.path());
            newUrl.setQuery(url.query());
            newUrl.setFragment(url.fragment());
            url = newUrl;
        }
        if (url.authority() != baseUrl.authority()) { continue; }
        if (! url.errorString().isEmpty()) {
            qDebug() << url.errorString();
        }
        link.hash = url.fragment();
        link.url = url;
        link.text = text;
        output.second << link;
    }
    return output;
}

QDebug& operator<<(QDebug& debug, const HtmlLink& link)
{
    debug << "HtmlLink:" << link.url << link.hash << link.text;
    return debug;
}

uint qHash(CrawlerRule rule)
{
    return qHash(rule.toString());
}

bool operator==(CrawlerRule a, CrawlerRule b)
{
    return a.toString() == b.toString();
}

CrawlerRule CrawlerRule::defaultRuleForDomain(Url const& url)
{
    return CrawlerRule::fromString(url.domain() + "/*");
}

QString CrawlerRule::toString()
{
    return friendly();
}

CrawlerRule CrawlerRule::fromString(QString const& str)
{
    CrawlerRule rule;
    rule.set_friendly(str);
    if (str.isEmpty()) {
        qCritical() << "CrawlerRule::fromString - empty string is invalid";
        rule.set_valid(false);
        return rule;
    }
    int first_slash = str.indexOf('/');
    int first_star = str.indexOf('*');
    int first_question = str.indexOf('?');
    // if a klee star exists a slash must exist before it
    if (first_star >= 0) {
        if (first_slash >= 0 && first_slash >= first_star)
        {
            qCritical() << "CrawlerRule::fromString - first * is after the first /";
            rule.set_valid(false);
            return rule;
        }
        if (first_question >= 0 && first_question >= first_star)
        {
            qCritical() << "CrawlerRule::fromString - first * is after the first ?";
            rule.set_valid(false);
            return rule;
        }
    }
    // rewrite rule using regex
    // * => .*
    // add ^ and $ for full string match
    // (/*)$ => ($|(/.*$))
    // eg, baidu.com* => invalid (www.baidu.com.*)
    // www.baidu.com => ^www.baidu.com$
    // www.baidu.com/* => ^www.baidu.com($|(/.*$))
    // www.baidu.com/*/test => www.baidu.com/.*/test
    // www.baidu.com?query=* => www.baidu.com?query=.*
    QString regex_str;
    // escape all chars
    for (int i = 0; i < str.length(); i++) {
        if (! str[i].isLetterOrNumber()) {
            regex_str.append('\\');
        }
        regex_str.append(str[i]);
    }
    regex_str.replace("\\*", ".*"); // * => .*
    regex_str.prepend('^');
    regex_str.append("$");
    regex_str.replace("\\/.*$", "($|(\\/.*$))");
    QRegularExpression regex(regex_str);
    regex.setPatternOptions(QRegularExpression::CaseInsensitiveOption);
    rule.set_regex(regex);
    if (first_slash >= 0 && first_question >= 0) {
        int min = first_question < first_slash ? first_question : first_slash;
        rule.set_domain(Url(str.left(min)));
    } else if (first_slash >= 0) {
        rule.set_domain(Url(str.left(first_slash)));
    } else if (first_question >= 0) {
        rule.set_domain(Url(str.left(first_question)));
    } else {
        rule.set_domain(Url(str));
    }
    rule.set_valid(true);
    return rule;
}

CrawlerRule::CrawlerRule(CrawlerRule& other)
    : m_domain(other.domain())
    , m_friendly(other.friendly())
    , m_enabled(other.enabled())
    , m_matched(other.matched())
    , m_valid(other.valid())
    , m_regex(other.regex())
{

}

CrawlerRule::CrawlerRule(CrawlerRule const& other)
    : m_domain(other.m_domain)
    , m_friendly(other.m_friendly)
    , m_enabled(other.m_enabled)
    , m_matched(other.m_matched)
    , m_valid(other.m_valid)
    , m_regex(other.m_regex)
{

}

bool CrawlerRule::matchUrl(Url const& url)
{
    if (! valid()) { return false; }
    QString schemeless = url.schemeless();
    QRegularExpressionMatch matched = regex().match(schemeless);
    return matched.hasMatch();
}

bool CrawlerRuleTable::hasEnabledAndMatchedRuleForUrl(Url const& url)
{
    for (CrawlerRule rule : *rules()) {
        if (rule.enabled() && rule.matchUrl(url)) {
            return true;
        }
    }
    return false;
}

CrawlerRuleTable::CrawlerRuleTable(CrawlerRuleTable& other)
    : m_rules(other.rules())
    , m_domain(other.domain())
{

}

CrawlerRuleTable::CrawlerRuleTable(CrawlerRuleTable const& other)
    : m_rules(other.m_rules)
    , m_domain(other.m_domain)
{

}

void CrawlerRuleTable::replaceRulesForDomains(CrawlerRuleTable* other)
{
    // remove for domain
    for (CrawlerRule other_rule : *other->rules())
    {
        QSet<CrawlerRule> copy = *rules();
        for (CrawlerRule this_rule : copy) {
            if (this_rule.domain() == other_rule.domain())
            {
                rules()->remove(this_rule);
            }
        }
    }
    // insert
    for (CrawlerRule other_rule : *other->rules())
    {
        insertRule(other_rule);
    }
}

void CrawlerRuleTable::writePartialTableToSettings()
{
    qInfo() << "CrawlerRule::writePartialTableToSettings";
    // read table from settings, then merge
    CrawlerRuleTable_ entire = CrawlerRuleTable::readEntireTableFromSettings();
    entire->replaceRulesForDomains(this);
    QVariantMap out;
    for (CrawlerRule rule : *entire->rules())
    {
        out[rule.toString()] = rule.enabled();
    }
    FileManager::writeDataJsonFileM("crawler.json", out);
}

CrawlerRuleTable_ CrawlerRuleTable::readPartialTableFromSettings(Url const& url)
{
    qInfo() << "CrawlerRule::readPartialTableFromSettings" << url;
    QVariantMap in = FileManager::readDataJsonFileM("crawler.json");
    CrawlerRuleTable_ table = CrawlerRuleTable_::create();
    for (QString const& pattern : in.keys())
    {
        CrawlerRule rule = CrawlerRule::fromString(pattern);
        if (! rule.valid()) {
            qCritical() << "CrawlerRule::readPartialTableFromSettings invalid pattern in settings" << pattern;
            continue;
        }
        if (url.domain() == rule.domain()) {
            rule.set_enabled(in[pattern].value<bool>());
            table->insertRule(rule);
        }
    }
    return table;
}

CrawlerRuleTable_ CrawlerRuleTable::readEntireTableFromSettings()
{
    qInfo() << "CrawlerRule::readEntireTableFromSettings";
    QVariantMap in = FileManager::readDataJsonFileM("crawler.json");
    CrawlerRuleTable_ table = CrawlerRuleTable_::create();
    for (QString const& pattern : in.keys())
    {
        CrawlerRule rule = CrawlerRule::fromString(pattern);
        rule.set_enabled(in[pattern].value<bool>());
        table->insertRule(rule);
    }
    return table;
}

//bool CrawlerRuleTable::domainExistsInSettings(Url const& url)
//{
//    CrawlerRuleTable_ partial = CrawlerRuleTable::readPartialTableFromSettings(url);
//    return partial->rulesCount() > 0;
//}

int CrawlerRuleTable::rulesCount()
{
    return rules()->count();
}

bool CrawlerRuleTable::insertRule(CrawlerRule& rule)
{
    qDebug() << "CrawlerRuleTable::insertRule" << rule;
    rules()->insert(rule);
    return true;
}

bool CrawlerRuleTable::removeRule(int idx)
{
    if (idx < 0 || idx >= rules()->count()) {
        qCritical() << "CrawlerRuleTable::removeRule index out of range" << idx << rules();
        return false;
    }
    rules()->remove(*(rules()->begin() + idx));
    return true;
}

//void CrawlerRuleTable::modifyRule(CrawlerRule& old, CrawlerRule& modified)
//{
//    rules()->remove(old);
//    rules()->insert(modified);
//}

bool CrawlerRuleTable::modifyRule(int old, CrawlerRule& modified)
{
    if (old < 0 || old >= rules()->count()) {
        qCritical() << "CrawlerRuleTable::modifyRule index out of range" << old << rules();
        return false;
    }
    rules()->remove(*(rules()->begin() + old));
    rules()->insert(modified);
    return true;
}

CrawlerRuleTable_ CrawlerRuleTable::defaultTableForDomain(Url const& url)
{
    CrawlerRuleTable_ table = CrawlerRuleTable_::create();
    CrawlerRule rule = CrawlerRule::defaultRuleForDomain(url);
    table->insertRule(rule);
    return table;
}

void CrawlerRuleTable::updateAssociatedUrl(Url const& url)
{
    // update matches for each rule
    // rebuild set
    QSharedPointer<QSet<CrawlerRule>> new_set = QSharedPointer<QSet<CrawlerRule>>::create();
    for (auto & old_rule: *rules())
    {
        CrawlerRule new_rule = old_rule;
        new_rule.set_matched(new_rule.matchUrl(url));
        new_set->insert(new_rule);
    }
    set_domain(url.domain());
    set_rules(new_set);
}

CrawlerRule CrawlerRuleTable::rule(int idx)
{
    if (idx < 0 || idx >= rules()->count()) {
        qCritical() << "CrawlerRuleTable::rule index out of range:" << idx;
        return CrawlerRule{};
    }
    return *(rules()->begin() + idx);
}

