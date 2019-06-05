/// Um super contrutor de componentes, delegando todas funcionalidades para seu pai
/// Este componente tem como objetivo ser uma abstraçao funcional, que permita que um dado original
/// seja usado como base para construir todo uma cadeida de componentes, estas que por sua vez podem
/// ser chamadas de acordo com as funçoes
abstract class ExtendComponent {
  bool destroied = false;
  bool hud = false;
  bool load = true;
  int dz = 0;

  @override
  bool destroy() => destroied;

  @override
  int priority() => dz;

  @override
  bool isHud() => hud;

  @override
  bool loaded() => load;
}