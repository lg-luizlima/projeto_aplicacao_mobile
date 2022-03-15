import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_ibm_watson/flutter_ibm_watson.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Texto&Falado',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const MyHomePage(title: 'Texto&Falado'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AudioPlayer audioPlayer = new AudioPlayer();
  String textAsSpeech = "";
  String apiKey = "";
  String ibmURL = "";

  void textToSpeech(String text) async {
    IamOptions options =
        await IamOptions(iamApiKey: apiKey, url: ibmURL).build();
    TextToSpeech service = new TextToSpeech(iamOptions: options);
    service.setVoice("pt-BR_IsabelaV3Voice");
    Uint8List voice = await service.toSpeech(text);

    audioPlayer.playBytes(voice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
              padding: const EdgeInsets.all(0.0),
              child: TextField(
                  decoration: InputDecoration(hintText: 'Digite o texto'),
                  onChanged: (value) {
                    setState(() {
                      textAsSpeech = value;
                    });
                  }),
            ),
            ElevatedButton(
              onPressed: () {
                textToSpeech(textAsSpeech);
              },
              child: Text("Falar"),
              style: ElevatedButton.styleFrom(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0),
                  ),
                  fixedSize: const Size.fromWidth(double.maxFinite)),
            ),
            Container(
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child:

                    // Replace this code with examples from the article.
                    Wrap(
                  spacing: 10,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        textToSpeech('Bom dia');
                      },
                      child: Text("Bom dia"),
                      style: ElevatedButton.styleFrom(primary: Colors.grey),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        textToSpeech('Boa tarde');
                      },
                      child: Text("Boa tarde"),
                      style: ElevatedButton.styleFrom(primary: Colors.grey),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        textToSpeech('Boa noite');
                      },
                      child: Text("Boa noite"),
                      style: ElevatedButton.styleFrom(primary: Colors.grey),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        textToSpeech('Por favor');
                      },
                      child: Text("Por favor"),
                      style: ElevatedButton.styleFrom(primary: Colors.grey),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        textToSpeech('Com Licença');
                      },
                      child: Text("Com Licença"),
                      style: ElevatedButton.styleFrom(primary: Colors.grey),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        textToSpeech('Me desculpe');
                      },
                      child: Text("Me desculpe"),
                      style: ElevatedButton.styleFrom(primary: Colors.grey),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        textToSpeech('Obrigado');
                      },
                      child: Text("Obrigado"),
                      style: ElevatedButton.styleFrom(primary: Colors.grey),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        textToSpeech('Não tem de quê');
                      },
                      child: Text("Não tem de quê"),
                      style: ElevatedButton.styleFrom(primary: Colors.grey),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        textToSpeech('Disponha');
                      },
                      child: Text("Disponha"),
                      style: ElevatedButton.styleFrom(primary: Colors.grey),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        textToSpeech('Eu que agradeço');
                      },
                      child: Text("Eu que agradeço"),
                      style: ElevatedButton.styleFrom(primary: Colors.grey),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        textToSpeech('Foi um prazer');
                      },
                      child: Text("Foi um prazer"),
                      style: ElevatedButton.styleFrom(primary: Colors.grey),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        textToSpeech('Não seja por isso');
                      },
                      child: Text("Não seja por isso"),
                      style: ElevatedButton.styleFrom(primary: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
