import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

const request = "https://api.hgbrasil.com/finance?key=86d6a323";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late double dolar;
  late double euro;
  late double libra;

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final libraController = TextEditingController();

  void _realChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    print("Real = $text");
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
    libraController.text = (real/libra).toStringAsFixed(2);
  }

  void _libraChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double libra = double.parse(text);
    realController.text = (libra * this.libra).toStringAsFixed(2);
    euroController.text = (libra * this.libra / euro).toStringAsFixed(2);
    dolarController.text = (libra * this.libra / dolar).toStringAsFixed(2);
  }

  void _dolarChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
    libraController.text = (dolar * this.dolar / libra).toStringAsFixed(2);
  }
  void _euroChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
    libraController.text = (euro * this.euro / libra).toStringAsFixed(2);
  }

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
    libraController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "\$Conversor\$",
        ),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                  child: Text(
                "Carregando dados...",
                style: TextStyle(color: Colors.amber, fontSize: 25.0),
                textAlign: TextAlign.center,
              ));
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Erro ao carregar dados",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                libra = snapshot.data!["results"]["currencies"]["GBP"]["buy"];
                print("Valor dolar: $dolar");
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150.0,
                        color: Colors.amber,
                      ),
                      buildTextField("Real", "R\$",realController, _realChanged),
                      Divider(),
                      buildTextField("Dólar", "US\$",dolarController,_dolarChanged),
                      Divider(),
                      buildTextField("Euro", "€",euroController,_euroChanged),
                      Divider(),
                      buildTextField("Libra", "£",libraController,_libraChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController c, Function f) {
  return TextField(
    controller: c,
    onChanged: (value){
      f(value);
    },
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      labelText: label,
      prefixText: prefix,
      labelStyle: TextStyle(
        color: Colors.amber,
      ),
      border: OutlineInputBorder(),
    ),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}
