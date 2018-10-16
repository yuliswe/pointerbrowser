#import "mac_crawler.hpp"
#import <Foundation/Foundation.h>
#include "global.hpp"

@interface URLSessionDataDelegate : NSObject<NSURLSessionDataDelegate>
{
                                        }
  @end

  @implementation URLSessionDataDelegate

  - (void)URLSession:(NSURLSession *)session
  dataTask:(NSURLSessionDataTask *)dataTask
  didReceiveResponse:(NSURLResponse *)response
  completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    if ([dataTask countOfBytesExpectedToReceive] > 1024
            || [dataTask countOfBytesReceived] > 1024) {
        qCCritical(CrawlerLogging) << "Aborted because the content is oversized.";
        completionHandler(NSURLSessionResponseCancel);
    } else {
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)completionHandler:(NSData*)data
  response: (NSURLResponse*)response
  error:(NSError*) error
  macCrawlerDelegate:(MacCrawlerDelegate*) macCrawlerDelegate
{
    if (error) {
        qCCritical(CrawlerLogging) << "Aborted with error" << error;
        emit macCrawlerDelegate->urlFailed();
        return;
    }
    NSString* html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (! html) {
        html = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
    }
    if (! html) {
        html = [[NSString alloc] initWithData:data encoding:NSWindowsCP1252StringEncoding];
    }
    if (! html) {
        qCCritical(CrawlerLogging) << "Aborted: unknown charset";
        emit macCrawlerDelegate->urlFailed();
        [html release];
        return;
    }
    QString str = QString::fromNSString(html);
    [html release];
    emit macCrawlerDelegate->urlLoaded(str);
}

- (void)URLSession:(NSURLSession *)session
  dataTask:(NSURLSessionDataTask *)dataTask
  willCacheResponse:(NSCachedURLResponse *)proposedResponse
  completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
    completionHandler(NULL);
}

@end

MacCrawlerDelegateFactory::MacCrawlerDelegateFactory()
{
    URLSessionDataDelegate* delegate = [[URLSessionDataDelegate alloc] init];
    NSURLSession* session = [NSURLSession
                            sessionWithConfiguration:NSURLSessionConfiguration.ephemeralSessionConfiguration
                            delegate:delegate delegateQueue:nil];
    set_url_session(session);
}

CrawlerDelegate_ MacCrawlerDelegateFactory::newCrawlerDelegate_()
{
    return shared<MacCrawlerDelegate>(this);
}

MacCrawlerDelegate::MacCrawlerDelegate(MacCrawlerDelegateFactory* factory)
    : m_factory(factory)
{
}

bool MacCrawlerDelegate::loadUrl(const UrlNoHash& uri)
{
    qCDebug(CrawlerLogging) << "MacCrawlerDelegate::loadUrl" << uri;
    NSURLSession* session = static_cast<NSURLSession*>(factory()->url_session());
    NSURL* url = [NSURL URLWithString:uri.base().toNSString()];
    NSURLSessionDataTask* task =
            [session dataTaskWithURL:url
            completionHandler:^void(NSData *data, NSURLResponse *response, NSError *error)
    {
            [session.delegate completionHandler:data response:response error:error macCrawlerDelegate:this];
    }];
[url release];
[task resume];
[task autorelease];
    return true;
}

MacCrawlerDelegateFactory* MacCrawlerDelegate::factory()
{
    return m_factory;
}

MacCrawlerDelegateFactory::~MacCrawlerDelegateFactory()
{
    NSURLSession* session = static_cast<NSURLSession*>(url_session());
    [session invalidateAndCancel];
    [session release];
}

MacCrawlerDelegate::~MacCrawlerDelegate()
{
}
