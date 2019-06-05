import 'dart:math';

import 'package:flame/components/component.dart';
import 'package:flame/svg.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:poligonic/component/player_map.dart';
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
import 'package:poligonic/screen/partial/poligon_maker.dart';
import 'package:poligonic/screen/poligon_builder.dart';
import 'package:poligonic/screen/poligon_struct_builder.dart';

class MainMenu extends BaseGame with GestureWrapper{
  final Router _router;
  final Size screen;
  final ProportionFactory _proportionFac;

  final _tapColisions = ColisionWrapper();
  final _dragColisions = ColisionWrapper();

  Poligon ship;
  PlayerMap playerMap;

  MainMenu(this._router) :
  this.screen = _router.screen,
  this._proportionFac = ProportionFactory(_router.screen)
  {
    // background
    add(RectProportional.fromLTRB(screen, 0, 0, 1, 1, Colors.lightBlue[100]));

    var menu = Listbox(_proportionFac.getRectLTRB(0, 0.85, 1, 1));
    menu.add(0.055, 1);
    // to battle
    menu.add(0.14, 1, (rect) {
      _addSvgWithTapColision('svg/pvp2.svg', rect, (action) {
        var options = RouterWrapper();
        options.apply = (r) => r.backTo(this);
        options.cancel = (r) => r.backTo(this);
        _router.toBattleMap(options, playerMap, ship.copy());
      });
    });

    menu.add(0.11, 1);
    // to skills
    menu.add(0.14, 1, (rect) {
      _addSvgWithTapColision('svg/skill (1).svg', rect, (action) {
          // TODO: skills
        });
    });

    menu.add(0.11, 1);
    // to base builder
    menu.add(0.14, 1, (rect) {
      _addSvgWithTapColision('svg/tank.svg', rect, (action) {
        var options = RouterWrapper();
        options.cancel = (r) => r.backTo(this);
        options.apply = (r) {
          assert(ComponentCache.selected != null);
          playerMap = ComponentCache.selected;
          playerMap.setArea(Rect.fromLTWH(-screen.width * 3 / 2 + screen.width, -screen.height * 4 / 2 + screen.height, screen.width * 3, screen.height * 4));
          r.backTo(this);
        };
        _router.toPlayerMapBuilder(options);
      });
    });

    menu.add(0.11, 1);
    // to ship builder
    menu.add(0.14, 1, (rect) {
      _addSvgWithTapColision('svg/startup.svg', rect, (action){
        // TODO: mudar para uma lista com os avioes para selecionar
        var options = RouterWrapper();
        options.cancel = (r) => r.backTo(this);
        options.apply = (r) {
          assert(ComponentCache.selected != null);
          ship = ComponentCache.selected;
          ship.setArea(_proportionFac.getRectLTRB(0.25, 0.25, 0.75, 0.75));
          r.backTo(this);
        };
        _router.toPoligonBuilder(options, "ship");
      });
    });
    menu.add(0.055, 1);

    var verticalMenu = Listbox(_proportionFac.getRectLTRB(0, 0.361, 0.14, 0.65));
    verticalMenu.add(1, 0.45, (rect) {
      _addSvgWithTapColision('svg/medical-history.svg', rect, (action) {
        // TODO: historico de acordo com as batalhas
      });
    });
    verticalMenu.add(1, 0.45, (rect) {
      _addSvgWithTapColision('svg/chat.svg', rect, (action) {
        // TODO: tela flutuante + conexao chat
      });
    });
    
    // Top bar
    // 13 de altura e 23 de largura max
    // 13 de altura e 13 de largura max
    _addSvgWithTapColision('svg/user.svg', 
      _proportionFac.getRectLTWH(0.06, 0.009, 0.13, 0.13), 
      (action) {

      });
    add(RectProportional.fromLTRB(screen, 0.26, 0.001, 0.36, 0.131, Colors.yellow));
    add(RectProportional.fromLTRB(screen, 0.37, 0.001, 0.74, 0.131, Colors.yellow));
    _addSvgWithTapColision('svg/store.svg', 
      _proportionFac.getRectLTWH(0.80, 0.009, 0.13, 0.13), 
      (action){

      });

    // options
    _addSvgWithTapColision('svg/settings.svg', 
      _proportionFac.getRectLTWH(0.01, 0.14, 0.13, 0.13), 
      (action) {

      });
  }
 
  _addSvg(String name, Rect rect) {
    var svg = SvgComponent.fromSvg(rect.width, rect.height, Svg(name))
      ..x = rect.left
      ..y = rect.top;
    add(svg);
  }

  _addSvgWithTapColision(String name, Rect rect, f(Offset action)) {
    _addSvg(name, rect);
    _tapColisions.addColision(rect, f);
  }

  _addSvgWithDragColision(String name, Rect rect, f(Offset action)) {
    _addSvg(name, rect);
    _dragColisions.addColision(rect, f);
  }

  @override
  void render(Canvas c) {
    super.render(c);
    ship?.render(c);
    playerMap?.render(c);
  }

  // Sistema de movimento aleatorio da nave no menu
  static final Random _random = Random();
  static int _nextRandom() => 1 + _random.nextInt(10 - 1);
  var r1 = _nextRandom();
  var r2 = _nextRandom();
  var r3 = _nextRandom();
  var r4 = _nextRandom();

  bool troca = true, troca2 = true;

  @override
  void update(double t) {
    super.update(t);
    if(ship != null) {
      ship.update(t);

      if(ship.x < size.shortestSide / 8 || ship.y < size.longestSide / 8) {
        troca = true;
        r1 = _nextRandom();
        r2 = _nextRandom();
        r3 = _nextRandom();
        r4 = _nextRandom();
      }

      if(ship.x > size.shortestSide - size.shortestSide / 2 || ship.y > size.longestSide - size.longestSide / 2) {
        troca = false;
      }

      if(troca) 
        ship.setPosition(ship.x + r1 / 10, ship.y + r3 / 10);
      else 
        ship.setPosition(ship.x - r2 / 10, ship.y - r4 / 10);
    }

    if(playerMap != null) {
      if(troca2) 
        playerMap.setPosition(playerMap.x + r1 / 10, playerMap.y + r3 / 10);
      else 
        playerMap.setPosition(playerMap.x - r2 / 8, playerMap.y - r4 / 8);

      if(playerMap.x > playerMap.width || playerMap.y > playerMap.height || playerMap.x < -playerMap.width || playerMap.y < -playerMap.height) {
        troca2 = troca2 ? false : true;
        r1 = _nextRandom();
        r2 = _nextRandom();
        r3 = _nextRandom();
        r4 = _nextRandom();
      }
    }
  }

  // ==============
  // === INPUTS ===
  // ==============

  @override
  void tapDown(Offset action) {
    _tapColisions.makeColision(action);
  }

  @override
  void panUpdate(Offset action) {
    _dragColisions.makeColision(action);
  }
}