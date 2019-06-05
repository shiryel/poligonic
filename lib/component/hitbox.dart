import 'package:poligonic/core/colision_detector.dart';

class Hitbox{
  final ColisionDetector colisionDetector;
  int life;
  final bool godmode;

  Hitbox(this.colisionDetector, {this.life = 1, this.godmode = false});

  /// Retorna true se o objeto morrer
  bool doDamageInColision(double x, double y, int damage) {
    if(colisionDetector.anyColision(x, y))
      life -= damage;
    if(life < 1)
      return true;
      
    return false;
  }
}