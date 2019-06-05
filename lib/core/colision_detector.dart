import 'dart:collection';
import 'dart:ui';

import 'package:flutter/rendering.dart';

class ColisionDetector {
  final List<Offset> routes;

  ColisionDetector(this.routes) {
    _defMaxMin();
  }

  ColisionDetector.fromOffset(Offset start, Offset end) :
  this.routes = List()
    ..add(start)
    ..add(end)
  {
    _defMaxMin();
  }

  ColisionDetector.fromRect(Rect rect) : 
  this.routes = List()
    ..add(rect.topLeft)
    ..add(rect.bottomRight)
  {
    _defMaxMin();
  }

  ColisionDetector.fromLTRB(double left, double top, double right, double bottom) :
  this.routes =List()
    ..add(Offset(left, top))
    ..add(Offset(right, bottom))
  {
    _defMaxMin();
  }

  double _xmax = 0, _xmin = 0, _ymax = 0, _ymin = 0;
  Rect get area => Rect.fromLTRB(_xmin, _ymin, _xmax, _ymax);
  set area(Rect v) {
    _xmin = v.left;
    _ymin = v.top;
    _xmax = v.right;
    _ymax = v.bottom;
  }

  bool anyColision(double x, double y) {
    if(x <= _xmax
    && x >= _xmin
    && y <= _ymax
    && y >= _ymin) {
      /*
      debugPrint("xmax: " + _xmax.toString());
      debugPrint("xmin: " + _xmin.toString());
      debugPrint("ymax: " + _ymax.toString());
      debugPrint("ymin: " + _ymin.toString());
      */
      return true;
    }
    return false;   
  }

  void _defMaxMin() {
    assert(routes.length > 1);
    var x = SplayTreeSet();
    var y = SplayTreeSet();
    routes.forEach(
      (f) => {
        x.add(f.dx),
        y.add(f.dy)
      }
    );

    _xmax = x.last;
    _xmin = x.first;
    _ymax = y.last;
    _ymin = y.first;
  }

  /// Verifica se todos os pontos deste colision esta totalmente dentro do [Rect] de outro colision
  /// Util para nao deixar que um componente saia da area de atuaçao de outro componente
  bool isFullInside(ColisionDetector colision) {
    var isInside = routes.map(
      (f) => colision.anyColision(f.dx, f.dy)
    );
    if(isInside.any((f) => f == false))
      return false;
    else
      return true;
  }

  /// Verifica se algum ponto das rotas desse colisor esta fora do [Rect] de outro colisor
  /// Util para nao deixar que um componente saia da area de atuaçao de outro componente
  bool anyOutside(ColisionDetector colision) {
    if(isFullInside(colision) == false)
      return true;
    else
      return false;
  }

}