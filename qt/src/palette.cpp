#include "palette.h"
#include <QPalette>

Palette::Palette() : QPalette()
{
    // Window
    this->setColor(QPalette::Active, QPalette::Window, QColor("#faf5f5f5"));
//    this->setColor(QPalette::Active, QPalette::Window, QColor("#00000000"));
    this->setColor(QPalette::Inactive, QPalette::Window, QColor("#faf5f5f5"));
    this->setColor(QPalette::Active, QPalette::WindowText, QColor("#000"));
    // Text
    this->setColor(QPalette::Active, QPalette::Text, QColor("#555"));
    this->setColor(QPalette::Inactive, QPalette::Text, QColor("#555"));
    this->setColor(QPalette::Disabled, QPalette::Text, QColor("#555"));
    // Button
    this->setColor(QPalette::Active, QPalette::Button, QColor("#ddd"));
    this->setColor(QPalette::Inactive, QPalette::Button, QColor("#00000000"));
    this->setColor(QPalette::Disabled, QPalette::Button, QColor("#00000000"));
    this->setColor(QPalette::Active, QPalette::ButtonText, QColor("#555"));
    this->setColor(QPalette::Inactive, QPalette::ButtonText, QColor("#555"));
    this->setColor(QPalette::Disabled, QPalette::ButtonText, QColor("#aaa"));
    // Shadow
#ifdef Q_OS_IOS
    this->setColor(QPalette::Active, QPalette::Shadow, QColor("#00000000"));
    this->setColor(QPalette::Inactive, QPalette::Shadow, QColor("#00000000"));
    this->setColor(QPalette::Disabled, QPalette::Shadow, QColor("#00000000"));
#else
    this->setColor(QPalette::Active, QPalette::Shadow, QColor("#ccc"));
    this->setColor(QPalette::Inactive, QPalette::Shadow, QColor("#ccc"));
    this->setColor(QPalette::Disabled, QPalette::Shadow, QColor("#ccc"));
#endif
    // Dark and Bright
    this->setColor(QPalette::Active, QPalette::Dark, QColor("#ddd"));
    this->setColor(QPalette::Inactive, QPalette::Dark, QColor("#ddd"));
    this->setColor(QPalette::Active, QPalette::BrightText, QColor("blue"));
    this->setColor(QPalette::Inactive, QPalette::BrightText, QColor("blue"));
    // Highlight
//    this->setColor(QPalette::Active, QPalette::Highlight, QColor("#aaaaaaff"));
    // Base & AlternateBase
    this->setColor(QPalette::Active, QPalette::Base, QColor("#ccc"));
    this->setColor(QPalette::Inactive, QPalette::Base, QColor("#ccc"));
    this->setColor(QPalette::Active, QPalette::AlternateBase, QColor("#555"));
    this->setColor(QPalette::Inactive, QPalette::AlternateBase, QColor("555"));
}

