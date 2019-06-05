import 'dart:math' as math;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/components/component.dart';
import 'package:poligonic/component/point.dart';
import 'package:poligonic/core/colision_detector.dart';

/// Classe responsavel por criar a shape basica de um [Poligon]
/// Ele contem sua posiçao atual para permitir ser alterado de acordo com o mundo exterior
class PoligonStruct extends PositionComponent {
  final List<Offset> routes; // from List<Offset>
  List<Offset> positionedRoutes = List<Offset>();
  Paint paint;
  bool _destroied = false;

  set destroied(bool v) { 
    if(_destroied)
      makeDestruction(1, 100, 2);
  }

  Rect get area => Rect.fromLTRB(x, y, x + width, y + height);
  Rect get internalArea { 
    if(positionedRoutes.length > 1)
      return ColisionDetector(positionedRoutes).area;
    else
      return null;
  }
  ColisionDetector get colision {
    if(positionedRoutes.length > 1)
      return ColisionDetector(positionedRoutes);
    else
      return null;
  }
  Offset get midPoint => Offset(width / 2 + x, height / 2 + y);

  /// Cria apenas um [PoligonStruct]
  /// 
  /// Utilizado principalmente para carregar do database
  PoligonStruct(this.routes, this.paint);

  /// Cria o [PoligonStruct] de forma posicionada
  /// 
  /// Utilizado principalmente para carregar na tela
  PoligonStruct.positioned(this.routes, this.paint, Rect position)
    {
      _setPositionFromRect(this, position);
      updatePosition();

      assert(this.positionedRoutes.any((f) => f == null) == false);
    }

  /// Cria o [PoligonStruct] a partir de pontos ainda nao processados
  /// 
  /// Tambem permite que uma posiçao seja passada para que o [PoligonStruct] seja posicionado logo em seguida
  /// 
  /// Utilizado principalmente para processar estruturas e armazenar de forma "raw"
  PoligonStruct.makeFromPoints(List<Point> points, this.paint, [Rect position]) :
    this.routes = _makeFromPoints(points)
    {
      if(position != null) {
        _setPositionFromRect(this, position);
        updatePosition();

        assert(this.positionedRoutes.any((f) => f == null) == false);
      }
    }

  /// Cria o [PoligonStruct] a partir de pontos ainda nao processador e em uma area determinada
  /// 
  /// Utilizado principalmente para processar estruturas dentro de uma area fixa
  PoligonStruct.makeFromPointsAndArea(List<Point> points, this.paint, Rect area, [Rect position]) :
    this.routes = _makeFromPoints(points, area)
    {
      assert(this.routes.any((f) => f == null) == false);

      if(position != null) { 
        _setPositionFromRect(this, position);
        updatePosition();

        assert(this.positionedRoutes.any((f) => f == null) == false);
      }

      assert(this.routes.any((f) => f == null) == false);
    }

  /// Cria o [PoligonStruct] a partir de Offset ainda nao processador e em uma area determinada
  /// 
  /// Utilizado principalmente para processar estruturas dentro de uma area fixa
  PoligonStruct.makeFromOffsetAndArea(List<Offset> points, this.paint, Rect area, [Rect position]) :
    this.routes = _makeFromOffset(points, area)
    {
      assert(this.routes.any((f) => f == null) == false);

      if(position != null) {
        _setPositionFromRect(this, position);
        updatePosition();

        assert(this.positionedRoutes.any((f) => f == null) == false);
      }

      assert(this.routes.any((f) => f == null) == false);
    }

  static void _setPositionFromRect(PoligonStruct p, Rect position) {
    p.x = position.left;
    p.y = position.top;
    p.width = position.width;
    p.height = position.height;
  }

  static List<Offset> _makeFromPoints(List<Point> points, [Rect area]) {
    area ??= ColisionDetector(List<Offset>.from(
      points.map((f) => Offset(f.dx, f.dy))
    )).area;

    // nao pode ocorrer, pois nao deve existir um poligono de "lados reversos"
    //assert(points.any((f) => f.dx < area.left || f.dy < area.top) == false);

    return List<Offset>.from(
        points.map<Offset>(
          (f) => Offset(
            (f.dx - area.left) / area.width,
            (f.dy - area.top) / area.height
          )
        )
      );
  }

  static List<Offset> _makeFromOffset(List<Offset> points, [Rect area]) {
    area ??= ColisionDetector(List<Offset>.from(
      points.map((f) => Offset(f.dx, f.dy))
    )).area;

    // nao pode ocorrer, pois nao deve existir um poligono de "lados reversos"
    //assert(points.any((f) => f.dx < area.left || f.dy < area.top) == false);

    return List<Offset>.from(
        points.map<Offset>(
          (f) => Offset(
            (f.dx - area.left) / area.width,
            (f.dy - area.top) / area.height
          )
        )
      );
  }

  @override
  void render(Canvas c) {
    assert(routes != null);

    c.drawPath(
      Path()..addPolygon(this.positionedRoutes, true),
      paint..style = PaintingStyle.fill
    );
  }

  @override
  void update(double t) {
  }

  @override
  bool destroy() {
    return _destroied;
  }

  /// Make a deep copy from this struct
  PoligonStruct copy() {
    var newPoligonStruct = PoligonStruct.positioned(
      List<Offset>.from(routes),
      Paint()..color = paint.color,
      Rect.fromLTRB(x, y, width + x, height + y)
    );
    newPoligonStruct.angle = this.angle;
    newPoligonStruct.anchor = this.anchor;
    newPoligonStruct._destroied = this._destroied;
    return newPoligonStruct;
  }

  /// Update the routes on the designed area (x,y,width,height)
  void updatePosition() {
    positionedRoutes = List<Offset>.from(
      routes.map<Offset>(
        (f) => Offset(
          this.width * f.dx + x,
          this.height * f.dy + y
        )
      )
    );
  }

  /// Set position and call the [updatePosition]
  void setPosition(double x, double y) {
    this.x = x;
    this.y = y;
    updatePosition();
  }

  /// Set area from a rect and call the [updatePosition]
  void setArea(Rect rect) {
    this.x = rect.left;
    this.y = rect.top;
    this.width = rect.width;
    this.height = rect.height;
    updatePosition();
  }

  void setProportion(double proportion) {
    x -= width * proportion / 2;
    y -= height * proportion / 2;
    width += width * proportion / 2;
    height += height * proportion /2;
    updatePosition(); 
  }

  // FIXME: verificar logica para rotacionar ao redor do midpoint
  Offset _rotate(Offset base, double radians, Offset point) {
    var dx = (point.dx-base.dx)*math.cos(radians) - (point.dy-base.dy) * math.sin(radians);
    var dy = (point.dx-base.dx)*math.sin(radians) - (point.dy-base.dy) * math.cos(radians);
    debugPrint(dx.toString() + dy.toString());
    return Offset(dx,dy);
  }

  void rotate(Offset base, double radians) {
    positionedRoutes = List.from(
      positionedRoutes.map<Offset>((f) => _rotate(base, radians, f))
    );
  }

  /// Define que o objeto foi destruido, e se ele deve realizar animaçao
  // FIXME: Talvez colocar em uma variavel para renderizalo em vez da estrutura principal, e assim apos sua destruiçao destruir [this]
  PoligonStructDestruction makeDestruction(int minRange, int maxRange, double time) {
    destroied = true;
    return PoligonStructDestruction.fromPoligonStruct(
      positionedRoutes, paint, time, minRange, maxRange
    );
  }
}

// FIXME: Nao funciona pois o detroy deveria ser chamado na lista de componentes, oque nao e realizado nesta estrutura atual
/// Poligono para animar a destruiçao de um [PoligonStruct]
/// TODO: Diminuir a opacidade do paint conforme o tempo
class PoligonStructDestruction extends PositionComponent {
  List<Point> points = List<Point>();
  Paint paint;

  final double time;

  final Random _random = Random();
  final int minRange, maxRange;
  int nextRandom() => minRange + _random.nextInt(maxRange - minRange);

  bool destroied = false;

  PoligonStructDestruction.fromPoligonStruct(
    List<Offset> routes,
    this.paint,
    this.time,
    this.minRange,
    this.maxRange
  ) {
    assert(routes != null);
    routes.forEach(
      (f) => points.add(Point.fromOffset(f))
    );
  }

  /// Renderiza os pontos, e uma vez que eles sao mutaveis isso facilita as coisas
  @override
  void render(Canvas c) {
    assert(points != null);
    points.forEach(
      (f) => c.drawLine(Offset(f.dx, f.dy), Offset(f.dx * 2, f.dy * 2), paint)
    );
  }

  /// Realiza a animaçao conforme o tempo por uma variavel randomica em uma range
  @override
  void update(double t) {
    if(time > 0) {
      points.forEach(
        (f) => {
          f.dx += nextRandom(),
          f.dy += nextRandom()
        } 
      );
    }
    else {
      destroied = true;
    }
  }

  @override
  bool destroy() {
    return destroied;
  }
}