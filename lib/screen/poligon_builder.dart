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
import 'package:poligonic/screen/master_poligon_builder.dart';
import 'package:poligonic/screen/partial/poligon_maker.dart';
import 'package:poligonic/screen/poligon_struct_builder.dart';

// TODO: tetar e criar o maker no componente para passar para o menu e fazelo mover corretamente
/// Tela de construtor de poligonos
/// Constroi uma estrutura e adiciona ela em uma lista empilhada
/// conforme a prioridade dos componentes.
/// Com base na lista um comando final [make] ira gerar o [Poligon]
/// Tambem deve carregar o [Poligon] do database e permitir ediçoes
class PoligonBuilder extends BaseGame with GestureWrapper{
  // Rotas para outras telas
  final Router _router;
  final Size screen; // Para proporçoes
  final ProportionFactory _proportionFac;
  final RouterWrapper _options;
  final String role;

  // Colisores para invocar eventos ou delegar para manipuladores
  final _tapColisions = ColisionWrapper();
  final _dragColisions = ColisionWrapper();
  final _holdTap = HoldTap();

  PoligonMaker _poligonMaker;
  PoligonMaker get poligonMaker => _poligonMaker;

  Minitela minitela; 

  PoligonBuilder(this._router, this._options, this.role) : 
  this.screen = _router.screen,
  this._proportionFac = ProportionFactory(_router.screen)
  {
    // OPTIONS
    var structOptions = RouterWrapper();
    structOptions.apply = (r) {
      r.backTo(this);
    };

    structOptions.cancel = (r) {
      // FIXME: r.toPoligonBuilder(_options);
    };

    // background
    add(RectProportional.fromLTRB(screen, 0, 0, 1, 1, Colors.lightBlue[100]));

    // area de construcao
    var makerArea = _proportionFac.getRectLTRB(0.01, 0.2, 0.81, 0.72);
    _poligonMaker = PoligonMaker.fromRect(makerArea, Colors.green);
    _tapColisions.addColision(makerArea, 
      (action) =>
        _poligonMaker.tapInput(action)
    );
    _dragColisions.addColision(makerArea, 
      (action) =>
        _poligonMaker.dragInput(action)
    );
    add(RectProportional.fromLTRB(screen, 0.01, 0.2, 0.81, 0.72, Colors.white));

    var menu = Listbox(_proportionFac.getRectLTRB(0, 0.85, 1, 1));

    menu.add(0.055, 1);
    // cancel
    menu.add(0.14, 1, (rect) {
      _addSvgWithColision('svg/error.svg', rect, (action) {
        // TODO: confirmar o cancel
        _options.cancel(_router);
        //FIXME: _router.toMasterPoligonBuilder(pai.roleName, pai.options);
      });
    });

    menu.add(0.055, 1);
    // confirm
    menu.add(0.14, 1, (rect) {
      _addSvgWithColision('svg/success.svg', rect, (action) {
        ComponentCache.add(Poligon.makeFromStruct(this._poligonMaker.list, this._poligonMaker.area, role, 0, null));
        ComponentCache.selected = ComponentCache.components.last;
        assert(ComponentCache.components.length > 0);

        _options.apply(_router);
        //FIXME: _router.toMasterPoligonBuilder(pai.roleName, pai.options);
      });
    });

    menu.add(0.11, 1);
    // palete
    menu.add(0.1625, 1, (rect) {
      _addSvgWithColision('svg/painting-palette.svg', rect, (action) {
        _router.toPoligonBuilderColorPicker(this);
        updateNavegador(0);
      });
    });

    menu.add(0.11, 1);
    // add struct
    menu.add(0.1625, 1, (rect) {
      _addSvgWithColision('svg/edit.svg', rect, (action) {
        _router.toPoligonStructBuilder(this, structOptions);
      });
    });

    var prioridades = Listbox(_proportionFac.getRectLTRB(0.01, 0.74, 0.99, 0.845));

    prioridades.add(0.055, 1);
    // up
    prioridades.add(0.11, 1, (rect) {
      _addSvgWithColision('svg/caret-arrow-up.svg', rect, (action) {
        _poligonMaker.selectedToUp();
      });
    });
    prioridades.add(0.06, 1);
    // down
    prioridades.add(0.11, 1, (rect) {
      _addSvgWithColision('svg/caret-down.svg', rect, (action) {
        _poligonMaker.selectedToDown();
      });
    });
    prioridades.add(0.1, 1);
    // ---------------------- 0.435
    // rotate left
    prioridades.add(0.11, 1, (rect) {
      _addSvgHoldTap('svg/rotate-left.svg', rect, (action, time) {
        var p = _poligonMaker.selected;
        p.rotate(p.midPoint, (time * screen.width / 10000));
      });
    });
    prioridades.add(0.06, 1);
    // rotate right
    prioridades.add(0.11, 1, (rect) {
      _addSvgHoldTap('svg/rotate-to-right.svg', rect, (action, time) {
        var p = _poligonMaker.selected;
        p.rotate(p.midPoint, (-time * screen.width / 10000));
      });
    });
    prioridades.add(0.1, 1, (f){});
    // ---------------------- 0.815
    // edit
    prioridades.add(0.16, 1, (rect) {
    _addSvgWithColision('svg/3d-cube.svg', rect, (action) {
        if(_poligonMaker.selected != null)
          _router.toPoligonStructBuilder(this, structOptions, (PoligonStructBuilder p) {
            p.loadOf = PoligonStruct.makeFromOffsetAndArea(_poligonMaker.selected.positionedRoutes, _poligonMaker.selected.paint, _poligonMaker.area);
          });
      });
    });
    prioridades.add(0.02, 1);
    
    var rightBar = Listbox(_proportionFac.getRectLTRB(0.84, 0.01, 0.999, 0.75));

    // lixeira:
    rightBar.add(1, 0.15, (rect) {
      _addSvgWithColision('svg/trash.svg', rect, (action) {
        _poligonMaker.killSelected();
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
        _poligonMaker.selected.setProportion(time * screen.width / 1000);
      });
    });
    rightBar.add(1, 0.03);
    // size minus
    rightBar.add(1, 0.075, (rect) {
      _addSvgHoldTap('svg/minus.svg', rect, (action, time) {
        _poligonMaker.selected.setProportion(-time * screen.width / 1000);
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

  void updateNavegador(int x) {
    _poligonMaker.moveSelected(x);
    minitela.setStructFlat(PoligonStruct.makeFromOffsetAndArea(_poligonMaker.selected.positionedRoutes, _poligonMaker.selected.paint, _poligonMaker.area));
  }

  // Necessario para renderizar o maker correto
  @override
  void render(Canvas c) {
    super.render(c);
    _poligonMaker.render(c);
  }

  @override
  void update(double t) {
    super.update(t);
    _poligonMaker.update(t);
    _holdTap.update(t);
  }

  /*** INPUTS ***/

  Offset _tapDown;
  @override
  void tapDown(Offset action) {
    _tapDown = action;
    _tapColisions.makeColision(action);
    _holdTap.down(action);
  }

  @override
  void tapUp(Offset action) {
    _tapDown = null;
    _holdTap.cancel();
  }

  @override
  void tapCancel() {
    _holdTap.cancel();
  }

  @override
  void longPressStart(Offset action) {
    _holdTap.down(action);
  }

  @override
  void longPressEnd(Offset action) {
    _holdTap.cancel();
  }

  @override
  void panUpdate(Offset action) {
    if(action != null)
      _dragColisions.makeColision(action);
  }

}

// TODO: Manter a proporçao original, ajustando-a com a posiçáo na [Minitela]
/// Mostra uma estrutura no local adequado
class Minitela extends PositionComponent {
  PoligonStruct _struct;
  final Rect position;

  Minitela(this.position);

  setStructFlat(PoligonStruct p) {
    if(_struct != null)
      _struct.destroied = true;
    _struct =PoligonStruct.positioned(
      p.routes,
      p.paint,
      position
    );
  }

  @override
  void render(Canvas c) {
    if(_struct != null)
      _struct.render(c);
  }

  @override
  void update(double t) {
  }

}