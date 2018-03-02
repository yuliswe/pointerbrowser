#ifndef OFFLINE_CRAWLER_HPP
#define OFFLINE_CRAWLER_HPP

#include <QtCore/QtCore>
#include "crawler.hpp"
#include "global.hpp"
#include "url.hpp"

class OfflineCrawlerDelegate : public CrawlerDelegate
{
    Q_OBJECT
public:
    virtual ~OfflineCrawlerDelegate() override;

public slots:
    virtual bool loadUrl(const UrlNoHash&) override;
};

typedef std::shared_ptr<OfflineCrawlerDelegate> OfflineCrawlerDelegate_;

class OfflineCrawlerDelegateFactory : public CrawlerDelegateFactory
{
    Q_OBJECT
public:
    virtual CrawlerDelegate_ newCrawlerDelegate_() override;
};

typedef QSharedPointer<OfflineCrawlerDelegateFactory> OfflineCrawlerDelegateFactory_;

#endif // OFFLINE_CRAWLER_HPP
