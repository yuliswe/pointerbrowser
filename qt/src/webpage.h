#ifndef WEBPAGE_H
#define WEBPAGE_H

#include <QObject>
#include <QString>
#include <QUrl>

class Webpage : public QObject
{
        Q_OBJECT
        Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
        Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)
        Q_PROPERTY(QUrl storeFile READ storeFile WRITE setStoreFile NOTIFY storeFileChanged)
        Q_PROPERTY(QString html READ html WRITE setHtml NOTIFY htmlChanged)

    public:
        explicit Webpage(QObject *parent = nullptr);
        Webpage(QUrl url, QString title, QString html);

        QString title() const;
        QString html() const;
        QUrl url() const;
        QUrl storeFile() const;
        void setTitle(QString);
        void setHtml(QString);
        void setUrl(QUrl);
        void setStoreFile(QUrl);

    signals:
        void titleChanged(QString);
        void urlChanged(QUrl);
        void storeFileChanged(QUrl);
        void htmlChanged(QString);

    public slots:

    private:
        QString _title;
        QUrl _url;
        QUrl _storeFile;
        QString _html;
};

Q_DECLARE_METATYPE(Webpage*)

#endif // WEBPAGE_H
