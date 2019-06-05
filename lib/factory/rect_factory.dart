import 'dart:ui';
import 'package:flame/components/component.dart';
import 'package:flutter/material.dart';

class RectProportional extends PositionComponent {
  final Rect rect;
  final Paint color;
  bool _isHud = false;
  RectProportional.fromLTRB(
    Size _screen, 
    double left,
    double top,
    double right,
    double bottom,
    Color color, 
    {bool isHud = false}
  ) :
    this.rect = Rect.fromLTRB(
      _screen.width * left, // right
      _screen.height * top, // left
      _screen.width * right, // bottom
      _screen.height * bottom // top
    ),
    this.color = Paint()..color = color
  {
    _isHud = isHud;
  }

  RectProportional.flatRect(this.rect, Color color, {bool isHud = false}) :
    this.color = Paint()..color = color {
      _isHud = isHud;
    }

  @override
  bool isHud() {
    return _isHud; 
  }

  @override
  void render(Canvas c) {
    c.drawRect(rect, color);
  }

  @override
  void update(double t) {
  }
}

/*
class RectFactory extends PositionComponent{
  final Size screen;
  var _toRender = List<Tuple2<Rect, Paint>>();
  var _texts = List<Tuple3<TextConfig, String, Position>>();

  RectFactory(this.screen);

  @override
  void render(Canvas c) {
    c.save();
    _toRender.forEach((f) => c.drawRect(f.item1, f.item2));
    _texts.forEach((f) => f.item1.render(c, f.item2, f.item3));
    c.restore();
  }

  @override
  void update(double t) {
  }

  /// Ao adicionar um retangulo ele tambem pode ser adicionado como hitbox,
  /// assim depois é possivel pegar o Hitbox, ver se ele colide com algo e
  /// tratalo pelo seu id na Tuple2
  /// Text: (1: text, 2: textProportion, 3: widthProportion, 4: heightProportion, 
  /// 5: fontFamily)
  Rect addRectLTRB(double left, double top, double right, 
   double bottom, Color color, {Tuple5 text}) {
    var rect = Rect.fromLTRB(
      screen.width * left, // right
      screen.height * top, // left
      screen.width * right, // bottom
      screen.height * bottom // top
    );

    _toRender.add(
      Tuple2(rect, Paint()..color = color)
    );

    if(text != null) {
      var heightSize = (screen.height * top - screen.height * bottom).abs() * text.item2;
      var widthSize = (screen.width * left - screen.width * bottom).abs() * text.item2;
      var size = heightSize < widthSize ? heightSize : widthSize;

      TextConfig config = TextConfig(fontSize: size, fontFamily: text.item5);
      var maxWidght = left > right ? screen.width * left : screen.width * right;
      var minWidght = left < right ? screen.width * left : screen.width * right;
      var maxHeight = top > bottom ? screen.height * top : screen.height * bottom;
      var minHeight = top < bottom ? screen.height * top : screen.height * bottom;
      _texts.add(Tuple3(
          config, 
          text.item1, 
          Position(
            minWidght + (maxWidght - minWidght) * text.item3,
            minHeight + (maxHeight - minHeight) * text.item4
          )
        )
      );
    }

    return rect;
  }

  Rect makeRectLTRM(double left, double top, double right, double bottom) {
    return Rect.fromLTRB(
      screen.width * left,
      screen.height * top,
      screen.width * right,
      screen.height * bottom
    );
  }
  
  /// Pega o size do retangulo de acordo com o size da tela e o LTRB
  /// Util para criar poligonos com tamanhos proporcionais a um tamanho
  /// externo, e apos posicionalo com o [x] e [y] do [PositionedComponent]
  Size getSize(double left, double top, double right, double bottom) {
    return Size(
      screen.width * (left - right).abs(),
      screen.height * (top - bottom).abs()
    );
  }
}
*/
