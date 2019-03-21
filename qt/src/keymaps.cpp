#include "keymaps.hpp"
#include "filemanager.hpp"
#include <QtCore/QtCore>

KeyMaps::KeyMaps(QObject *parent) : QObject(parent) {}
SettingsModel::SettingsModel(QObject *parent) : QObject(parent) {}

void KeyMaps::loadOverwrite(const QVariantMap& map) {
    QStringList keys = map.keys();
    for (QString k : keys) {
        QString val = map[k].value<QString>();

#define KEYMAP(name) \
    if (k == #name) { \
    set_##name(val); \
    qInfo() << "KeyMaps::loadOverwrite" << k << val; \
    continue; \
    }

        KEYMAP(focus_address_bar);
        KEYMAP(focus_search);
        KEYMAP(close_tab);
        KEYMAP(new_tab);
#undef KEYMAP
    }
}

const QVariantMap KeyMaps::toVariantMap() const {
    QVariantMap map;
#define KEYMAP(NAME) map.insert(#NAME, NAME())
    KEYMAP(focus_address_bar);
    KEYMAP(focus_search);
    KEYMAP(close_tab);
    KEYMAP(new_tab);
#undef KEYMAP
    return map;
}

void KeyMaps::sync() {
    qInfo() << "KeyMaps::sync starts";
    // load default settings
    loadOverwrite(FileManager::readQrcJsonFileM("settings/keymaps.json"));
    if (FileManager::dataFile("keymaps.json").exists()) {
        loadOverwrite(FileManager::readDataJsonFileM("keymaps.json"));
    }
    // load user settings
    FileManager::writeDataJsonFileM("keymaps.json", toVariantMap());
}
