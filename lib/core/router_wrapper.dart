import 'dart:ui';

import 'package:poligonic/core/colision_detector.dart';
import 'package:tuple/tuple.dart';

import '../main.dart';

/// Principalmente utilizado com o [Selector]
/// Use ele em conjunto com o [Cache] para conseguir uma abstraçao de seletor sem ter que re-implementado, e sim utilizando apenas as funçoes dispostas aqui. Para tal o [Cache] contem uma funçao que permite selecionar um de seus objetos e deixar disponivel para consulta para o resto da aplicaçao. Para evitar mau uso é recomendavel que quando um selector inicie atravez da funçao [start] seja setado o selected do [Cache] para null (assim como quando voltar da tela de construçao root como [MasterPoligonMaker])
class RouterWrapper {
  Function(Router router) start = (_) => {};
  Function(Router router) cancel = (_) => {};
  Function(Router router) apply = (_) => {};
  Function(Router router) newItem = (_) => {};
  Function(Router router) edit = (_) => {};
}