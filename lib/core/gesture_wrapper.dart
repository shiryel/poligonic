import 'dart:ui';

import 'package:poligonic/core/colision_detector.dart';
import 'package:tuple/tuple.dart';

/// Uma vez que o dart nao facilita a vida em deixar utilizar gestures
/// dentro de uma classe com rota unica (ja que as rotas do [GestureBinding]
/// sao globais), entao estou criando essa classe para controlar uma API 
/// global e generica de todos os Recognizers desta bosta
/// obs: ele tambem nao deixa usar introspection para saber se um metodo existe

class GestureWrapper {
  void tapDown(Offset action) {}
  void tapUp(Offset action) {}
  void tapCancel() {}
  void panUpdate(Offset action) {}
  void longPressStart(Offset action) {}
  void longPressEnd(Offset action) {}

}

class HoldTap {
  // guarda um determinado colisor que executara uma funçao
  // a cada x microsegundos
  var _worker = List<Tuple2<ColisionDetector, Function>>();
  Offset _inHold;

  void addWorker(Rect c, f(Offset action, double time)) {
    var colision = ColisionDetector.fromRect(c);
    _worker.add(Tuple2(colision, f));
  }

  void down(Offset v) {
    _inHold = v;
  }

  cancel() {
    _inHold = null;
  }

  update(double t) { 
    if(_inHold == null) return;

    _worker.forEach((f) {
      if(f.item1.anyColision(_inHold.dx, _inHold.dy))
        f.item2(_inHold, t);
    });
  }
}