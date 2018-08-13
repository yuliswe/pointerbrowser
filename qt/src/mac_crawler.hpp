#ifndef MAC_CRAWLER_H
#define MAC_CRAWLER_H

#include <QtCore/QtCore>
#include "crawler.hpp"
#include "macros.hpp"

using namespace std;

class MacCrawlerDelegateFactory;

class MacCrawlerDelegate : public CrawlerDelegate
{
    MacCrawlerDelegateFactory* m_factory;
    Q_OBJECT
public:
    virtual ~MacCrawlerDelegate() override;
    MacCrawlerDelegate(MacCrawlerDelegateFactory* factory);
    MacCrawlerDelegateFactory* factory();

public slots:
    virtual bool loadUrl(const UrlNoHash&) override;
};

//Q_DECLARE_METATYPE(MacCrawlerDelegate);
typedef std::shared_ptr<MacCrawlerDelegate> MacCrawlerDelegate_;

class MacCrawlerDelegateFactory : public CrawlerDelegateFactory
{
    Q_OBJECT
    PROP_DEF_BEGINS
    PROP_RN_D(void*, url_session, nullptr)
    PROP_DEF_ENDS
//    QMap<unsigned long, void> m_data_map;
public:
    MacCrawlerDelegateFactory();
    virtual ~MacCrawlerDelegateFactory() override;
    virtual CrawlerDelegate_ newCrawlerDelegate_() override;
//    QMap<unsigned long, void*>& data_map();
};

typedef QSharedPointer<MacCrawlerDelegateFactory> MacCrawlerDelegateFactory_;


#endif // MAC_CRAWLER_H
