#ifndef WEBPAGE_H
#define WEBPAGE_H

#include <QObject>
#include <QString>
#include <QList>
#include <QVariantMap>
#include <QSharedPointer>
#include <QStringList>
#include "macros.h"

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

    PROP_RWN_D(QString, title, "")
    DEC_PROP_RWN_D(QString, url, "")
    DEC_PROP_RWN_D(QString, hash, "")
    PROP_RN_D(QString, uri, "")
    PROP_RWN_D(QString, html, "")
    PROP_RWN_D(QString, symbol, "")
    PROP_RWN_D(QString, display, "")
    PROP_RWN_D(QStringList, expanded_display, {})
    PROP_RWN_D(quint64, visited, 0)
    PROP_RWN_D(int, loading_percentage, 0)
};

Q_DECLARE_METATYPE(Webpage*)
Q_DECLARE_METATYPE(Webpage_)
#endif // WEBPAGE_H
