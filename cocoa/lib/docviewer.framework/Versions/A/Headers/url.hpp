#ifndef URL_HPP
#define URL_HPP

#include <QtCore/QtCore>

class Url : public QUrl
{
public:
    Url() = default;
    Url(QString const&);
    Url(const QUrl&);
    Url(Url const&) = default;
    QString hash() const;
    QString base() const;
    QString full() const;
    QString domain() const;
    QString schemeless() const;
    bool isBlank();
    virtual ~Url() = default;
    static Url fromAmbiguousText(QString const&);
};

class UrlNoHash : public QUrl
{
public:
    UrlNoHash() = default;
    UrlNoHash(QString const&);
    UrlNoHash(const QUrl&);
    UrlNoHash(const UrlNoHash&) = default;
    QString base() const;
    Url toUrl() const;
    virtual ~UrlNoHash() = default;
};

uint qHash(const UrlNoHash& url);
bool operator==(const UrlNoHash& a, const UrlNoHash& b);
QDebug& operator<<(QDebug& debug, const UrlNoHash& url);

Q_DECLARE_METATYPE(Url)
Q_DECLARE_METATYPE(UrlNoHash)

#endif // URL_HPP
