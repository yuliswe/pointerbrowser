#ifndef WEBPAGE_H
#define WEBPAGE_H

#include <QObject>
#include <QString>
#include <QList>
#include <QVariantMap>
#include <QSharedPointer>

#define QPROP_DEC(type, prop) \
    Q_PROPERTY(type prop READ prop WRITE set_##prop NOTIFY prop##_changed) \
    public: type prop() const; \
    public: void set_##prop(type); \
    public: type _##prop; \
    Q_SIGNAL void prop##_changed(type); \


class Webpage;
typedef QSharedPointer<Webpage> Webpage_;
typedef QList<Webpage_> Webpage_List;


class Webpage : public QObject
{
    Q_OBJECT

    QPROP_DEC(QString, title)
    QPROP_DEC(QString, url)
    QPROP_DEC(QString, html)
    QPROP_DEC(QString, symbol)
    QPROP_DEC(QString, hash)
    QPROP_DEC(QString, display)
    QPROP_DEC(quint64, visited)
    QPROP_DEC(bool, url_matched)
    QPROP_DEC(bool, title_matched)
    QPROP_DEC(bool, hash_matched)
    QPROP_DEC(bool, symbol_matched)

    public:
        explicit Webpage(QString url);

        QVariantMap toQVariantMap();
        static Webpage_ fromQVariantMap(QVariantMap&);
        QJsonObject toQJsonObject();
        static Webpage_ fromQJsonObject(QJsonObject&);
};

Q_DECLARE_METATYPE(Webpage*)
Q_DECLARE_METATYPE(Webpage_)
#endif // WEBPAGE_H
