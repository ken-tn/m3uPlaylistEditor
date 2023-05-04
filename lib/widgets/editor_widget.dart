import 'package:flutter/material.dart';
import 'package:m3u_playlist/models/audio_model.dart';
import 'package:m3u_playlist/models/playlist_model.dart';
import 'package:m3u_playlist/utilities/app_state.dart';
import 'package:provider/provider.dart';

class EditorWidget extends StatefulWidget {
  final AsyncSnapshot snapshot;
  final SaveCallback onSave;

  const EditorWidget({
    super.key,
    required this.snapshot,
    required this.onSave,
  });

  @override
  State<EditorWidget> createState() => _EditorWidget();
}

class _EditorWidget extends State<EditorWidget> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    return LayoutBuilder(builder: (context, constraints) {
      var snapshot = widget.snapshot;
      if (snapshot.hasData) {
        List<Audio> songs = snapshot.data![1];
        Playlist selectedPlaylist = appState.selectedPlaylist;
        List<Audio> loadedSongs = selectedPlaylist.toList(songs);
        widget.onSave(loadedSongs);

        void updateState() {
          setState(
            () => {loadedSongs = selectedPlaylist.toList(songs)},
          );
          widget.onSave(loadedSongs);
        }

        return SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(2),
                    ),
                    for (var audio in songs)
                      ListTile(
                        leading: const Icon(Icons.music_note),
                        title: Text(
                          audio.name(),
                        ),
                        onTap: () {
                          if (selectedPlaylist.add(audio.path)) {
                            updateState();
                          }
                        },
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ReorderableListView(
                  onReorder: (oldIndex, newIndex) => {
                    selectedPlaylist.swap(oldIndex, newIndex),
                    updateState(),
                  },
                  padding: const EdgeInsets.all(5),
                  children: [
                    for (Audio audio in loadedSongs)
                      ListTile(
                        key: ValueKey(audio),
                        textColor: audio.tags.containsKey('isMissing')
                            ? Theme.of(context).colorScheme.errorContainer
                            : Theme.of(context).textTheme.bodyMedium!.color,
                        leading: const Icon(Icons.music_note),
                        title: Text(audio.name()),
                        onTap: () {
                          if (selectedPlaylist.remove(audio.path)) {
                            updateState();
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

typedef SaveCallback = void Function(List<Audio> songs);
