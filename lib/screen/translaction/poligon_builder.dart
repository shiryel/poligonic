import 'package:poligonic/factory/text_factory.dart';
import 'package:tuple/tuple.dart';

// FIXME: Atualmente nao mais necessario
/// Text: (1: text, 2: textProportion, 3: widthProportion, 4: heightProportion, 
/// 5: fontFamily)
class TextTranslactions {
  final Language language;
  final String fontFamily;
  TextTranslactions(this.language, [this.fontFamily = 'Arial']);

  get voltar {
    switch (language) {
      case Language.pt_br:
        return Tuple5("voltar", .5, .1, .2, fontFamily);
      case Language.en:
        return Tuple5("back", .5, .1, .2, fontFamily);
      default:
        return voltar(Language.en);
    }
  } 

  get cor {
    switch (language) {
      case Language.pt_br:
        return Tuple5("cor", .5, .3, .2, fontFamily);
      case Language.en:
        return Tuple5("color", .5, .3, .2, fontFamily);
      default:
        return cor(Language.en);
    }
  }

  get create {
    switch (language) {
      case Language.pt_br:
        return Tuple5("criar", .5, .2, .2, fontFamily);
      case Language.en:
        return Tuple5("create", .5, .2, .2, fontFamily);
      default:
        return create(Language.en);
    }
  }

  get modify{
    switch (language) {
      case Language.pt_br:
        return Tuple5("modificar", .35, .14, .25, fontFamily);
      case Language.en:
        return Tuple5("modify", .4, .2, .2, fontFamily);
      default:
        return modify(Language.en);
    }
  }

  get up{
    switch (language) {
      case Language.pt_br:
        return Tuple5("acima", .5, .2, .2, fontFamily);
      case Language.en:
        return Tuple5("up", .5, .2, .2, fontFamily);
      default:
        return up(Language.en);
    }
  }

get down{
    switch (language) {
      case Language.pt_br:
        return Tuple5("baixo", .5, .2, .2, fontFamily);
      case Language.en:
        return Tuple5("down", .5, .2, .2, fontFamily);
      default:
        return down(Language.en);
    }
  }

  get poligono {
    switch (language) {
      case Language.pt_br:
        return Tuple5("poligono", .5, .05, .2, fontFamily);
      case Language.en:
        return Tuple5("poligon", .5, .05, .2, fontFamily);
      default:
        return poligono(Language.en);
    }
  }
  
  get delete{
    switch (language) {
      case Language.pt_br:
        return Tuple5("deletar", .5, .05, .2, fontFamily);
      case Language.en:
        return Tuple5("delete", .5, .05, .2, fontFamily);
      default:
        return delete(Language.en);
    }
  }
}