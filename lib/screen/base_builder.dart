import 'package:flame/components/component.dart';
import 'package:flame/svg.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:poligonic/component/poligon_struct.dart';
import 'package:poligonic/core/colision_wrapper.dart';
import 'package:poligonic/factory/proportion_factory.dart';
import 'package:poligonic/factory/rect_factory.dart';
import 'package:poligonic/main.dart';
import 'package:poligonic/screen/partial/poligon_maker.dart';
import 'package:poligonic/screen/poligon_struct_builder.dart';

// TODO: finalizar classe para construçao de bases
class BaseBuilder extends BaseGame {
  final Router _router;
  final Size screen;
  final ProportionFactory _proportionFac;

  final _tapColisions = ColisionWrapper();
  final _dragColisions = ColisionWrapper();

  BaseBuilder(this._router) :
  this.screen = _router.screen,
  this._proportionFac = ProportionFactory(_router.screen)
  {
    // background
    add(RectProportional.fromLTRB(screen, 0, 0, 1, 1, Colors.lightBlue[100]));

    // Menu


  }

  _addSvg(String name, Rect rect) {
    var svg = SvgComponent.fromSvg(rect.width, rect.height, Svg(name))
      ..x = rect.left
      ..y = rect.top;
    add(svg);
  }

  _addSvgWithTapColision(String name, Rect rect, f(Offset action)) {
    _addSvg(name, rect);
    _tapColisions.addColision(rect, f);
  }

  _addSvgWithDragColision(String name, Rect rect, f(Offset action)) {
    _addSvg(name, rect);
    _dragColisions.addColision(rect, f);
  }

  // ==============
  // === INPUTS ===
  // ==============
  void tapInput(Offset action) => _tapColisions.makeColision(action);
  void dragInput(Offset action) => _dragColisions.makeColision(action);
}