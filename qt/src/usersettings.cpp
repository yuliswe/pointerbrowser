#include "usersettings.hpp"

UserSettings::UserSettings()
{

}

UserSettings_ UserSettings::fromQVariantMap(QVariantMap const& map)
{
    UserSettings_ default_settings = UserSettings_::create();
    if (map.contains("warn_http")) {
        default_settings->set_warn_http(map["warn_http"].value<bool>());
    }
    return default_settings;
}

QVariantMap UserSettings::toQVariantMap()
{
    QVariantMap map;
    map["warn_http"] = QVariant::fromValue(warn_http());
    return map;
}

UserSettings_ UserSettings::readUserSettingsFromFile(QFileInfo const& file)
{
    QMap<QString, QVariant> map = FileManager::readJsonFileM(file);
    return UserSettings::fromQVariantMap(map);
}

void UserSettings::saveUserSettingsToFile(QFileInfo const& file)
{
    QVariantMap map = toQVariantMap();
    FileManager::writeJsonFileM(file, map);
}
