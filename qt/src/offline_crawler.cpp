#include "offline_crawler.hpp"

bool OfflineCrawlerDelegate::loadUrl(const UrlNoHash& url)
{
    static int count = 0;
    qInfo() << "OfflineCrawlerDelegate::loadUrl" << url;
    QThread* worker = QThread::create([=]() {
        QThread::sleep(1);
        QString html = "<html>";
        for (int i = 0; i < 1000; i++)
        {
            html += "<a href='https://domain.com/" + QString::number(count + i) + "'>test</a>";
        }
        html += "</html>";
        emit urlLoaded(html);
    });
    QObject::connect(worker, &QThread::finished, worker, &QThread::deleteLater);
    worker->start();
    count += 250;
    return true;
}

OfflineCrawlerDelegate::~OfflineCrawlerDelegate()
{
    qDebug() << "~OfflineCrawlerDelegate";
}

CrawlerDelegate_ OfflineCrawlerDelegateFactory::newCrawlerDelegate_()
{
    return shared<OfflineCrawlerDelegate>();
}
