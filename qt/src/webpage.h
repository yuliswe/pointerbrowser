#ifndef WEBPAGE_H
#define WEBPAGE_H

#include <QObject>
#include <QString>
#include <QVariantMap>
#include <QSharedPointer>
class Webpage;
typedef QSharedPointer<Webpage> Webpage_;
typedef QList<Webpage_> WebpageList;

class Webpage : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
    Q_PROPERTY(QString url READ url WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(QString storeFile READ storeFile WRITE setStoreFile NOTIFY storeFileChanged)
    Q_PROPERTY(QString html READ html WRITE setHtml NOTIFY htmlChanged)
    Q_PROPERTY(bool temporary READ temporary WRITE setTemporary NOTIFY temporaryChanged)


public:
    explicit Webpage(QObject *parent = nullptr);
    Webpage(QString url);
    Webpage(QString url, QString title, QString html);

    QString title() const;
    QString html() const;
    QString url() const;
    QString storeFile() const;
    bool temporary() const;
    void setTitle(QString);
    void setHtml(QString);
    void setUrl(QString);
    void setStoreFile(QString);
    void setTemporary(bool);
    QVariantMap toQVariantMap();
    static Webpage_ fromQVariantMap(QVariantMap&);
    QJsonObject toQJsonObject();
    static Webpage_ fromQJsonObject(QJsonObject&);
    static Webpage_ create(const QString& url);

signals:
    void titleChanged(QString);
    void urlChanged(QString);
    void storeFileChanged(QString);
    void htmlChanged(QString);
    void temporaryChanged(bool);

public slots:

private:
    QString _title;
    QString _url;
    QString _storeFile;
    QString _html;
    bool _temporary;
};

Q_DECLARE_METATYPE(Webpage*)
Q_DECLARE_METATYPE(Webpage_)
#endif // WEBPAGE_H
