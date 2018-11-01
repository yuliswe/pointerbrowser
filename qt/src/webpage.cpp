#include "webpage.hpp"
#include <QtCore/QtCore>
#include "global.hpp"

QDebug& operator<<(QDebug& debug, const FindTextState& state)
{
    return debug << "FindTextState("<< state.visiable << "," << state.current << "/" << state.found << state.text << ")";
}

Webpage::Webpage(QString const& url)
{
    go(url);
}

Webpage::Webpage(Url const& url)
{
    set_url(url);
}

Webpage::Webpage(Url const& url,
                 QString const& title1,
                 QString const& title2,
                 QString const& title3)
{
    set_url(url);
    set_title(title1);
    set_title_2(title2);
    set_title_3(title3);
}

Webpage::Webpage(const QVariantMap& map)
{
    set_url(Url(map["url"].value<QString>()));
    set_title(QString(map["title"].value<QString>()));
}

Webpage::~Webpage() {}

QVariantMap Webpage::toQVariantMap()
{
    QVariantMap map;
    map.insert("title", title());
    map.insert("url", url().full());
    return map;
}

Webpage_ Webpage::fromQVariantMap(const QVariantMap& map)
{
    return shared<Webpage>(map); // use constructor
}

Url Webpage::custom_set_url(Url const& url, void const* sender)
{
    if (! url.isEmpty()) {
        set_title(url.full());
    }
    set_is_blank(url.isBlank());
    return url;
}

bool Webpage::crawlerRuleTableReloadFromSettings()
{
    if (url().isEmpty()) { return false; }
    CrawlerRuleTable_ table = CrawlerRuleTable::readPartialTableFromSettings(url());
    if (table->rulesCount() == 0) {
        table = CrawlerRuleTable::defaultTableForDomain(url());
    }
    table->updateAssociatedUrl(url());
    set_crawler_rule_table(table);
    return true;
}

QString Webpage::custom_set_title(QString const& title, void const* sender)
{
    QString trimmed = title;
    trimmed.replace(QRegularExpression("\\s+"), " ");
    if (trimmed.isEmpty()) {
        qCDebug(WebpageLogging) << "title is empty, use url" << url().full() << "instead";
        return url().full();
    } else {
        return trimmed;
    }
}

int Webpage::go(QString const& input)
{
    qCInfo(WebpageLogging) << "Webpage::go" << input;
    handleUrlChanged(Url::fromAmbiguousText(input));
    return 0;
}

int Webpage::handleUrlChanged(Url const& url, void const* sender)
{
    qCInfo(WebpageLogging) << "handleUrlChanged" << url;
    set_url(url, sender);
    if (is_blank() || is_error()) {
        findClear();
    }
    return 0;
}

void Webpage::findNext(QString const& txt)
{
    bool restart = txt != find_text_state().text;
    FindTextState newState = find_text_state();
    FindTextState oldState = find_text_state();
    if (txt.isEmpty()) {
        newState.current = -1;
        newState.found = -1;
        emit_tf_find_clear();
    } else if (oldState.found <= 0) {
        newState.current = -1;
    } else if (oldState.current == oldState.found - 1) {
        newState.current = 0;
    } else {
        newState.current = oldState.current + 1;
    }
    newState.text = txt;
    set_find_text_state(newState);
    if (txt.isEmpty()) { return; }
    if (restart) {
        emit_tf_find_highlight_all(txt);
    } else {
        emit_tf_find_scroll_to_next_highlight(newState.current);
    }
}

void Webpage::findPrev(QString const& txt)
{
    FindTextState newState = find_text_state();
    FindTextState oldState = find_text_state();
    bool restart = txt != find_text_state().text;
    if (txt.isEmpty() || restart) {
        newState.current = -1;
        newState.found = -1;
        emit_tf_find_clear();
    } else if (oldState.found <= 0) {
        newState.current = -1;
    } else if (oldState.current <= 0) {
        newState.current = oldState.found - 1;
    } else {
        newState.current = oldState.current - 1;
    }
    newState.text = txt;
    set_find_text_state(newState);
    if (txt.isEmpty()) { return; }
    if (restart) {
        emit_tf_find_highlight_all(txt);
    } else {
        emit_tf_find_scroll_to_prev_highlight(newState.current);
    }
}

void Webpage::findClear()
{
    FindTextState newState;
    set_find_text_state(newState);
    emit_tf_find_clear();
}

int Webpage::updateFindTextFound(int nfound)
{
    FindTextState newState = find_text_state();
    FindTextState oldState = find_text_state();
    newState.found = nfound;
    // if found new, focus on new
    if (oldState.found <= 0 && nfound > 0) {
        newState.current = 0;
        emit_tf_find_scroll_to_next_highlight(0);
    }
    set_find_text_state(newState);
    return 0;
}

bool Webpage::crawlerRuleTableInsertRule(CrawlerRule& rule)
{
    qCInfo(WebpageLogging) << "Webpage::crawlerRuleTableInsertRule" << rule;
    if (! rule.valid())
    {
        qCCritical(WebpageLogging) << "Webpage::crawlerRuleTableInsertRule rule is invalid" << rule;
        return false;
    }
    if (rule.domain() != url().domain())
    {
        qCCritical(WebpageLogging) << "Webpage::crawlerRuleTableInsertRule rule"
                    << rule;
        qCCritical(WebpageLogging) << "does not match the domain"
                    << url();
        return false;
    }
    CrawlerRuleTable_ table = crawler_rule_table();
    table->insertRule(rule);
    table->updateAssociatedUrl(url());
    set_crawler_rule_table(table);
    return true;
}


bool Webpage::crawlerRuleTableRemoveRule(int idx)
{
    qCInfo(WebpageLogging) << "Webpage::crawlerRuleTableInsertRule" << idx;
    CrawlerRuleTable_ table = crawler_rule_table();
    if (! table->removeRule(idx))
    {
        return false;
    }
    set_crawler_rule_table(table);
    return true;
}

bool Webpage::crawlerRuleTableModifyRule(int old, CrawlerRule& modified)
{
    qCInfo(WebpageLogging) << "Webpage::crawlerRuleTableModifyRule" << old << modified;
    if (! modified.valid())
    {
        qCCritical(WebpageLogging) << "Webpage::crawlerRuleTableModifyRule rule is invalid" << modified;
        return false;
    }
    if (modified.domain() != url().domain())
    {
        qCCritical(WebpageLogging) << "Webpage::crawlerRuleTableModifyRule rule" << modified.toString() << "does not belong to the domain" << url();
        return false;
    }
    CrawlerRuleTable_ table = crawler_rule_table();
    table->modifyRule(old, modified);
    table->updateAssociatedUrl(url());
    set_crawler_rule_table(table);
    return true;
}

CrawlerRuleTable_ Webpage::custom_set_crawler_rule_table(CrawlerRuleTable_ const& tb, void const* sender)
{
    tb->updateAssociatedUrl(url());
    return tb;
}

int Webpage::handleError(QString const& error, void const* sender)
{
    qCInfo(WebpageLogging) << "handleError" << error;
    set_error(error);
    set_is_error(true);
    return true;
}

int Webpage::handleSuccess(void const* sender)
{
    qCInfo(WebpageLogging) << "handleSuccess";
    set_error("Unknown");
    set_is_error(false);
    return true;
}

QString Webpage::errorPageHtml(QString const& message)
{
    return "<html><body>" + message + "</body></html>";
}
