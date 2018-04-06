#include "palette.h"
#include <QPalette>

Palette::Palette() : QPalette()
{
    // Window
    this->setColor(QPalette::Active, QPalette::Window, QColor("#f5f5f5f5"));
    this->setColor(QPalette::Active, QPalette::WindowText, QColor("#000"));
    // Text
    this->setColor(QPalette::Active, QPalette::Text, QColor("#555"));
    this->setColor(QPalette::Inactive, QPalette::Text, QColor("#555"));
    this->setColor(QPalette::Disabled, QPalette::Text, QColor("#555"));
    // Button
    this->setColor(QPalette::Active, QPalette::Button, QColor("#ccc"));
    this->setColor(QPalette::Inactive, QPalette::Button, QColor("#00000000"));
    this->setColor(QPalette::Disabled, QPalette::Button, QColor("#00000000"));
    this->setColor(QPalette::Active, QPalette::ButtonText, QColor("#fff"));
    this->setColor(QPalette::Inactive, QPalette::ButtonText, QColor("#555"));
    this->setColor(QPalette::Disabled, QPalette::ButtonText, QColor("#aaa"));
    // Shadow
    this->setColor(QPalette::Active, QPalette::Shadow, QColor("#ccc"));
    this->setColor(QPalette::Inactive, QPalette::Shadow, QColor("#ccc"));
    this->setColor(QPalette::Disabled, QPalette::Shadow, QColor("#ccc"));
}

