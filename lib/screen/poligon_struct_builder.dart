import 'package:flame/components/component.dart';
import 'package:flame/svg.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:poligonic/component/poligon_struct.dart';
import 'package:poligonic/core/colision_wrapper.dart';
import 'package:poligonic/core/gesture_wrapper.dart';
import 'package:poligonic/core/listbox.dart';
import 'package:poligonic/core/router_wrapper.dart';
import 'package:poligonic/factory/proportion_factory.dart';
import 'package:poligonic/factory/rect_factory.dart';
import 'package:poligonic/main.dart';
import 'package:poligonic/screen/partial/poligon_struct_maker.dart';
import 'package:poligonic/screen/poligon_builder.dart';

/// Tela de construtor de poligonos
/// Constroi uma estrutura e adiciona ela em uma lista empilhada
/// conforme a prioridade dos componentes.
/// Com base na lista um comando final [make] ira gerar o [Poligon]
/// Tambem deve carregar o [Poligon] do database e permitir ediçoes
class PoligonStructBuilder extends BaseGame with GestureWrapper{
  // Rotas para outras telas
  final Router _router;
  final Size screen; // Para proporçoes
  final PoligonBuilder _poligonBuilder;
  final ProportionFactory _proportionFac;
  final RouterWrapper _options;

  // Colisores para invocar eventos ou delegar para manipuladores
  final _tapColisions = ColisionWrapper();
  final _dragColisions = ColisionWrapper();

  // DEPENDENCE MAKER:
  PoligonStructMaker _poligonStructMaker; 
  set loadOf(PoligonStruct p) => _poligonStructMaker.loadOf(p);

  PoligonStructBuilder(this._router, this._poligonBuilder, this._options) : 
  this.screen = _router.screen,
  this._proportionFac = ProportionFactory(_router.screen)
  {
    // background
    add(RectProportional.fromLTRB(screen, 0, 0, 1, 1, Colors.lightBlue[100]));

    // area de construcao
    var makerArea = _proportionFac.getRectLTRB(0.01, 0.2, 0.81, 0.72);
    _poligonStructMaker = PoligonStructMaker.fromRect(screen, 3, makerArea, Colors.green);
    _tapColisions.addColision(makerArea, (action) {
      _poligonStructMaker.tapInput(action);
    });
    _dragColisions.addColision(makerArea, (action) {
      _poligonStructMaker.dragInput(action);
    });
    add(RectProportional.fromLTRB(screen, 0.01, 0.2, 0.81, 0.72, Colors.white));

    var menu = Listbox(_proportionFac.getRectLTRB(0, 0.85, 1, 1));

    menu.add(0.055, 1);
    // cancel
    menu.add(0.14, 1, (rect) {
      _addSvgWithColision('svg/error.svg', rect, (action) {
        // TODO: confirmar o cancel
        _options.cancel(_router);
      });
    });

    menu.add(0.055, 1);
    menu.add(0.14, 1, (rect) {
      _addSvgWithColision('svg/success.svg', rect, (action) {
        if(_poligonStructMaker.points.length > 0) {
          _poligonBuilder.poligonMaker.addStruct(_poligonStructMaker.makeProportional());
          _poligonBuilder.updateNavegador(1); // muda para o atual ou apenas se 0
        }
        _options.apply(_router);
      });
    });

    // Informations TODO: adicionar limite
    add(RectProportional.fromLTRB(screen, 0.02, 0.1, 0.3, 0.18, Colors.yellow));

    var rightBar = Listbox(_proportionFac.getRectLTRB(0.84, 0.01, 0.999, 0.75));

    // lixeira:
    rightBar.add(1, 0.15, (rect) {
      _addSvgWithColision('svg/trash.svg', rect, (action) {
        _poligonStructMaker.removeLastPoint();
      });
    });

    // grid
    rightBar.add(1, 0.15, (rect) {
      _addSvgWithColision('svg/hash.svg', rect, (action) {
        // TODO: GRID
      });
    });
  }

  _addSvg(String name, Rect rect) {
    var svg = SvgComponent.fromSvg(rect.width, rect.height, Svg(name))
      ..x = rect.left
      ..y = rect.top;
    add(svg);
  }

  _addSvgWithColision(String name, Rect rect, f(Offset action)) {
    _addSvg(name, rect);
    _tapColisions.addColision(rect, f);
  }


  // Necessario para renderizar o maker correto
  @override
  void render(Canvas c) {
    super.render(c);
    _poligonStructMaker.render(c);
  }

  /*** INPUTS ***/

  @override
  void tapDown(Offset action) {
    _tapColisions.makeColision(action);
  }

  @override
  void panUpdate(Offset action) {
    _dragColisions.makeColision(action);
  }

}
