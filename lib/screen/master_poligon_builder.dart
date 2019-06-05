import 'package:flame/components/component.dart';
import 'package:flame/svg.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:poligonic/component/poligon.dart';
import 'package:poligonic/component/poligon_struct.dart';
import 'package:poligonic/core/colision_wrapper.dart';
import 'package:poligonic/core/component_cache.dart';
import 'package:poligonic/core/gesture_wrapper.dart';
import 'package:poligonic/core/listbox.dart';
import 'package:poligonic/core/router_wrapper.dart';
import 'package:poligonic/factory/proportion_factory.dart';
import 'package:poligonic/factory/rect_factory.dart';
import 'package:poligonic/main.dart';
import 'package:poligonic/screen/partial/master_poligon_maker.dart';
import 'package:poligonic/screen/poligon_builder.dart';

/// Tela de construtor de poligonos
/// Constroi uma estrutura e adiciona ela em uma lista empilhada
/// conforme a prioridade dos componentes.
/// Com base na lista um comando final [make] ira gerar o [Poligon]
/// Tambem deve carregar o [Poligon] do database e permitir ediçoes
class MasterPoligonBuilder extends BaseGame with GestureWrapper {
  // Rotas para outras telas
  final Router _router;
  final Size screen; // Para proporçoes
  final ProportionFactory _proportionFac;
  final String roleName;
  final RouterWrapper options;

  // Colisores para invocar eventos ou delegar para manipuladores
  final _tapColisions = ColisionWrapper();
  final _dragColisions = ColisionWrapper();
  final _holdTap = HoldTap();

  MasterPoligonMaker _masterPoligonMaker;
  get poligonMaker => _masterPoligonMaker;

  Minitela minitela; 

  MasterPoligonBuilder(this._router, this.roleName, this.options) : 
  this.screen = _router.screen,
  this._proportionFac = ProportionFactory(_router.screen)
  {
    // background
    add(RectProportional.fromLTRB(screen, 0, 0, 1, 1, Colors.lightBlue[100]));

    // area de construcao
    var makerArea = _proportionFac.getRectLTRB(0.01, 0.02, 0.81, 0.72);
    _masterPoligonMaker = MasterPoligonMaker.fromRect(makerArea, Colors.green, roleName);
    _tapColisions.addColision(makerArea, 
      (action) {
        //_masterPoligonMaker.tapInput(action)
      }
    );
    _dragColisions.addColision(makerArea, 
      (action) =>
        _masterPoligonMaker.dragInput(action)
    );
    add(RectProportional.fromLTRB(screen, 0.01, 0.2, 0.81, 0.72, Colors.white));

    var menu = Listbox(_proportionFac.getRectLTRB(0, 0.85, 1, 1));

    menu.add(0.055, 1);
    // cancel
    menu.add(0.14, 1, (rect) {
      _addSvgWithColision('svg/error.svg', rect, (action) {
        // TODO: pop-up p/ confirmar o cancel
        options.cancel(_router);
      });
    });

    menu.add(0.055, 1);
    // confirm
    menu.add(0.14, 1, (rect) {
      _addSvgWithColision('svg/success.svg', rect, (action) {
        ComponentCache.add(_masterPoligonMaker.make());
        options.apply(_router);
      });
    });

    menu.add(0.11, 1);
    menu.add(0.1625, 1);
    menu.add(0.11, 1);

    // TODO: Abrir seleçao de poligonos pre criados para assim ir para a verdadeira seleçao
    // add poligon
    menu.add(0.1625, 1, (rect) {
      _addSvgWithColision('svg/plus.svg', rect, (action) {
        // TODO: adicionar nome unico, ou mudalo pelo struct builder
        //_router.toPoligonStructBuilder(PoligonBuilder(_router, this, ""));
      });
    });

    var prioridades = Listbox(_proportionFac.getRectLTRB(0.01, 0.74, 0.99, 0.845));

    prioridades.add(0.055, 1);
    // up
    prioridades.add(0.11, 1, (rect) {
      _addSvgWithColision('svg/caret-arrow-up.svg', rect, (action) {
        _masterPoligonMaker.selectedToUp();
      });
    });
    prioridades.add(0.06, 1);
    // down
    prioridades.add(0.11, 1, (rect) {
      _addSvgWithColision('svg/caret-down.svg', rect, (action) {
        _masterPoligonMaker.selectedToDown();
      });
    });
    prioridades.add(0.1, 1);
    // ---------------------- 0.435
    // rotate left
    prioridades.add(0.11, 1, (rect) {
      _addSvgHoldTap('svg/rotate-left.svg', rect, (action, time) {
        _currentStruct.rotate(_currentStruct.midPoint, (time * screen.width / 10000));
      });
    });
    prioridades.add(0.06, 1);
    // rotate right
    prioridades.add(0.11, 1, (rect) {
      _addSvgHoldTap('svg/rotate-to-right.svg', rect, (action, time) {
        _currentStruct.rotate(_currentStruct.midPoint, (-time * screen.width / 10000));
      });
    });
    prioridades.add(0.1, 1, (f){});
    // ---------------------- 0.815
    // edit
    prioridades.add(0.16, 1, (rect) {
    _addSvgWithColision('svg/edit.svg', rect, (action) {
        // TODO:
      });
    });
    prioridades.add(0.02, 1);
    
    var rightBar = Listbox(_proportionFac.getRectLTRB(0.84, 0.01, 0.999, 0.75));

    // lixeira:
    rightBar.add(1, 0.15, (rect) {
      _addSvgWithColision('svg/trash.svg', rect, (action) {
        _masterPoligonMaker.killSelected();
        updateNavegador(0);
      });
    });

    // grid
    rightBar.add(1, 0.15, (rect) {
      _addSvgWithColision('svg/hash.svg', rect, (action) {
        // TODO: GRID
      });
    });

    rightBar.add(1, 0.03);
    // up
    rightBar.add(1, 0.10, (rect) {
      _addSvgWithColision('svg/chevron-arrow-up.svg', rect, (action) {
        updateNavegador(-1);
      });
    });
    // selected
    rightBar.add(1, 0.14, (rect) {
      add(RectProportional.flatRect(rect, Colors.white));
      minitela = Minitela(rect);
      add(minitela);
    });
    // down
    rightBar.add(1, 0.10, (rect) {
      _addSvgWithColision('svg/chevron-arrow-down.svg', rect, (action) {
        updateNavegador(-1);
      });
    });
    rightBar.add(1, 0.03);

    rightBar.add(1, 0.05);
    // size plus
    rightBar.add(1, 0.075, (rect) {
      _addSvgHoldTap('svg/add.svg', rect, (action, time) {
        _masterPoligonMaker.selected.setProportion(time * screen.width / 1000);
      });
    });
    rightBar.add(1, 0.03);
    // size minus
    rightBar.add(1, 0.075, (rect) {
      _addSvgHoldTap('svg/minus.svg', rect, (action, time) {
        _masterPoligonMaker.selected.setProportion(-time * screen.width / 1000);
      });
    });
    rightBar.add(1, 0.07);
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

  _addSvgHoldTap(String name, Rect rect, f(Offset action, double time)) {
    _addSvg(name, rect);
    _holdTap.addWorker(rect, f);
  }

  // OTHER COMPONENTS:
  PoligonStruct _currentStruct;

  void updateNavegador(int x) {
    if(_currentStruct != null) _currentStruct.destroied = true;
    _masterPoligonMaker.moveSelected(x);
    //TODO: _currentStruct = newCurrentStruct(this, _masterPoligonMaker.selected);
  }

  // Necessario para renderizar o maker correto
  @override
  void render(Canvas c) {
    super.render(c);
      _masterPoligonMaker.render(c);
    // minitelas
    if(_currentStruct != null) _currentStruct.render(c);
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

// menu para escolher qual poligon struct esta
// Tambem ja posiciona as minitelas nos lugares corretos
// FIXME: Juntar a area de atuacao deste com a area branca dos navegadores
// para que assim nao seja necessario realizar uma alteracao aqui quando uma
// la ocorrer
PoligonStruct newCurrentStruct(MasterPoligonBuilder builder, PoligonStruct p) {
  assert(builder != null, builder.screen != null);
  
  if(p != null && p.routes != null) {
    return PoligonStruct.positioned(
      p.routes, 
      p.paint, 
      ProportionFactory(builder.screen).getRectLTRB(0.82, 0.50, 0.99, 0.60)
    );
  }
  else return null;
}

/// Mostra um poligon no local adequado
class Minitela extends PositionComponent {
  Poligon _poligon;
  final Rect position;

  Minitela(this.position);

  setStructFlat(Poligon p) {
    if(_poligon != null)
      _poligon.destroied = true;
    _poligon = p.copy();
    _poligon.setArea(position);
  }

  @override
  void render(Canvas c) {
    if(_poligon != null)
      _poligon.render(c);
  }

  @override
  void update(double t) {
  }

}