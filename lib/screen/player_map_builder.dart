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
import 'package:poligonic/screen/partial/player_map_maker.dart';
import 'package:poligonic/screen/partial/poligon_maker.dart';
import 'package:poligonic/screen/poligon_struct_builder.dart';

class PlayerMapBuilder extends BaseGame with GestureWrapper {
  final Router _router;
  final Size screen;
  final ProportionFactory _proportionFactory;
  final RouterWrapper _options;
  PlayerMapMaker _mapMaker;
  final minitelas = List<Minitela>(4);
  var poligonoSelecionado = 0;

  Minitela getSelectedPoligon() => minitelas[poligonoSelecionado];
  
  final _tapColisions = ColisionWrapper();
  final _dragColisions = ColisionWrapper();
  final _holdTap = HoldTap();

  /// Mapa criado com o tamanho da W * 3 e W * 20
  PlayerMapBuilder(this._router, this.screen, this._options) :
  this._proportionFactory = ProportionFactory(screen)
  {
    //Area de construçao
    var makerArea = _proportionFactory.getRectLTRB(0.15, 0.005, 0.85, 0.85);
    _mapMaker = PlayerMapMaker.fromRect(makerArea);
    add(RectProportional.flatRect(makerArea, Colors.lightBlue[50]));

    _tapColisions.addColision(makerArea, (action) {
      _mapMaker.addStruct(Rect.fromLTWH(action.dx, action.dy, screen.width / 18, screen.height / 18), getSelectedPoligon().poligon.copy());
      _mapMaker.tapInput(action);
    });

    _dragColisions.addColision(makerArea, (action) {
      _mapMaker.dragInput(action);
    });

    var menu = Listbox(_proportionFactory.getRectLTRB(0, 0.86, 1, 0.99));

    // Remove
    menu.add(0.15, 1, (r) {
      _addSvgWithColision('svg/trash.svg', r, (action){
        minitelas[poligonoSelecionado].poligon = null;
      });
    });

    menu.add(0.025, 1);

    // 1
    menu.add(0.14, 1, (r) {
      add(RectProportional.flatRect(r, Colors.lightBlue[100]));
      minitelas[0] = Minitela(r);
      _tapColisions.addColision(r, (action) => poligonoSelecionado = 0);
    });

    menu.add(0.01, 1);
    // 2
    menu.add(0.14, 1, (r) {
      add(RectProportional.flatRect(r, Colors.lightBlue[100]));
      minitelas[1] = Minitela(r);
      _tapColisions.addColision(r, (action) => poligonoSelecionado = 1);
    });

    menu.add(0.01, 1);
    // 3
    menu.add(0.14, 1, (r) {
      add(RectProportional.flatRect(r, Colors.lightBlue[100]));
      minitelas[2] = Minitela(r);
      _tapColisions.addColision(r, (action) => poligonoSelecionado = 2);
    });

    menu.add(0.01, 1);
    // 4
    menu.add(0.14, 1, (r) {
      add(RectProportional.flatRect(r, Colors.lightBlue[100]));
      minitelas[3] = Minitela(r);
      _tapColisions.addColision(r, (action) => poligonoSelecionado = 3);
    });

    // = 60

    menu.add(0.025, 1);
    // New poligon
    menu.add(0.15, 1, (r) {
      _addSvgWithColision("svg/plus.svg", r, (action) {
        var opts = RouterWrapper();
        opts.apply = (r) {
          minitelas[poligonoSelecionado].poligon = ComponentCache.selected;
          r.backTo(this);
        };
        opts.cancel = (r) {
          r.backTo(this);
        };
        _router.toPoligonBuilder(opts, "defense"); // FIXME: adicionar a enum
      });
    });

    var topMenu = Listbox(_proportionFactory.getRectLTRB(0, 0, 1, 0.15));

    topMenu.add(0.02, 1);
    // cancel
    topMenu.add(0.14, 1, (rect) {
      _addSvgWithColision('svg/error.svg', rect, (action) {
        // TODO: confirmar o cancel
        _options.cancel(_router);
      });
    });

    topMenu.add(0.69, 1);
    // confirm
    topMenu.add(0.14, 1, (rect) {
      _addSvgWithColision('svg/success.svg', rect, (action) {
        ComponentCache.add(_mapMaker.make()); 
        ComponentCache.selected = ComponentCache.components.last;
        assert(ComponentCache.components.length > 0);

        _options.apply(_router);
      });
    });

    var sideMenu = Listbox(_proportionFactory.getRectLTRB(0, 0.70, 0.15, 0.86));

    sideMenu.add(1, 1, (rect) {
      _addSvgWithColision('svg/back.svg', rect, (action) {
        _mapMaker.list.removeLast();
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

  // FIXME: provavelmente só sera utilizado no maker para arrastar onde os poligonos ficaram na tela
  _addSvgHoldTap(String name, Rect rect, f(Offset action, double time)) {
    _addSvg(name, rect);
    _holdTap.addWorker(rect, f);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _mapMaker.render(canvas);
    minitelas.forEach((f) => f.render(canvas));
  }

  @override
  void update(double t) {
    super.update(t);
    _mapMaker.update(t);
  }

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
}

class Minitela extends PositionComponent {
  Poligon _poligon;
  final Rect position;

  Minitela(this.position);

  set poligon(Poligon v) {
    _poligon = v;
    _poligon?.setArea(position);
  }

  Poligon get poligon => _poligon;

  @override
  void render(Canvas c) {
    _poligon?.render(c);
  }

  @override
  void update(double t) {
    _poligon.update(t);
  }

}