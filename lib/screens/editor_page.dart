import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:m3u_playlist/models/audio_model.dart';
import 'package:m3u_playlist/utilities/app_state.dart';
import 'package:m3u_playlist/widgets/editor_widget.dart';
import 'package:provider/provider.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPage();
}

// function defined in the state class
void sortItems(String value) {}
const List<String> dropDown = <String>['None', 'Artist', 'Title', 'Date'];

class _EditorPage extends State<EditorPage> {
  var logger = Logger(
    printer: PrettyPrinter(),
  );
  List<Audio> songs = [];
  String dropdownValue = dropDown.first;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var musicData = appState.musicData;

    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);

    return FutureBuilder<List>(
        future: musicData,
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          return WillPopScope(
            onWillPop: () {
              SystemChrome.setPreferredOrientations(
                  [DeviceOrientation.portraitUp]);

              // trigger leaving and use own data
              Navigator.pop(context, false);

              // we need to return a future
              return Future.value(false);
            },
            child: Scaffold(
              appBar: AppBar(
                title: Row(children: [
                  const Padding(padding: EdgeInsets.all(20.0)),
                  DropdownButton(
                      value: dropdownValue,
                      icon: const Icon(Icons.sort, color: Colors.white),
                      items: dropDown.map<DropdownMenuItem<String>>(
                        (String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        },
                      ).toList(),
                      onChanged: (String? value) {
                        // This is called when the user selects an item.
                        setState(() {
                          dropdownValue = value!;
                        });
                      }),
                ]),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.save),
                    tooltip: 'Save',
                    onPressed: () {
                      if (songs.isEmpty) {
                        logger.d("Playlist is empty, not saving.");
                        return;
                      }
                      appState.selectedPlaylist.save(songs);
                    },
                  ),
                ],
              ),
              body: EditorWidget(
                  snapshot: snapshot,
                  onSave: (List<Audio> loadedSongs) {
                    songs = loadedSongs;
                  }),
            ),
          );
        });
  }
}
