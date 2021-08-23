import 'package:flutter/material.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=a3789379";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
        hintStyle: TextStyle(color: Colors.amber),
      )),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({ Key? key }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double _dolar = 0;
  double _euro = 0;

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double real = double.parse(text);
    dolarController.text = (real/_dolar).toStringAsFixed(2);
    euroController.text = (real/_euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double dolar = double.parse(text);

    realController.text = (dolar * _dolar).toStringAsFixed(2);
    euroController.text = (dolar * _dolar / _euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double euro = double.parse(text);

    realController.text = (euro * _euro).toStringAsFixed(2);
    dolarController.text = (euro * _euro / _dolar).toStringAsFixed(2);
  }

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: Text("\$ Conversor \$"),
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return buildCenterChild("Carregando dados...");
            default:
              if(snapshot.hasError || ! snapshot.hasData) {
                return buildCenterChild("Erro ao carregar dados.");
              }
              
              _dolar = snapshot.data?["results"]["currencies"]["USD"]["sell"];
              _euro = snapshot.data?["results"]["currencies"]["EUR"]["sell"];

              return SingleChildScrollView(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Icon(Icons.monetization_on, size: 150, color: Colors.amber),
                    buildTextField("Reais", "R\$", realController, _realChanged),
                    Divider(),
                    buildTextField("Dólares", "US\$", dolarController, _dolarChanged),
                    Divider(),
                    buildTextField("Euros", "€", euroController, _euroChanged),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController controller, void Function(String) changed) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(
      color: Colors.amber,
      fontSize: 25,
    ),
    onChanged: changed,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}

Widget buildCenterChild(String message) {
  return Center(
    child: Text(
      message,
      style: TextStyle(color: Colors.amber, fontSize: 25),
      textAlign: TextAlign.center,
    ),
  );
}