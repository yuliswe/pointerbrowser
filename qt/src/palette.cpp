#include "palette.h"
#include <QPalette>

Palette::Palette()
{
    this->setColor(QPalette::Active, QPalette::Button, QColor("#fdfdfd"));
    this->setColor(QPalette::Inactive, QPalette::Button, QColor("#000"));
    this->setColor(QPalette::ButtonText, QColor("#aaa"));
}

