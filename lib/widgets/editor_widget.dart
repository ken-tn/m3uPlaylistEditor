import 'dart:io';

import 'package:flutter/material.dart';
import 'package:m3u_playlist/models/audio_model.dart';
import 'package:m3u_playlist/models/playlist_model.dart';
import 'package:m3u_playlist/utilities/app_state.dart';
import 'package:provider/provider.dart';

class EditorWidget extends StatefulWidget {
  final AsyncSnapshot snapshot;
  final SaveCallback onSave;
  final String dropdownValue;

  const EditorWidget({
    super.key,
    required this.snapshot,
    required this.onSave,
    required this.dropdownValue,
  });

  @override
  State<EditorWidget> createState() => _EditorWidget();
}

class _EditorWidget extends State<EditorWidget> {
  ScrollController myScrollController = ScrollController();

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
        switch (widget.dropdownValue) {
          case 'Modified':
            songs.sort((a, b) => a.compareDateModified(b));
            songs = songs.reversed.toList();
            break;
          case 'Artist':
            songs.sort((a, b) => a.compareArtist(b));
            break;
          case 'Title':
            songs.sort((a, b) => a.compareTitle(b));
            break;
          default:
            break;
        }

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
                    Padding(
                      padding: const EdgeInsets.all(3),
                      child: Text('You have ${songs.length} songs: '),
                    ),
                    for (var audio in songs)
                      ListTile(
                        subtitle: audio.tags.containsKey('artist')
                            ? Text(audio.tags['artist'] as String)
                            : const Text('Unknown artist'),
                        leading: audio.tags.containsKey('cover')
                            ? Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 10,
                                        color: Colors.black,
                                        spreadRadius: 1)
                                  ],
                                ),
                                child: CircleAvatar(
                                  backgroundImage: Image.file(
                                    File(audio.tags['cover'] as String),
                                  ).image,
                                ),
                              )
                            : const Icon(Icons.music_note),
                        title: Text(
                          audio.name(),
                        ),
                        onTap: () {
                          if (selectedPlaylist.add(audio.path)) {
                            myScrollController.animateTo(
                                72.0 * (selectedPlaylist.songs.length + 1),
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeOut);
                            updateState();
                          }
                        },
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ReorderableListView(
                  scrollController: myScrollController,
                  onReorder: (oldIndex, newIndex) => {
                    selectedPlaylist.swap(oldIndex, newIndex),
                    updateState(),
                  },
                  header: Text(
                      '${selectedPlaylist.name()}: ${selectedPlaylist.songs.length} songs'),
                  padding: const EdgeInsets.all(5),
                  children: [
                    for (Audio audio in loadedSongs)
                      ListTile(
                        key: ValueKey(audio),
                        textColor: audio.tags.containsKey('isMissing')
                            ? Theme.of(context).colorScheme.errorContainer
                            : null,
                        subtitle: audio.tags.containsKey('artist')
                            ? Text(audio.tags['artist'] as String)
                            : const Text('Unknown artist'),
                        leading: audio.tags.containsKey('cover')
                            ? Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 10,
                                        color: Colors.black,
                                        spreadRadius: 1)
                                  ],
                                ),
                                child: CircleAvatar(
                                  backgroundImage: Image.file(
                                    File(audio.tags['cover'] as String),
                                  ).image,
                                ),
                              )
                            : const Icon(Icons.music_note),
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
        return const Center(child: CircularProgressIndicator());
      }
    });
  }
}

typedef SaveCallback = void Function(List<Audio> songs);
