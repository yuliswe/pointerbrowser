#ifndef USERSETTINGS_HPP
#define USERSETTINGS_HPP

#include <QtCore/QtCore>
#include "filemanager.hpp"
#include "macros.hpp"

class UserSettings;
typedef QSharedPointer<UserSettings> UserSettings_;

class UserSettings : public QObject
{
    Q_OBJECT

#define DEF_USER_SETTING(type, name, defval) \
    PROP_RWN_D(type, name, defval) \
    inline static constexpr char const* name##_key = #name;

    PROP_DEF_BEGINS

    DEF_USER_SETTING(bool, warn_http, true)
    DEF_USER_SETTING(QString, search_engine, "google")

    PROP_DEF_ENDS

#undef DEF_USER_SETTING

public:
    UserSettings();
    void saveUserSettingsToFile(QFileInfo const& filepath);
    QVariantMap toQVariantMap();
    static UserSettings_ readUserSettingsFromFile(QFileInfo const& filepath);
    static UserSettings_ fromQVariantMap(QVariantMap const& map);
};

#undef DEFINE_USER_SETTING


#endif // USERSETTINGS_HPP
