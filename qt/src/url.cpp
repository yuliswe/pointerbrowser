#include "url.hpp"

Url::Url(QString const& url)
    : Url(QUrl(url))
{
}

Url::Url(const QUrl& url)
    : QUrl(url.adjusted(NormalizePathSegments))
{
//    if (scheme() == "http") {
//        setScheme("https");
//    }
    if (fragment() == "")
    {
        setFragment(QString());
    }
}

QString Url::base() const {
    return this->adjusted(RemoveFragment).toString(QUrl::FullyEncoded);
}

QString Url::hash() const {
    return this->fragment(QUrl::FullyEncoded);
}

QString Url::full() const
{
    return toString(QUrl::FullyEncoded);
}

QString Url::domain() const
{
    return authority(QUrl::FullyEncoded);
}

QString Url::schemeless() const
{
    if (hasQuery()) {
        return authority(QUrl::FullyEncoded) + path(QUrl::FullyEncoded) + "?" + query(QUrl::FullyEncoded);
    }
    return authority(QUrl::FullyEncoded) + path(QUrl::FullyEncoded);
}

QString Url::directoryPath() const
{
    return adjusted(RemoveFilename|RemoveQuery|RemoveFragment).toString(QUrl::FullyEncoded);
}

QString Url::filePath() const
{
    return adjusted(RemoveQuery|RemoveFragment).toString(QUrl::FullyEncoded);
}

Url Url::fromAmbiguousText(QString const& input)
{
    QUrl url(input, QUrl::StrictMode);
    /* 1. if input contains a space, it is not url
     * 2. if contains no dot and it has no scheme, it is not url
     * 3. otherwise it is a url
     */
    bool is_url = true;
    if (input.contains(" ")) {
        is_url = false;
    }
    if (! input.contains(".") && url.scheme().isEmpty()) {
        is_url = false;
    }
    // when a google search is needed
    if (! is_url) {
        QString encoded = QUrl::toPercentEncoding(input,"","");
        url.setUrl("https://www.google.com/search?q=" + encoded, QUrl::TolerantMode);
    } else {
        // when missing protocal
        if (url.scheme().isEmpty()) {
           url.setUrl("https://" + input, QUrl::TolerantMode);
        }
    }
    return Url(url);
}

UrlNoHash::UrlNoHash(QString const& url)
    : UrlNoHash(QUrl(url))
{
}

UrlNoHash::UrlNoHash(const QUrl& url)
    : QUrl(url.adjusted(NormalizePathSegments))
{
    if (scheme() == "http") {
        setScheme("https");
    }
}

QString UrlNoHash::base() const {
    return adjusted(RemoveFragment).toString(QUrl::FullyEncoded);
}

uint qHash(const UrlNoHash& url)
{
    return qHash(url.base());
}

bool operator==(const Url& a, const Url& b)
{
    return a.full() == b.full();
}

bool operator==(UrlNoHash const& a, UrlNoHash const& b)
{
    return a.base() == b.base();
}

bool operator!=(UrlNoHash const& a, UrlNoHash const& b)
{
    return a.base() != b.base();
}

QDebug& operator<<(QDebug& debug, const UrlNoHash& url)
{
    return debug << url.base() << "(" << url.fragment() << ")";
}

bool Url::isBlank() const
{
    return full() == "about:blank";
}

UrlNoHash UrlNoHash::adjusted(QUrl::FormattingOptions ops) const
{
    return UrlNoHash(QUrl::adjusted(ops));
}
