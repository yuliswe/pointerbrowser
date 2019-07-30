#include "usersettings.hpp"

UserSettings::UserSettings()
{

}

UserSettings_ UserSettings::fromQVariantMap(QVariantMap const& map)
{
    UserSettings_ default_settings = UserSettings_::create();
    /* Overwrite defaults here */
    if (map.contains(warn_http_key)) {
        default_settings->set_warn_http(map[warn_http_key].value<bool>());
    }
    if (map.contains(search_engine_key)) {
        default_settings->set_search_engine(map[search_engine_key].value<QString>());
    }
    return default_settings;
}

QVariantMap UserSettings::toQVariantMap()
{
    QVariantMap map;
    map[warn_http_key] = QVariant::fromValue(warn_http());
    map[search_engine_key] = QVariant::fromValue(search_engine());
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
