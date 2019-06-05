import 'package:poligonic/core/colision_detector.dart';
import 'package:tuple/tuple.dart';

import 'poligon_struct.dart';
import 'hitbox.dart';
import 'package:flutter/material.dart';
import 'package:flame/components/component.dart';

/*
Um poligon nada mais é que varios [PoligonStruct] posicionados em relaçao ao
seu proprio retangulo (sua area herdada do PositionComponent), para tal 
sua area deve tambem ser posicionada na tela, essa area por sua vez 
pode possuir um hitbox interno
*/

class Poligon extends PositionComponent{
  String role; // mutable in builders
  int dz; // mutable in builders
  bool _destroied = false;

  set destroied(bool v) {
    _rawPoligonStructs.forEach((f) => f.destroied = v);
    _destroied = v;
  }

  final List<PoligonStruct> _rawPoligonStructs;
  Hitbox hitbox;

  List<PoligonStruct> get structs => _rawPoligonStructs;

  /// Principalmente usado para carregar do banco
  Poligon(
    this.role,
    this.dz,
    this._rawPoligonStructs,
    this.hitbox
  );

  /// Principalmente usado para carregar na tela
  Poligon.positioned(
    this.role,
    this.dz,
    this._rawPoligonStructs,
    this.hitbox,
    Rect rect
  ) {
    this.x = rect.left;
    this.y = rect.top;
    this.width = rect.width;
    this.height = rect.height;
    updateArea();
  }

  /// Principalmente usado para criar o objeto completo de forma "raw" e mandar para o servidor
  Poligon.makeFromStruct(
    List<PoligonStruct> structs, 
    Rect area,
    this.role, 
    this.dz,
    this.hitbox,
    [Rect position]) :
      this._rawPoligonStructs = _makeFromStruct(structs, area) {
        assert(_rawPoligonStructs.any((f) => f == null) == false);

        if(position != null) {
          _setPositionFromRect(this, position);
          updateArea();
        }

        assert(_rawPoligonStructs.any((f) => f == null) == false);
      }

  static void _setPositionFromRect(Poligon p, Rect position) {
    p.x = position.left;
    p.y = position.top;
    p.width = position.width;
    p.height = position.height;
  }

  // Os pontos devem ser relacionados com o ponto 0,0 do colision DESTE poligon
  static List<PoligonStruct> _makeFromStruct(List<PoligonStruct> structs, [Rect area]) {
    if(area == null) {
      var list = List<Offset>();

      structs.forEach((f) {
        f.positionedRoutes.forEach((ff) {
          list.add(ff);
        });
      });

      area = ColisionDetector(list).area;
    }

    var structList = List<PoligonStruct>();

    structs.forEach((f) {
      structList.add(PoligonStruct.makeFromOffsetAndArea(f.positionedRoutes, f.paint, area));
    });
    assert(structList.length > 0);

    return structList;
  }

  updateHitbox() {
    var list = List<Offset>();
    structs.forEach((f) {
      f.positionedRoutes.forEach((x) => list.add(x));
    });

    hitbox = Hitbox(ColisionDetector(list));
  }

  /// Make a deep copy from this struct
  Poligon copy() {
    var newPoligon = Poligon.positioned(
      this.role,
      this.dz,
      List.from(
        _rawPoligonStructs.map((f) => f.copy())
      ),
      this.hitbox,
      Rect.fromLTWH(this.x, this.y, this.width, this.height),
    );
    newPoligon.angle = this.angle;
    newPoligon.anchor = this.anchor;
    newPoligon.destroied = this._destroied;

    // Nao deve retornar estruturas vazias
    assert(newPoligon._rawPoligonStructs.any((f) => f == null) == false);

    return newPoligon;
  }

  /// move as estruturas internas se baseando nas posiçoes atuais 
  /// e adicionando relativamente
  //var _lastArea = Rect.fromLTRB(0,0,0,0);
  void updateArea() {
    _rawPoligonStructs.forEach((f) {
      f.setArea(Rect.fromLTWH(this.x, this.y, width, height));
    });

    updateHitbox(); // FIXME: Nao deveria ser realizado assim
    /*
    var relativeX = x - _lastArea.left;
    var relativeY = y - _lastArea.top;
    var relativeWidth = width - _lastArea.width;
    var relativeHeight = height - _lastArea.height;
    _rawPoligonStructs.forEach(
      (f) {
        f?.setArea(
          Rect.fromLTWH(
          f?.x ?? 0 + relativeX,
          f?.y ?? 0 + relativeY,
          f?.width ?? 0 + relativeWidth,
          f?.height ?? 0 + relativeHeight
          )
        );
      });
    _lastArea = Rect.fromLTWH(x, y, width, height);

    // ja que a area atual é a mesma area do colisor do hitbox
    hitbox.colisionDetector.area = _lastArea;
    */
  }

  /// Set position and call the [updatePosition]
  void setPosition(double x, double y) {
    this.x = x;
    this.y = y;
    updateArea();
  }

  /// Set area from a rect and call the [updatePosition]
  void setArea(Rect rect) {
    this.x = rect.left;
    this.y = rect.top;
    this.width = rect.width;
    this.height = rect.height;
    updateArea();
  }

  void setProportion(double proportion) {
    x -= width * proportion / 2;
    y -= height * proportion / 2;
    width += width * proportion / 2;
    height += height * proportion /2;
    updateArea(); 
  }


  @override
  void render(Canvas c) {
    _rawPoligonStructs.forEach((f) => f.render(c));
  }

  @override
  void update(double t) {
    _rawPoligonStructs.forEach((f) => f.update(t));
  }

  void rotate(double rotateDegree) {
    _rawPoligonStructs.forEach((f) => f.angle = rotateDegree);
  }
  
  @override
  bool destroy() {
    return _destroied;
  }
}