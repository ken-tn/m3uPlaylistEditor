import 'package:flutter/material.dart';
import 'package:m3u_playlist/models/audio_model.dart';
import 'package:m3u_playlist/models/playlist_model.dart';
import 'package:m3u_playlist/utilities/app_state.dart';
import 'package:provider/provider.dart';

class EditorWidget extends StatefulWidget {
  const EditorWidget({
    super.key,
  });

  @override
  State<EditorWidget> createState() => _EditorWidget();
}

class _EditorWidget extends State<EditorWidget> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    return FutureBuilder<List>(
        future: appState.musicData,
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            List<Audio> _songs = snapshot.data![1];
            Playlist _selectedPlaylist = appState.selectedPlaylist;
            List<Audio> _loadedSongs = _selectedPlaylist.toList(_songs);

            return SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(2),
                        ),
                        for (var audio in _songs)
                          ListTile(
                            leading: const Icon(Icons.music_note),
                            title: Text(
                              audio.name(),
                            ),
                            onTap: () {
                              _selectedPlaylist.add(audio.path);
                              setState(() => {
                                    _loadedSongs =
                                        _selectedPlaylist.toList(_songs)
                                  });
                            },
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ReorderableListView(
                      onReorder: (oldIndex, newIndex) => {
                        _selectedPlaylist.swap(oldIndex, newIndex),
                        print(_loadedSongs),
                        print(_selectedPlaylist.songs),
                        setState(() =>
                            {_loadedSongs = _selectedPlaylist.toList(_songs)})
                      },
                      padding: const EdgeInsets.all(10),
                      children: [
                        for (Audio audio in _loadedSongs)
                          ListTile(
                            key: ValueKey(audio),
                            textColor: audio.tags.containsKey('isMissing')
                                ? Theme.of(context).colorScheme.errorContainer
                                : Theme.of(context).textTheme.bodyMedium!.color,
                            leading: const Icon(Icons.music_note),
                            title: Text(audio.name()),
                            onTap: () {
                              if (_selectedPlaylist.remove(audio.path)) {
                                setState(() => {
                                      _loadedSongs =
                                          _selectedPlaylist.toList(_songs)
                                    });
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
