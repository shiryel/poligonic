import 'package:poligonic/component/point.dart';
import 'package:poligonic/component/poligon.dart';
import 'package:poligonic/core/colision_detector.dart';
import 'package:tuple/tuple.dart';

import 'poligon_struct.dart';
import 'hitbox.dart';
import 'package:flutter/material.dart';
import 'package:flame/components/component.dart';

class PlayerMap extends PositionComponent{
  /// Um retangulo determina a area de um poligono dentro do mapa
  /// Ou seja: o retangulo determina a posiçao relativa do poligono no mapa, e com tal o poligono pode determinar sua posiçao dentro do retangulo
  var raw = List<Tuple2<Rect, Poligon>>();

  /// Ocorre apos o raw, deve ser entrelaçado com o raw
  var positioned = List<Tuple2<Rect, Poligon>>();

  bool _isDirt = false;

  get isDirt => _isDirt;
  set idDirt(bool v) {
    _isDirt = v;
    if(_isDirt) updatePoligons();
  }

  PlayerMap(Rect area) {
    _setArea(area);
  }

  PlayerMap.rawLoad(Rect area, List<Tuple2<Rect, Poligon>> load) {
    _setArea(area);
    raw = load;
    _genPositioned();
  }

  PlayerMap.positionedLoad(Rect area, List<Tuple2<Rect, Poligon>> load) {
    _setArea(area);
    positioned = load;
    _genRaw();
  }

  /// Adiona na lista de positioned
  void addPositioned(Rect r, Poligon p) {
    assert(r != null && p != null);
    positioned.add(Tuple2(r,p));
  }

  void add(Poligon p) {
    var list = List<Offset>();
    
    p.structs.forEach((f) {
      f.positionedRoutes.forEach((ff) {
        list.add(ff);
      });
    });

    var area = ColisionDetector(list).area;
    positioned.add(Tuple2(area, p));
  }

  /// Remove na area informada
  /// Use para remover no acerto de algo
  void removePositioned(Offset action) {
    positioned = positioned.where((f) {
      return !f.item2.hitbox.colisionDetector.anyColision(action.dx, action.dy);
    }).toList();
    _genRaw();
  }

  /// Necessario para enviar ao banco de dados
  void _genRaw() {
    raw = positioned.map<Tuple2<Rect, Poligon>>(
      (f) {
        return Tuple2(
          Rect.fromLTWH(
            (f.item1.left - this.x) / this.width,
            (f.item1.top - this.y) / this.height, 
            f.item1.width / this.width, 
            f.item1.height / this.height 
          ),
          f.item2
        );
      }
    ).toList();
    assert(raw.any((f) => f == null) == false);
    assert(raw.any((f) => f.item1 == null) == false);
    assert(raw.any((f) => f.item2 == null) == false);
  }

  /// Necessario para carregar do banco
  void _genPositioned() {
    positioned = raw.map<Tuple2<Rect, Poligon>>(
      (f){
        return Tuple2(
          Rect.fromLTWH(
            this.width * f.item1.left + this.x, 
            this.height * f.item1.top + this.y, 
            this.width * f.item1.width, 
            this.height * f.item1.height
          ),
          f.item2
        );
      }
    ).toList();

    assert(positioned.any((f) => f == null) == false);
    assert(positioned.any((f) => f.item1 == null) == false);
    assert(positioned.any((f) => f.item2 == null) == false);

    updatePoligons();
  }

  void updatePoligons() {
    /*
    positioned = positioned.map((f){
      return Tuple2(
        f.item1,
        Poligon.positioned(f.item2.role, f.item2.dz, f.item2.structs, f.item2.hitbox, f.item1)
      );
    }).toList();
    */

    // mesma coisa
    positioned.forEach((f) => f.item2.setArea(f.item1));
  }

  void _setArea(Rect r) {
    this.x = r.left;
    this.y = r.top;
    this.width = r.width;
    this.height = r.height;
  }

  void setArea(Rect r) {
    _setArea(r);
    _genPositioned();
  }

  void setPosition(double x, double y) {
    this.x = x;
    this.y = y;
    _genPositioned();
  }

  @override
  void render(Canvas c) {
    assert(positioned != null);

    positioned.forEach((f) {
      f.item2.render(c);
    });
  }

  @override
  void update(double t) {
    assert(positioned != null);

    positioned.forEach((f) {
      f.item2.update(t);
    });
  }

}