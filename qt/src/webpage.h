#ifndef WEBPAGE_H
#define WEBPAGE_H

#include <QObject>
#include <QString>
#include <QList>
#include <QVariantMap>
#include <QSharedPointer>
#include <QStringList>

class Webpage;
typedef QSharedPointer<Webpage> Webpage_;
typedef QList<Webpage_> Webpage_List;


class Webpage : public QObject
{
    Q_OBJECT

public:

    ~Webpage();
    explicit Webpage(const QString& url);
    explicit Webpage(const QVariantMap&);

    QVariantMap toQVariantMap();
    static Webpage_ fromQVariantMap(const QVariantMap&);
    QJsonObject toQJsonObject();
    static Webpage_ fromQJsonObject(const QJsonObject&);

#define PROP_DEC(type, prop, defval) \
    Q_PROPERTY(type prop READ prop WRITE set_##prop NOTIFY prop##_changed) \
    public: type prop() const; \
    public: void set_##prop(type); \
    public: type _##prop = defval; \
    Q_SIGNAL void prop##_changed(type);

    PROP_DEC(QString, title, "")
    PROP_DEC(QString, url, "")
    PROP_DEC(QString, html, "")
    PROP_DEC(QString, symbol, "")
    PROP_DEC(QString, hash, "")
    PROP_DEC(QString, display, "")
    PROP_DEC(QStringList, expanded_display, {})
    PROP_DEC(quint64, visited, 0)
    PROP_DEC(bool, preview_mode, false)
    PROP_DEC(bool, open, false)
    PROP_DEC(bool, url_matched, false)
    PROP_DEC(bool, title_matched, false)
    PROP_DEC(bool, hash_matched, false)
    PROP_DEC(bool, symbol_matched, false)

#undef PROP_DEC
};

Q_DECLARE_METATYPE(Webpage*)
Q_DECLARE_METATYPE(Webpage_)
#endif // WEBPAGE_H
