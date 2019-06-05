import 'package:flame/game.dart';
import 'package:flame/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flame/flame.dart';
import 'package:flutter/services.dart';
import 'package:poligonic/component/player_map.dart';
import 'package:poligonic/component/poligon.dart';
import 'package:poligonic/core/router_wrapper.dart';
import 'package:poligonic/factory/text_factory.dart';
import 'package:poligonic/screen/battle_map.dart';
import 'package:poligonic/screen/main_menu.dart';
import 'package:poligonic/screen/master_poligon_builder.dart';
import 'package:poligonic/screen/partial/color_picker.dart';
import 'package:poligonic/screen/player_map_builder.dart';
import 'package:poligonic/screen/poligon_struct_builder.dart';
import 'dart:ui';
import 'screen/poligon_builder.dart';
import 'screen/selector.dart' as selector;

void main() async {
  Flame.audio.disableLog();

  Util flameUtil = Util();
  await flameUtil.fullScreen();
  await flameUtil.setOrientation(DeviceOrientation.portraitUp);
  
  var screen = await flameUtil.initialDimensions();
  var router = Router(screen, Language.pt_br);
  router.toMainMenu();

  var tapper = TapGestureRecognizer();
  tapper.onTapDown = (evt) => router.game.tapDown(evt.globalPosition);
  tapper.onTapUp = (evt) => router.game.tapUp(evt.globalPosition);
  tapper.onTapCancel = () => router.game.tapCancel();

  var dragger = PanGestureRecognizer();
  dragger.onUpdate = (evt) => router.game.panUpdate(evt.globalPosition);

  var longPressRec = LongPressGestureRecognizer();
  // FIXME: verificar se o bug de n encontrar o globalposition é local ou do flutter
  longPressRec.onLongPressStart = (evt) => router.game.longPressStart(evt.globalPosition);
  longPressRec.onLongPressEnd = (evt) => router.game.longPressEnd(evt.globalPosition);

  runScreen(router);

  flameUtil.addGestureRecognizer(tapper);
  flameUtil.addGestureRecognizer(dragger);
  flameUtil.addGestureRecognizer(longPressRec);
/*
  Flame.util.addGestureRecognizer(PanGestureRecognizer()
    ..onUpdate = (offset) {
      router.game.dragInput(offset.globalPosition);
    });

  Flame.util.addGestureRecognizer(TapGestureRecognizer()
    ..onTapDown = (evt) {
      router.game.tapInput(evt.globalPosition);
    });
    */
}

void runScreen(Router router) async {
  runApp(MaterialApp(
    home:Scaffold(
      body:Container(
        child: router.game.widget,
      )
    )
  ));
}

void runWidget(Router router, Widget widget) async {
  runApp(MaterialApp(
    home:Scaffold(
      body:Container(
        child: widget,
      )
    )
  ));
}

class Router {
  final Size screen;
  final Language language;
  BaseGame _game;

  Router(this.screen, this.language);

  get game => _game;

  backTo(BaseGame screen) {
    _game = screen;
    runScreen(this);
  }

  toMainMenu() {
    _game = MainMenu(this);
    runScreen(this);
  }

  toPoligonStructBuilder(PoligonBuilder builder, RouterWrapper options, [f(PoligonStructBuilder p)]) {
    _game = PoligonStructBuilder(this, builder, options);
    if(f != null) 
      f(_game);
    runScreen(this);
  }
  
  toPoligonBuilder(RouterWrapper options, String role) {
    _game = PoligonBuilder(this, options, role);
    runScreen(this);
  } 
  
  toMasterPoligonBuilder(String roleName, RouterWrapper options) {
    _game = MasterPoligonBuilder(this, roleName, options);
    runScreen(this);
  } 

  toPoligonBuilderColorPicker(PoligonBuilder p) {
    runWidget(this, PoligonBuilderColorPicker(this, p));
  }

  toSelector(String roleName, RouterWrapper options) {
    selector.runSelector(this, roleName, options);
  }

  toPlayerMapBuilder(RouterWrapper options) {
    _game = PlayerMapBuilder(this, screen, options);
    runScreen(this);
  }

  toBattleMap(RouterWrapper options, PlayerMap map, Poligon ship) {
    _game = BattleMap(this, screen, map, ship, options);
    runScreen(this);
  }

}