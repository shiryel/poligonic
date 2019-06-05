import 'package:flutter/material.dart';
import 'package:poligonic/core/colision_detector.dart';
import 'package:poligonic/factory/proportion_factory.dart';
import 'package:tuple/tuple.dart';

class ColisionWrapper {
  var _colisions = List<Tuple2<ColisionDetector, Function>>();

  void addColision(Rect rect, f(Offset action)) {
    _colisions.add(Tuple2(ColisionDetector.fromRect(rect), f));
  }

  void makeColision(Offset action) {
    _colisions.forEach((f) => _verifyColision(f.item1, f.item2, action));
  }

  void _verifyColision(ColisionDetector detector, f(Offset action), Offset action) {
    if(detector.anyColision(action.dx, action.dy))
      f(action);
  }
}

class ColisionProportionalWrapper {
  final ProportionFactory _proportion;
  final _colisionWrapper = ColisionWrapper();

  ColisionProportionalWrapper(Size screen) :
    this._proportion = ProportionFactory(screen);

  /// Adiciona os colisores no wrapper
  /// Recebe valores proporcionais á tela
  void addColisionLTRB(double left, double top, double right, double bottom, f(Offset action)) {
    _colisionWrapper.addColision(
      _proportion.getRectLTRB(left, top, right, bottom),
      f
    );
  }

  /// Aciona os colisores do wrapper
  /// Nao recebe valores proporcionais, e sim o ponto de acao exato
  void makeColision(Offset action) {
    _colisionWrapper.makeColision(action);
  }

}