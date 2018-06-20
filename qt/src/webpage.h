#ifndef WEBPAGE_H
#define WEBPAGE_H

#include <QObject>
#include <QString>
#include <QList>
#include <QVariantMap>
#include <QSharedPointer>

#define QPROP_DEC(type, prop, defval) \
    Q_PROPERTY(type prop READ prop WRITE set_##prop NOTIFY prop##_changed) \
    public: type prop() const; \
    public: void set_##prop(type); \
    public: type _##prop = defval; \
    Q_SIGNAL void prop##_changed(type); \


class Webpage;
typedef QSharedPointer<Webpage> Webpage_;
typedef QList<Webpage_> Webpage_List;


class Webpage : public QObject
{
    Q_OBJECT

public:

    ~Webpage();
    explicit Webpage(const QString& url);
    explicit Webpage(const QVariantMap);

    QVariantMap toQVariantMap();
    static Webpage_ fromQVariantMap(QVariantMap&);
    QJsonObject toQJsonObject();
    static Webpage_ fromQJsonObject(QJsonObject&);

    QPROP_DEC(QString, title, "")
    QPROP_DEC(QString, url, "")
    QPROP_DEC(QString, html, "")
    QPROP_DEC(QString, symbol, "")
    QPROP_DEC(QString, hash, "")
    QPROP_DEC(QString, display, "")
    QPROP_DEC(QString, expanded_display, "")
    QPROP_DEC(quint64, visited, 0)
    QPROP_DEC(bool, preview_mode, false)
    QPROP_DEC(bool, open, false)
    QPROP_DEC(bool, url_matched, false)
    QPROP_DEC(bool, title_matched, false)
    QPROP_DEC(bool, hash_matched, false)
    QPROP_DEC(bool, symbol_matched, false)
};

Q_DECLARE_METATYPE(Webpage*)
Q_DECLARE_METATYPE(Webpage_)
#endif // WEBPAGE_H
