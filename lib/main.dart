import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_ibm_watson/flutter_ibm_watson.dart';
import 'sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Texto Falado',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const MyHomePage(title: 'Texto Falado'),
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
  static dynamic jsonMap;

  Future<void> loadAsset(BuildContext context) async {
    final jsonString = await DefaultAssetBundle.of(context)
        .loadString('assets/.config.json');
         jsonMap = jsonDecode(jsonString);
  }

  AudioPlayer audioPlayer = AudioPlayer();
  String textAsSpeech = "";
  String apiKey = jsonMap['apiKey'];
  String ibmURL = jsonMap['ibmURL'];


  void textToSpeech(String text) async {
    IamOptions options =
    await IamOptions(iamApiKey: apiKey, url: ibmURL).build();
    TextToSpeech service = TextToSpeech(iamOptions: options);
    service.setVoice("pt-BR_IsabelaV3Voice");
    Uint8List voice = await service.toSpeech(text);

    audioPlayer.playBytes(voice);
  }

  // All journals
  List<Map<String, dynamic>> _journals = [];

  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals(); // Loading the diary when the app starts
  }

  final TextEditingController _titleController = TextEditingController();

// Insert a new journal to the database
  Future<void> _addItem() async {
    await SQLHelper.createItem(_titleController.text);
    _refreshJournals();
  }

  // Update an existing journal
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(id, _titleController.text);
    _refreshJournals();
  }

  // Delete an item
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a journal!'),
    ));
    _refreshJournals();
  }

  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                // this will prevent the soft keyboard from covering the text fields
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'Texto'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Save new journal
                      if (id == null) {
                        await _addItem();
                      }

                      if (id != null) {
                        await _updateItem(id);
                      }

                      // Clear the text fields
                      _titleController.text = '';

                      // Close the bottom sheet
                      Navigator.of(context).pop();
                    },
                    child: Text('Update'),
                  )
                ],
              ),
            ));
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.teal,
            bottom: const TabBar(
              indicatorColor: Colors.teal,
              tabs: [
                Tab(icon: Icon(Icons.volume_up)),
                Tab(icon: Icon(Icons.history)),
              ],
            ),
            centerTitle: true,
            title: Text(widget.title),
          ),
          body: TabBarView(
            children: [
              Container(
                padding: const EdgeInsets.all(25),
                child: Center(
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
                        padding: const EdgeInsets.all(0.0),
                        child: TextField(
                            controller: _titleController,
                            decoration:
                                InputDecoration(hintText: 'Digite o texto'),
                            onChanged: (value) {
                              setState(() {
                                textAsSpeech = value;
                              });
                            }),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          textToSpeech(textAsSpeech);
                          _addItem();
                          _titleController.text = '';
                          textAsSpeech = '';
                        },
                        child: Text("Falar"),
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            fixedSize: const Size.fromWidth(double.maxFinite)),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.only(top: 15),
                          itemCount: _journals.length,
                          itemBuilder: (context, index) => ElevatedButton(
                            onPressed: () {
                              textToSpeech(_journals[index]['title']);
                            },
                            child: Text(_journals[index]['title']),
                            style:
                                ElevatedButton.styleFrom(primary: Colors.grey),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                child: Center(
                  child: ListView.builder(
                    itemCount: _journals.length,
                    itemBuilder: (context, index) => Card(
                      color: Colors.grey,
                      margin: const EdgeInsets.all(15),
                      child: ListTile(
                          title: Text(_journals[index]['title']),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _showForm(_journals[index]['id']),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () =>
                                      _deleteItem(_journals[index]['id']),
                                ),
                              ],
                            ),
                          )),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
