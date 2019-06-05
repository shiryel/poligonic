import 'package:flutter/material.dart';
import 'package:flame/components/component.dart';
import 'package:poligonic/component/point.dart';
import 'package:poligonic/component/poligon_struct.dart';
import 'package:poligonic/core/colision_detector.dart';

/// Construtor de [PoligonStruct]
/// Responavel por criar um local para criaçao de [PoligonStruct]
/// A ideia é utilizalo com o [PoligonBuilder] em uma unica tela e
/// permitir a criaçao de poligonos completos, apos isso estes serao
/// juntados pelo [MasterPoligonBuilder]
class PoligonStructMaker extends PositionComponent {
  var _points = List<Point>(); // Compem o [PoligonStruct]
  int _holdPoint; // Para permitir a movimentaçao dos [points]

  final Size screen; // Para converter proporcionalmente á tela
  final double pointRadius; // Para poder selecionar os pontos
  final Paint paint;
  final Rect area;

  List<Point> get points => _points;

  PoligonStructMaker.fromRect(this.screen, this.pointRadius, 
      this.area, MaterialColor color) :
    this.paint = Paint()..color = color;

  @override
  void render(Canvas c) {
    assert(_points != null);
    assert(paint != null);
    _points.forEach(
      (f) => c.drawCircle(f.toOffset(), pointRadius, paint)
    );

    c.drawPath(
      Path()
        ..addPolygon(
          List<Offset>.from(_points.map<Offset>((f) => Offset(f.dx, f.dy))),
          true),
      paint..style = PaintingStyle.stroke
    );
  }

  @override
  void update(double t) {
  }

  /* HELPERS */

  ColisionDetector get hitbox => ColisionDetector.fromRect(area);

  // ===== INPUTS ======

  void dragInput(Offset offset) {
    if(_holdPoint != null) {
      _points[_holdPoint].dx = offset.dx;
      _points[_holdPoint].dy = offset.dy;
    }
  }

  void tapInput(Offset offset) {
    assert(_points != null);
    // Para pegar um ponto ja colocado
    if(_points.any((p) => _verifyColision(p, offset))) {
      _holdPoint = _points.indexWhere((p) => _verifyColision(p, offset));
    }
    // senao inserir um novo ponto
    else {
      _points.add(Point.fromOffset(offset));
    }
  }

  // ===== PRIVATE =====

  // Para verificar a colisao em um ponto de acordo com o tamanho dele
  bool _verifyColision(Point point, Offset offset) {
    if((point.dx - offset.dx).abs() <= pointRadius
      || (point.dy - offset.dy).abs() <= pointRadius)
        return true;

    return false;
  }

  // ===== PUBLIC =====

  /// Cria um [PoligonStruct] se baseando no tamanho do mesmo
  /// Sendo assim, o [PoligonStruct] ocupara "sem deixar espaços" um [Rect] ou [Colision]
  PoligonStruct make() {
    assert(_points != null);
    assert(_points.any((f) => f.dx / screen.width > 1) == false);
    assert(_points.any((f) => f.dy / screen.height > 1) == false);

    return PoligonStruct.makeFromPoints(_points, paint);
  }

  /// Realiza o make, porem mantem no tamanho original deste [PoligonStructMaker]
  /// Util para transpor para o [PoligonStruct] e subsequente derivar na [Minitala] do mesmo
  PoligonStruct makeProportional() {
    assert(_points != null);
    assert(_points.any((f) => f.dx / screen.width > 1) == false);
    assert(_points.any((f) => f.dy / screen.height > 1) == false);

    var colision = ColisionDetector(List<Offset>.from(
      points.map((f) => Offset(f.dx, f.dy))
    )).area;

    return PoligonStruct.makeFromPoints(
      _points, 
      paint,
      Rect.fromLTWH(colision.left, colision.top, colision.width, colision.height)
    );
  }

  /// Utilizado para alterar uma estrutura ja existente
  void loadOf(PoligonStruct p) {
    assert(p.routes != null);
    p.routes.forEach(
      (f) => _points.add(Point(area.width * f.dx + area.left, area.height * f.dy + area.top))
    );
  }

  /// Reseta a estrutura, utilizado para criar novas estruturas
  void reset() {
    _points = List<Point>();
    _holdPoint = null;
  }

  void removeLastPoint() {
    if(_points.length > 0)
      _points.removeAt(_points.length - 1);
  }
}