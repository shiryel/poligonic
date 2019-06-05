class RingSelector<T> {
  var _list = List<T>();
  var _iterator;

  RingSelector();

  List<T> get list => _list;

  T get selected {
    if(_list.length > 0 && _iterator == null)
      _iterator = 0;

    if(_iterator != null)
      return _list[_iterator];
    else
      return null;
  }

  set selected(T t) {
    if(_list.length > 0 && _iterator == null)
      _iterator = 0;

    if(_iterator != null)
      _list[_iterator] = t;
  }

  int get length => _list.length;

  void add(T t) {
    _list.add(t);
    if(_iterator == null)
      _iterator = 0;
  } 

  void removeSelected() {
    if(_iterator != null)
      _list.removeAt(_iterator);
    moveIterator(-1);
  }

  void moveIterator(int x) {
    // validadores padroes
    if(_list.length == 0) {
      _iterator = null;
      return;
    };
    if(_iterator == null) _iterator = 0;

    // permite que o x se ajuste ao range padrao
    if(x >= _list.length) return moveIterator(x - _list.length);
    if(x.abs() >= _list.length) return moveIterator(x + _list.length);
    // caso necessite dar a voltar por traz
    if(_iterator + x < 0) {
      if(x < 0)
        _iterator = _list.length + x;
      else
        _iterator = _list.length - 1;
      return;
    }
    // caso necessite dar a volta pela frente
    if(_iterator + x >= _list.length) {
      if(x > 0)
        _iterator = x - 1;
      else
        _iterator = 0;
      return;
    }

    // caso x ainda dentro do range padrao
    _iterator += x;
  }

  void moveIteratorToLast() {
    if(_list.length == 0) {
      _iterator = null;
      return;
    }

    _iterator = _list.length - 1;
  }

  void moveIteratorToFirst() {
    if(_list.length == 0) {
      _iterator = null;
      return;
    }

    _iterator = 0;
  }

  void moveSelected(int x) {
    T current = selected;
    moveIterator(x);
    T target = selected;
    List<T> newOrder = List<T>();

    for (var item in _list) {
      if(item == current) {
        newOrder.add(target);
        continue;
      }
      if(item == target) {
        newOrder.add(current);
        continue;
      }
      newOrder.add(item);
    }

    assert(newOrder.length == _list.length);
    _list = newOrder;
  }
}