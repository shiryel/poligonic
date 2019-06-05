import 'package:flutter/widgets.dart';

class Listbox {
  Rect position;
  Listbox(this.position);

  var _components = List<Rect>();

  void add(double width, double heigth, [f(Rect rect)]) {
    var lastLeft = position.left;
    var lastTop = position.top;
    if(_components.length > 0) {
      lastLeft = _components.last.right;
      lastTop = _components.last.top;

      if(lastLeft + position.width * width > position.right) {
        lastLeft = position.left;
        lastTop = _components.last.bottom;
      }

      assert(lastTop + position.height * heigth <= position.bottom + 0.0001);
      assert(lastLeft + position.width * width <= position.right + 0.0001);
    }
    
    var compRect = Rect.fromLTWH(
      lastLeft, 
      lastTop, 
      position.width * width,
      position.height * heigth);

    _components.add(compRect);
    if(f != null)
      f(compRect);
  } 
}