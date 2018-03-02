#ifndef MODELREGISTER_H
#define MODELREGISTER_H

#include <QObject>

class ModelRegister : public QObject
{
        Q_OBJECT
    public:
        explicit ModelRegister(QObject *parent = nullptr);

    signals:

    public slots:
};

#endif // MODELREGISTER_H