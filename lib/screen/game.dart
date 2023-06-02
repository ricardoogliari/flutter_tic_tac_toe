import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertictactoe/model/message.dart';
import 'package:fluttertictactoe/util/constants.dart';

class WrapperCreator {
  final bool creator;
  final String nameGame;
  WrapperCreator(this.creator, this.nameGame);
}

class Game extends StatefulWidget {
  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {

  static const platform = const MethodChannel('game/exchange');

  late bool minhaVez;
  late WrapperCreator creator;

  // 0 = branco. 1 = eu. 2 - adversário
  List<List<int>> cells = [
    [0, 0, 0],
    [0, 0, 0],
    [0, 0, 0]
  ];

  TextStyle textStyle75 = TextStyle(
      fontSize: 75,
      color: Colors.white
  );

  TextStyle textStyle36 = TextStyle(
      fontSize: 36,
      color: Colors.white
  );

  @override
  void initState() {
    super.initState();
    configurePubNub();
  }

  void configurePubNub(){
    platform.setMethodCallHandler((call) {
      String action = call.method;
      String argumentos = call.arguments.toString();
      List<String> parts = argumentos.split("|");

      if (action == "sendAction") {
        ExchangeMessage message = ExchangeMessage(
            parts[0], int.parse(parts[1]), int.parse(parts[2]));

        if (message.user == (creator.creator ? 'p2' : 'p1')) {
          setState(() {
            minhaVez = true;
            cells[message.x][message.y] = 2;
          });
          checkWinner();
        }
      } else {
        if (parts[0] == (creator.creator ? 'p2' : 'p1')) {
          _showChat(parts[1]);
        }
      }

      return Future.value(true);
    });
  }

  Widget buildButton(String label, bool owner) => Container(
    width: ScreenUtil().setWidth(300),
    child: ElevatedButton(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
            label,
            style: textStyle36
        ),
      ),
      onPressed: (){
        createGame(owner);
      },
    ),
  );

  checkWinner(){
    bool youWin = false;
    bool enemyWin = false;

    if (cells[0][0] == cells[0][1] && cells[0][1] == cells[0][2]){
      if (cells[0][0] == 1){
        youWin = true;
      } else if (cells[0][0] == 2){
        enemyWin = true;
      }
    } else if (cells[1][0] == cells[1][1] && cells[1][1] == cells[1][2]){

    } else if (cells[2][0] == cells[2][1] && cells[2][1] == cells[2][2]){

    } else if (cells[0][0] == cells[1][0] && cells[1][0] == cells[2][0]){

    } else if (cells[0][1] == cells[1][1] && cells[1][1] == cells[2][1]){

    } else if (cells[0][2] == cells[1][2] && cells[1][2] == cells[2][2]){

    } else if (cells[0][0] == cells[1][1] && cells[1][1] == cells[2][2]){

    } else if (cells[0][2] == cells[1][1] && cells[1][1] == cells[2][0]){

    }

    if (youWin){  _showFinishGame(true); }
    else if (enemyWin){  _showFinishGame(false);  }
  }

  Future<void> _showFinishGame(bool youWin) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Fim do jogo!!!'),
          content: Text(youWin ? "Você Ganhou!!!" : "Seu Adversário ganhou!!!"),
          actions: <Widget>[
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(700, 1400),
      builder: (BuildContext context, Widget? child) {
          return Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: ScreenUtil().setWidth(550),
                        height: ScreenUtil().setHeight(550),
                        color: colorBackBlue1,
                      ),
                      Container(
                        width: ScreenUtil().setWidth(150),
                        height: ScreenUtil().setHeight(550),
                        color: colorBackBlue2,
                      )
                    ],
                  ),
                  Container(
                    width: ScreenUtil().setWidth(700),
                    height: ScreenUtil().setHeight(850),
                    color: colorBackBlue3,
                  )
                ],
              ),
              Container(
                height: ScreenUtil().setHeight(1400),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //o creator indica que o jogo começou ou não
                      //se o jogo não começou, creator vai estar nulo e
                      //mostramos os dois botões, caso contrário, o
                      //label de direcionamento da jogada
                      creator == null ? Row(
                        children: [
                          buildButton("Criar", true),
                          SizedBox(width: 10),
                          buildButton("Entrar", false)
                        ],
                        mainAxisSize: MainAxisSize.min,
                      ) : InkWell(
                        child: Text(
                            minhaVez ? "Sua Vez!!" : "Aguarde Sua Vez!!!",
                            style: textStyle36
                        ),
                        onLongPress: (){
                          _sendMessage();
                        },
                      ),
                      GridView.count(
                        shrinkWrap: true,
                        padding: EdgeInsets.all(20),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        crossAxisCount: 3,
                        children: <Widget>[
                          getCell(0, 0),
                          getCell(0, 1),
                          getCell(0, 2),
                          getCell(1, 0),
                          getCell(1, 1),
                          getCell(1, 2),
                          getCell(2, 0),
                          getCell(2, 1),
                          getCell(2, 2),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
      },
    );
  }

  Future<void> createGame(bool isCreator) async {
    TextEditingController editingController = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Qual o nome do jogo?'),
          content: TextField(
            controller: editingController,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Jogar'),
              onPressed: () {
                Navigator.of(context).pop();
                _sendAction('subscribe', {'channel': editingController.text}).then((value) {
                  setState(() {
                    creator = WrapperCreator(isCreator, editingController.text);
                    minhaVez = isCreator;
                  });
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _sendAction(String action, Map<String, dynamic> arguments) async {
    try {
      //nessa linha que, efetivamente, ocorre o envio do comando
      // via PlatformChannel
      final bool result = await platform.invokeMethod(action, arguments);
      if (result){
        return true;
      }

      return false;
    } on PlatformException catch (e) {
      return false;
    }
  }

  Widget getCell(int x, int y) =>
      InkWell(
        child: Container(
          padding: EdgeInsets.all(8),
          child: Center(
              child: Text(
                  cells[x][y] == 0 ? " " : cells[x][y] == 1 ? "X" : "O",
                  style: textStyle75
              )
          ),
          color: Colors.lightBlueAccent,
        ),
        onTap: () async {
          if (minhaVez && cells[x][y] == 0) {
            _showSendingAcion();
            _sendAction('sendAction', {'tap': '${creator.creator ? 'p1' : 'p2'}|$x|$y'}).then((value) {
              Navigator.of(context).pop();
              minhaVez = false;
              cells[x][y] = 1;

              setState(() {});

              checkWinner();
            });
          }
        },
      );

  Future<void> _showSendingAcion() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enviando ação, aguarde...'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator()
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendMessage() async {
    TextEditingController editingController = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Digite a mensagem abaixo:'),
          content: TextField(
            controller: editingController,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Enviar'),
              onPressed: () {
                Navigator.of(context).pop();
                _sendAction(
                  'chat',
                  {'message': '${creator.creator ? 'p1' : 'p2'}|${editingController.text}'}
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showChat(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Você recebeu uma nova mensagem:'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}
