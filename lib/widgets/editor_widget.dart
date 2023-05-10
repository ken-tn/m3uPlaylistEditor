import 'dart:io';

import 'package:flutter/material.dart';
import 'package:m3u_playlist/models/audio_model.dart';
import 'package:m3u_playlist/models/playlist_model.dart';
import 'package:m3u_playlist/utilities/app_state.dart';
import 'package:provider/provider.dart';

class EditorWidget extends StatefulWidget {
  final List<Audio> filteredSongs;
  final SaveCallback onSave;
  final String dropdownValue;

  const EditorWidget({
    super.key,
    required this.filteredSongs,
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
    List<Audio> songs = widget.filteredSongs;
    String sortType = widget.dropdownValue;

    return LayoutBuilder(builder: (context, constraints) {
      Playlist selectedPlaylist = appState.selectedPlaylist;
      List<Audio> loadedSongs = selectedPlaylist.toList(songs);

      widget.onSave(loadedSongs);
      switch (sortType) {
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
        case 'Album':
          songs.sort((a, b) => a.compareAlbum(b));
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

      return OrientationBuilder(builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          return Column(
            children: [
              deviceSongs(songs, sortType, selectedPlaylist, updateState),
              const Divider(
                thickness: 5,
                height: 5,
              ),
              playlistSongs(
                  selectedPlaylist, updateState, loadedSongs, context),
            ],
          );
        } else {
          return Row(
            children: [
              deviceSongs(songs, sortType, selectedPlaylist, updateState),
              const VerticalDivider(
                thickness: 5,
                width: 5,
              ),
              playlistSongs(
                  selectedPlaylist, updateState, loadedSongs, context),
            ],
          );
        }
      });
    });
  }

  Expanded playlistSongs(Playlist selectedPlaylist, void Function() updateState,
      List<Audio> loadedSongs, BuildContext context) {
    return Expanded(
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
              leading: LeadingIconWidget(
                audio: audio,
              ),
              title: Text(audio.name()),
              onTap: () {
                if (selectedPlaylist.remove(audio.path)) {
                  updateState();
                }
              },
            ),
        ],
      ),
    );
  }

  Expanded deviceSongs(List<Audio> songs, String sortType,
      Playlist selectedPlaylist, void Function() updateState) {
    return Expanded(
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(3),
            child: Text('You have ${songs.length} songs: '),
          ),
          for (var audio in songs)
            ListTile(
              subtitle: SubtitleTextWidget(
                sortType: sortType,
                audio: audio,
              ),
              leading: LeadingIconWidget(
                audio: audio,
              ),
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
    );
  }
}

class SubtitleTextWidget extends StatefulWidget {
  final String sortType;
  final Audio audio;

  const SubtitleTextWidget({
    super.key,
    required this.sortType,
    required this.audio,
  });

  @override
  State<SubtitleTextWidget> createState() => _SubtitleTextWidget();
}

class _SubtitleTextWidget extends State<SubtitleTextWidget> {
  @override
  Widget build(BuildContext context) {
    final Audio audio = widget.audio;
    late Text returnSubtitle;
    switch (widget.sortType) {
      case 'Album':
        returnSubtitle = audio.tags.containsKey('album')
            ? Text(audio.tags['album'] as String)
            : const Text('Unknown album');
        break;
      default:
        returnSubtitle = audio.tags.containsKey('artist')
            ? Text(audio.tags['artist'] as String)
            : const Text('Unknown artist');
        break;
    }

    return returnSubtitle;
  }
}

class LeadingIconWidget extends StatefulWidget {
  final Audio audio;

  const LeadingIconWidget({
    super.key,
    required this.audio,
  });

  @override
  State<LeadingIconWidget> createState() => _LeadingIconWidget();
}

class _LeadingIconWidget extends State<LeadingIconWidget> {
  @override
  Widget build(BuildContext context) {
    final audio = widget.audio;

    if (audio.tags.containsKey('cover')) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(blurRadius: 10, color: Colors.black, spreadRadius: 1)
          ],
        ),
        child: CircleAvatar(
          backgroundImage: Image.file(
            File(audio.tags['cover'] as String),
          ).image,
        ),
      );
    } else {
      return const Icon(Icons.music_note);
    }
  }
}

typedef SaveCallback = void Function(List<Audio> songs);
