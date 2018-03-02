#ifndef SETTINGSMODEL_H
#define SETTINGSMODEL_H

#include <QtCore/QtCore>

class KeyMaps : public QObject
{
    Q_OBJECT

public:
    explicit KeyMaps(QObject *parent = nullptr);

#define KEYMAP(prop, desc) \
    Q_PROPERTY(QString prop READ prop WRITE set_##prop NOTIFY prop##_changed) \
    Q_PROPERTY(QString prop##_desc READ prop##_desc) \
    public: QString _##prop = ""; \
    public: QString prop() const { return _##prop; } \
    public: QString prop##_desc() const { return desc; } \
    Q_SIGNAL void prop##_changed(QString); \
    public: void set_##prop(QString val) { _##prop = val; emit prop##_changed(val); }

    KEYMAP(focus_address_bar, "Address Bar")
    KEYMAP(focus_search, "Search")
    KEYMAP(close_tab, "Close Tab")
    KEYMAP(new_tab, "New Tab")
#undef KEYMAP

    void sync();
    Q_INVOKABLE const QVariantMap toVariantMap() const;
    void loadOverwrite(const QVariantMap&);
};

Q_DECLARE_METATYPE(KeyMaps*)

class SettingsModel : public QObject
{
    Q_OBJECT

public:

//#define PROP_DEC(T, prop, init) \
//    Q_PROPERTY(T prop READ prop WRITE set_##prop NOTIFY prop##_changed) \
//    public: T& prop() { return _##prop; } \
//    public: T _##prop{init}; \
//    Q_SIGNAL void prop##_changed(T);

//public: void set_##prop(T val) { _##prop = val; emit prop##_changed(val); } \

//    PROP_DEC(KeyMaps, keymaps, this)
//#undef PROP_DEC

    explicit SettingsModel(QObject *parent = nullptr);


signals:

public slots:
};

#endif // SETTINGSMODEL_H
