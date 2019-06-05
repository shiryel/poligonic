import "package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart";
import 'package:flutter/material.dart';
import 'package:poligonic/main.dart';
import 'package:poligonic/screen/poligon_builder.dart';
import 'dart:ui';

class PoligonBuilderColorPicker extends StatelessWidget{
  final Router _router;
  final PoligonBuilder poligon;

  PoligonBuilderColorPicker(this._router, this.poligon);

  @override
  Widget build(BuildContext context) {
    return new ColorPicker(
      color: Colors.blue, 
      onChanged: (value) {
        poligon.poligonMaker.selected.paint = Paint()..color = value;
        _router.backTo(poligon); //FIXME: colocar esta funcao no widget raiz
        }
    );
  }

}