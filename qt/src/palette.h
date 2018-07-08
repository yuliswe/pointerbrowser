#ifndef PALETTE_H
#define PALETTE_H
#include <QPalette>
#include <QMap>
#include <QJsonObject>
#include <QJsonDocument>
#include <QVariant>

typedef QJsonObject ColorMap;

class Palette: public QObject
{
    Q_OBJECT
    Q_PROPERTY(ColorMap normal READ normal NOTIFY paletteChanged)
    Q_PROPERTY(ColorMap selected READ selected NOTIFY paletteChanged)
    Q_PROPERTY(ColorMap hovered READ hovered NOTIFY paletteChanged)
    Q_PROPERTY(ColorMap disabled READ disabled NOTIFY paletteChanged)
    Q_PROPERTY(ColorMap pressed READ pressed NOTIFY paletteChanged)
    Q_PROPERTY(QJsonObject json READ json)
signals:
    void paletteChanged();
public:
    Palette();
    void setup();
    ColorMap normal() const;
    ColorMap selected() const;
    ColorMap hovered() const;
    ColorMap disabled() const;
    ColorMap pressed() const;
    QJsonObject json() const;


protected:
    ColorMap _normal = ColorMap();
    ColorMap _selected = ColorMap();
    ColorMap _hovered = ColorMap();
    ColorMap _disabled = ColorMap();
    ColorMap _pressed = ColorMap();
    QJsonObject _json;
};

Q_DECLARE_METATYPE(ColorMap)
#endif // PALETTE_H
