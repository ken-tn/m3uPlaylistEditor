import 'package:flutter/material.dart';
import 'package:m3u_playlist/models/audio_model.dart';
import 'package:m3u_playlist/utilities/app_state.dart';
import 'package:m3u_playlist/widgets/editor_widget.dart';
import 'package:provider/provider.dart';

import '../models/playlist_model.dart';
import '../utilities/log.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPage();
}

final List<String> dropDown = <String>['Modified', 'Artist', 'Title', 'Album'];

class _EditorPage extends State<EditorPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Audio> filteredSongs = [];
  List<Audio> _songData = [];
  String dropdownValue = dropDown.first;
  Future<void> _performSearch() async {
    setState(() {
      filteredSongs = _songData
          .where((element) => element
              .name()
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
    var audio = appState.audio;

    return FutureBuilder<List>(
        future: audio,
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            _songData = snapshot.data! as List<Audio>;
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
                      // prevents keyboard from resizing body which rotates screen
                      resizeToAvoidBottomInset: false,
                      appBar: AppBar(
                        title: Row(children: [
                          SortByWidget(
                            dropdownValue: dropdownValue,
                            onChanged: (value) => setState(() {
                              dropdownValue = value;
                            }),
                          ),
                          const Padding(padding: EdgeInsets.all(5.0)),
                          SearchWidget(
                            width: 70,
                            controller: _searchController,
                          ),
                          undoActionButton(context),
                          redoActionButton(context),
                        ]),
                        actions: [
                          saveActionButton(context),
                        ],
                      ),
                      body: snapshot.hasData
                          ? EditorWidget(
                              filteredSongs: filteredSongs,
                              sortType: dropdownValue,
                            )
                          : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                  Text(
                                      'This can take a few minutes on first launch.')
                                ],
                              ),
                            ));
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
                        undoActionButton(context),
                        redoActionButton(context),
                        const Padding(padding: EdgeInsets.all(20.0)),
                        saveActionButton(context),
                      ],
                    ),
                    body: EditorWidget(
                      filteredSongs: filteredSongs,
                      sortType: dropdownValue,
                    ),
                  );
                }
              },
            ),
          );
        });
  }

  IconButton saveActionButton(BuildContext context) {
    var appState = context.watch<AppState>();
    final Playlist selectedPlaylist = appState.selectedPlaylist;
    return IconButton(
      icon: const Icon(Icons.save),
      tooltip: 'Save',
      onPressed: selectedPlaylist.songs.isEmpty
          ? null
          : () {
              if (selectedPlaylist.songs.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Playlist is empty.'),
                  ),
                );
                return;
              }
              selectedPlaylist.save().then((value) => {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Saved ${appState.selectedPlaylist.name()}.'),
                      ),
                    ),
                  });
            },
    );
  }

  // Actions
  IconButton undoActionButton(BuildContext context) {
    var appState = context.watch<AppState>();
    final Playlist playlist = appState.selectedPlaylist;
    return IconButton(
      icon: const Icon(Icons.undo),
      tooltip: 'Undo',
      onPressed: playlist.past.isEmpty
          ? null
          : () {
              playlist.undo();
              appState.notify();
            },
    );
  }

  IconButton redoActionButton(BuildContext context) {
    var appState = context.watch<AppState>();
    final Playlist playlist = appState.selectedPlaylist;
    return IconButton(
      icon: const Icon(Icons.redo),
      tooltip: 'Redo',
      onPressed: playlist.future.isEmpty
          ? null
          : () {
              playlist.redo();
              appState.notify();
            },
    );
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
        icon: const Row(
          children: [
            Padding(
              padding: EdgeInsets.all(3.0),
            ),
            Icon(Icons.sort),
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
  // Focus for the search TextField
  FocusNode focus = FocusNode();

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return SizedBox(
      width: widget.width,
      child: TextField(
          controller: controller,
          focusNode: focus,
          onTap: () {
            FocusScope.of(context).requestFocus(focus);
          },
          decoration: InputDecoration(
            hintText: focus.hasFocus ? 'Search...' : null,
            border: InputBorder.none,
            prefixIcon: (focus.hasFocus || controller.text.isNotEmpty)
                ? null
                : const Icon(Icons.search),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 5,
              minHeight: 5,
            ),
            suffixIcon: ClipOval(
              child: Material(
                color: Colors.transparent,
                child: (focus.hasFocus || controller.text.isNotEmpty)
                    ? IconButton(
                        onPressed: controller.clear,
                        icon: const Icon(Icons.clear),
                      )
                    : null,
              ),
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 5,
              minHeight: 5,
            ),
          )),
    );
  }
}

typedef ChangeCallback = void Function(String value);
