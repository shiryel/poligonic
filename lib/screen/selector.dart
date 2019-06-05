import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:poligonic/core/router_wrapper.dart';

import '../main.dart';

/// Aqui é selecionado atravez do [Cache] um objeto para operaçoes padrao CRUD
/// Para tal é utilizado com o RouterWrapper, para fornecer as funçoes bases para que o selector seja abstraido atravez do contrutor root (como o [MasterPoligonMaker])
/// Esta funçao já realiza o runApp
void runSelector(Router router, String roleName, RouterWrapper options) 
{
  runApp(new _Selector(router, roleName, options));
}

class _Selector extends StatelessWidget 
{
  final Router router;
  final String roleName;
  final RouterWrapper options;
  _Selector(this.router, this.roleName, this.options);

  @override
  Widget build(BuildContext context) 
  {
    return new MaterialApp
    (
      title: 'Listas',
      home: new _SelectorWidget(router, roleName, options),
      theme: new ThemeData(primaryColor: Colors.black),
    );
  }
}

class _SelectorWidget extends StatefulWidget 
{
  final Router router;
  final String roleName;
  final RouterWrapper options;
  _SelectorWidget(this.router, this.roleName, this.options);

  @override
  State<_SelectorWidget> createState() => new _SelectorWidgetState(router, roleName, options);
}

class _SelectorWidgetState extends State<_SelectorWidget> with TickerProviderStateMixin 
{
  final Router router;
  final String roleName;
  final RouterWrapper options;
  _SelectorWidgetState(this.router, this.roleName, this.options);

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      body: Center
      (
        child: Column
        (
          children: <Widget>
          [
            Expanded
            (
              flex: 9,
              child: GridView.builder //Grid View 
              (
                itemCount: 20, //Número de Itens
                gridDelegate:
                    new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3), //Colunas
                itemBuilder: (BuildContext context, int index) 
                {
                  
                  return new GestureDetector
                  (
                    child: new Card //São os itens, estou usando card pq é bunitu
                    (
                      elevation: 5.0,
                      child: new Container //Aqui dentro vai o conteúdo
                      (
                        alignment: Alignment.center,
                        child: new Text('Item $index'),
                      ),
                    ),

                    onTap: () //Quando pressionado rapidamente,
                    {	      //ainda não feita pq precisa do tratamento de selecionado ou não
                      
                    },

                    onLongPress: ()//Quando o pressionado por mais tempo
                    {
                      showDialog //Abre uma um pop-up no centro da tela
                      (
                        barrierDismissible: false,
                        context: context,
                        child: new CupertinoAlertDialog
                        (
                          title: new Column
                          (
                            children: <Widget>
                            [
                              new Text("Item $index"),
                              new Icon
                              (
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ],
                          ),
                          content: new Text("Deseja mesmo DELETAR ?"),
                          actions: <Widget>
                          [
                            new FlatButton
                            (
                                onPressed: () //Coloque aqui dentro a função para deletar o item
                                {
                                  Navigator.of(context).pop(); //Aqui ele apenas retorna para a tela de seleção
                                },
                                child: new Text("Sim"))
                          ],
                        ),
                      );
                    },
                  );
                }
              )
            ),
            

            Expanded
            (
              flex: 1,
              child: ButtonBar //Botões
              (
                mainAxisSize: MainAxisSize.min,
                children: <Widget>
                [
                  RaisedButton
                  (
                    child: Text('Editar'),
                    onPressed: () => options.edit(router),
                  ),

                  RaisedButton
                  (
                    child: Text('Select'),
                    onPressed: () => options.apply(router),
                  )

                ],
              )
            )

          ],
        ) 
      )
    );
  }
}