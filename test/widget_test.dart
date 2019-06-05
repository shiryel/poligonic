// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poligonic/component/poligon_struct.dart';
import 'package:poligonic/core/colision_detector.dart';
import 'package:poligonic/core/component_cache.dart';
import 'package:poligonic/core/ring_selector.dart';

import 'package:poligonic/main.dart';

void main() {
  test('Ring Selector test', () {
    var ring = RingSelector<int>();
    // inicial
    expect(ring.length, 0);
    expect(ring.selected, null);
    ring.moveIterator(0);
    expect(ring.length, 0);
    expect(ring.selected, null);

    // adiçoes
    ring.add(10);
    expect(ring.length, 1);
    expect(ring.selected, 10);
    ring.add(20);
    expect(ring.length, 2);
    expect(ring.selected, 10);

    // movimentos
    ring.moveIterator(1);
    expect(ring.length, 2);
    expect(ring.selected, 20);
    ring.moveIterator(1);
    expect(ring.selected, 10);
    ring.moveIterator(1);
    expect(ring.selected, 20);
    ring.moveIterator(1);
    expect(ring.selected, 10);
    ring.moveIterator(1);
    expect(ring.selected, 20);
    ring.moveIterator(3);
    expect(ring.selected, 10);
    ring.moveIterator(-1);
    expect(ring.selected, 20);
    ring.moveIterator(-1);
    expect(ring.selected, 10);
    ring.moveIterator(-1);
    expect(ring.selected, 20);
    ring.moveIterator(-1);
    expect(ring.selected, 10);
    ring.moveIterator(-1);
    expect(ring.selected, 20);
    ring.moveIterator(-3);
    expect(ring.selected, 10);

    // swaper
    ring.add(30); // >10 20 30
    expect(ring.selected, 10);
    ring.moveSelected(1); // 20 >10 30
    expect(ring.selected, 10);
    ring.moveIterator(-1); // >20 10 30
    expect(ring.selected, 20);
    ring.moveSelected(-1); // 30 10 >20
    expect(ring.selected, 20);
    ring.moveIteratorToLast(); // 30 10 >20
    expect(ring.selected, 20);
    ring.moveIterator(-1); // 30 >10 20
    expect(ring.selected, 10);

    // deletes
    ring.removeSelected(); // >30 20 
    expect(ring.selected, 30);
    ring.moveIterator(1); // 30 >20
    expect(ring.selected, 20); 
    ring.removeSelected(); // 30
    expect(ring.selected, 30);
    ring.removeSelected(); // null
    expect(ring.selected, null);
  });

  test('Colision wrapper', () {
    var colision1 = ColisionDetector.fromLTRB(100, 100, 200, 200);

    // esta dentro do colision 1
    var colision2 =ColisionDetector.fromLTRB(120, 120, 150, 150); 

    // esta parcialmente dentro do colision 1
    var colision3 =ColisionDetector.fromLTRB(50, 100, 150, 150);

    // verificar colisores
    expect(colision1.isFullInside(colision2), false);
    expect(colision1.anyOutside(colision2), true);
    expect(colision1.anyOutside(colision3), true);

    expect(colision2.isFullInside(colision1), true);
    expect(colision2.anyOutside(colision1), false);

    expect(colision3.isFullInside(colision1), false);
    expect(colision3.anyOutside(colision1), true);

    // verificar metricas
    expect(colision1.area, Rect.fromLTRB(100, 100, 200, 200));
    expect(colision1.area.width, 100);
    expect(colision1.area.height, 100);
  });

  test('Poligon Struct', () {
    // quadrado
    var route1 = List<Offset>();
    route1.add(Offset(0, 0));
    route1.add(Offset(1, 0));
    route1.add(Offset(1, 0));
    route1.add(Offset(0, 1));

    // 90 percent
    var route2 = List<Offset>();
    route2.add(Offset(.9, .9)); // rigth/bottom
    route2.add(Offset(.9, .1)); // rigth/top
    route2.add(Offset(.1, .9)); // left/top
    route2.add(Offset(.1, .1)); // left/bottom

    // preparando estruturas
    var struct1 = PoligonStruct(route1, Paint()..color = Colors.black);

    var struct2 = PoligonStruct.positioned(
      route1,
      Paint()..color = Colors.black,
      Rect.fromLTRB(100, 100, 400, 400)
      );

    var struct3 = PoligonStruct.positioned(
      route2,
      Paint()..color = Colors.black,
      Rect.fromLTRB(100, 100, 400, 400)
      );

    // testando a area, a area interna e o midpoint
    expect(struct1.area, Rect.fromLTRB(0, 0, 0, 0));
    expect(struct2.area, Rect.fromLTRB(100, 100, 400, 400));
    expect(struct3.area, Rect.fromLTRB(100, 100, 400, 400));
    expect(struct1.internalArea, null); // nao posicionado
    expect(struct2.internalArea, Rect.fromLTRB(100, 100, 400, 400));
    expect(struct3.internalArea, Rect.fromLTRB(130, 130, 370, 370));
    expect(struct1.midPoint, Offset(0, 0));
    expect(struct2.midPoint, Offset(250, 250));
    expect(struct3.midPoint, Offset(250,250));

    // testando mudança de posicao
    struct2.setPosition(10, 10);
    expect(struct2.area, Rect.fromLTRB(10, 10, 310, 310));
    expect(struct2.internalArea, Rect.fromLTRB(10, 10, 310, 310));
    expect(struct2.midPoint, Offset(160, 160));

    struct2.setArea(Rect.fromLTRB(50, 50, 300, 300));
    expect(struct2.area, Rect.fromLTRB(50, 50, 300, 300));
    expect(struct2.internalArea, Rect.fromLTRB(50, 50, 300, 300));
    expect(struct2.midPoint, Offset(175, 175));

    struct2.angle = 10.0;
    var copy2 = struct2.copy();
    expect(copy2.routes, struct2.routes);
    expect(copy2.positionedRoutes, struct2.positionedRoutes);
    expect(copy2.angle, struct2.angle);

    struct3.angle = 10.0;
    var copy3 = struct3.copy();
    expect(copy3.routes, struct3.routes);
    expect(copy3.positionedRoutes, struct3.positionedRoutes);
    expect(copy3.angle, struct3.angle);
  });

  test('Component Cache', () {
    var component1 = PoligonStruct(List<Offset>(), Paint());
    var component2 = PoligonStruct(List<Offset>(), Paint());

    ComponentCache.add(component1);
    var cache1 = ComponentCache.components;
    
    expect(cache1[0], component1);
    expect(cache1.length, 1);

    ComponentCache.add(component2);
    var cache2 = ComponentCache.components;
    
    expect(cache2[1], component2);
    expect(cache2.length, 2);
    expect(cache1.length, 2); // nao modifica pois é imutavel

    ComponentCache.remove(component1);
    var cache3 = ComponentCache.components;
    expect(cache3[0], component2);
    expect(cache3.length, 1);
    expect(cache2.length, 1); // nao modifica pois é imutavel
    expect(cache1.length, 1); // nao modifica pois é imutavel
  });
}