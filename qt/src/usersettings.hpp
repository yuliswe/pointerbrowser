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

    PROP_DEF_BEGINS
    PROP_RN_D(bool, warn_http, true)
    PROP_DEF_ENDS

public:
    UserSettings();
    void saveUserSettingsToFile(QFileInfo const& filepath);
    QVariantMap toQVariantMap();
    static UserSettings_ readUserSettingsFromFile(QFileInfo const& filepath);
    static UserSettings_ fromQVariantMap(QVariantMap const& map);
};


#endif // USERSETTINGS_HPP
