import 'package:flutter/material.dart';
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

    return FutureBuilder<List>(
        future: musicData,
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            _songData = snapshot.data![1];
            if (filteredSongs.isEmpty && _searchController.text.isEmpty) {
              filteredSongs = _songData;
            }
          }

          return GestureDetector(
            // unfocus on tap outside search bar
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: OrientationBuilder(
              builder: (context, orientation) {
                if (orientation == Orientation.portrait) {
                  // Portrait
                  return Scaffold(
                    appBar: AppBar(
                      title: Row(children: [
                        SortByWidget(
                          dropdownValue: dropdownValue,
                          onChanged: (value) => setState(() {
                            dropdownValue = value;
                          }),
                        ),
                        const Padding(padding: EdgeInsets.all(10.0)),
                        SearchWidget(
                          width: 100,
                          controller: _searchController,
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
                  );
                } else {
                  // Landscape
                  return Scaffold(
                    appBar: AppBar(
                      title: Row(children: [
                        const Text('Editor'),
                        const Padding(padding: EdgeInsets.all(20.0)),
                        SortByWidget(
                          dropdownValue: dropdownValue,
                          onChanged: (value) => setState(() {
                            dropdownValue = value;
                          }),
                        ),
                        const Padding(padding: EdgeInsets.all(10.0)),
                        SearchWidget(
                          width: 150,
                          controller: _searchController,
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
                  );
                }
              },
            ),
          );
        });
  }
}

class SortByWidget extends StatefulWidget {
  final String dropdownValue;
  final ChangeCallback onChanged;

  const SortByWidget({
    super.key,
    required this.dropdownValue,
    required this.onChanged,
  });

  @override
  State<SortByWidget> createState() => _SortByWidget();
}

class _SortByWidget extends State<SortByWidget> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton(
        value: widget.dropdownValue,
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
          widget.onChanged(value!);
        });
  }
}

class SearchWidget extends StatefulWidget {
  final double width;
  final TextEditingController controller;

  const SearchWidget({
    super.key,
    required this.width,
    required this.controller,
  });

  @override
  State<SearchWidget> createState() => _SearchWidget();
}

class _SearchWidget extends State<SearchWidget> {
  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return SizedBox(
      width: widget.width,
      child: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: const TextStyle(color: Colors.white54),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: ClipOval(
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  iconSize: 20,
                  onPressed: controller.clear,
                  icon: const Icon(Icons.clear),
                ),
              ),
            ),
          )),
    );
  }
}

typedef ChangeCallback = void Function(String value);
