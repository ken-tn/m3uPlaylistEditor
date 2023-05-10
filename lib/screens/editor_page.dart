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

final List<String> dropDown = <String>['Modified', 'Artist', 'Title', 'Album'];
var logger = Logger(
  printer: PrettyPrinter(),
);

class _EditorPage extends State<EditorPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Audio> _playlistAudios = [];
  List<Audio> filteredSongs = [];
  List<Audio> _songData = [];
  String dropdownValue = dropDown.first;
  Future<void> _performSearch() async {
    setState(() {
      filteredSongs = _songData
          .where((element) => element.tags['title']
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });

    logger.d('Search results: ${filteredSongs.length}');
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var musicData = appState.musicData;

    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);

    return FutureBuilder<List>(
        future: musicData,
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            _songData = snapshot.data![1];
            if (filteredSongs.isEmpty && _searchController.text.isEmpty) {
              filteredSongs = _songData;
            }
          }

          return WillPopScope(
            onWillPop: () {
              SystemChrome.setPreferredOrientations(
                  [DeviceOrientation.portraitUp]);

              // trigger leaving and use own data
              Navigator.pop(context, false);

              // we need to return a future
              return Future.value(false);
            },
            child: GestureDetector(
              // unfocus on tap outside search bar
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: Scaffold(
                appBar: AppBar(
                  title: Row(children: [
                    const Text('Editor'),
                    const Padding(padding: EdgeInsets.all(20.0)),
                    DropdownButton(
                        value: dropdownValue,
                        icon: Row(
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(3.0),
                            ),
                            Icon(Icons.sort, color: Colors.white),
                          ],
                        ),
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
                    const Padding(padding: EdgeInsets.all(10.0)),
                    SizedBox(
                      width: 120,
                      child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            hintStyle: const TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                            suffixIcon: ClipOval(
                              child: Material(
                                color: Colors.transparent,
                                child: IconButton(
                                  iconSize: 20,
                                  onPressed: _searchController.clear,
                                  icon: const Icon(Icons.clear),
                                ),
                              ),
                            ),
                          )),
                    ),
                  ]),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.save),
                      tooltip: 'Save',
                      onPressed: () {
                        if (_playlistAudios.isEmpty) {
                          logger.d("Playlist is empty, not saving.");
                          return;
                        }
                        appState.selectedPlaylist.save(_playlistAudios);
                      },
                    ),
                  ],
                ),
                body: EditorWidget(
                  filteredSongs: filteredSongs,
                  onSave: (List<Audio> loadedSongs) {
                    _playlistAudios = loadedSongs;
                  },
                  dropdownValue: dropdownValue,
                ),
              ),
            ),
          );
        });
  }
}
