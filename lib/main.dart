import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    home: ClimaApp(),
  ));
}

class ClimaApp extends StatefulWidget {
  @override
  _ClimaAppState createState() => _ClimaAppState();
}

class _ClimaAppState extends State<ClimaApp> {
  String apiKey = '0e67b33ca85072cac666b59fede86903';
  String cityName = '';
  String temperature = '0';
  String weatherIcon = '';
  Color backgroundColor = Colors.white; // Cor de fundo padrão

  Color getColorForWeatherIcon(String iconCode) {
    if (iconCode.startsWith('01') || iconCode.startsWith('02')) {
      return  Color.fromARGB(255, 243, 232, 134); // Ensolarado ou nublado
    } else if (iconCode.startsWith('03') || iconCode.startsWith('04')) {
      return  Color.fromARGB(255, 131, 130, 130); // Nublado
    } else if (iconCode.startsWith('09') ||
        iconCode.startsWith('10') ||
        iconCode.startsWith('11')) {
      return  Color.fromARGB(204, 96, 165, 223); // Chuvoso
    } else {
      return Colors.white; // Padrão
    }
  }

  void fetchWeatherData() async {
    String apiUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric';
    
    try {
      var response = await http.get(Uri.parse(apiUrl));
      
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          temperature = data['main']['temp'].toString();
          weatherIcon = data['weather'][0]['icon'];

          backgroundColor = getColorForWeatherIcon(weatherIcon);
        });
      }
    } catch (e) {
      print('Erro na requisição: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Climatempo'),
        ),
        backgroundColor: backgroundColor, // Definir a cor de fundo
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Clima em $cityName:',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              Text(
                '$temperature°C',
                style: TextStyle(fontSize: 50),
              ),
              SizedBox(height: 20),
              weatherIcon.isNotEmpty
                  ? Image.network(
                      'http://openweathermap.org/img/w/$weatherIcon.png')
                  : SizedBox(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Abre um diálogo para inserção da cidade
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Digite o nome da cidade'),
                        content: TextField(
                          onChanged: (value) {
                            cityName = value;
                          },
                        ),
                        actions: <Widget>[
                          ElevatedButton(
                            onPressed: () {
                              fetchWeatherData();
                              Navigator.pop(context);
                            },
                            child: Text('Buscar'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text('Mudar cidade'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
