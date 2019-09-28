#ifndef URL_HPP
#define URL_HPP

#include <QtCore/QtCore>

class Url : public QUrl
{
public:
    Url() = default;
    Url(QString const&);
    // use explict to prevent conversion between url and nohash url
    explicit Url(const QUrl&);
    Url(Url const&) = default;
    QString hash() const;
    QString base() const;
    QString full() const;
    QString domain() const;
    QString schemeless() const;
    QString directoryPath() const;
    QString filePath() const;
    bool isBlank() const;
//    bool isError();
    virtual ~Url() = default;
    static Url fromAmbiguousText(
        QString const& input,
        QString const& search_engine
    );
};

class UrlNoHash : public QUrl
{
public:
    UrlNoHash() = default;
    UrlNoHash(QString const&);
    explicit UrlNoHash(const QUrl&);
    UrlNoHash(const UrlNoHash&) = default;
    QString base() const;
    UrlNoHash adjusted(QUrl::FormattingOptions) const;
    virtual ~UrlNoHash() = default;
};

uint qHash(const UrlNoHash& url);
bool operator==(const UrlNoHash& a, const UrlNoHash& b);
bool operator!=(const UrlNoHash& a, const UrlNoHash& b);
QDebug& operator<<(QDebug& debug, const UrlNoHash& url);

Q_DECLARE_METATYPE(Url)
Q_DECLARE_METATYPE(UrlNoHash)

#endif // URL_HPP
