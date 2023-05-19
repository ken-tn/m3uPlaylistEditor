import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:m3u_playlist/models/audio_model.dart';
import 'package:path/path.dart';
import 'package:shared_storage/saf.dart';

import '../utilities/log.dart';

class Playlist {
  final String path;
  final List<String> songs;

  const Playlist({
    required this.path,
    required this.songs,
  });

  // Convert a PlaylistFile into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'path': path,
    };
  }

  List<Audio> toList(List<Audio> loadedSongs) {
    List<Audio> mapped = [];

    for (String path in songs) {
      bool found = false;
      for (Audio loadedAudio in loadedSongs) {
        if (path == loadedAudio.path) {
          found = true;
          mapped.add(loadedAudio);

          break;
        }
      }

      if (!found) {
        // no audio found, add null entry
        mapped.add(Audio(
          path: path,
          fileType: extension(path),
          lastModified: 0,
          tags: {'isMissing': true},
        ));
      }
    }

    return mapped;
  }

  bool add(String path) {
    for (String song in songs) {
      if (song == path) {
        return false;
      }
    }

    songs.add(path);
    return true;
  }

  bool remove(String path) {
    for (String song in songs) {
      if (song == path) {
        songs.remove(song);
        return true;
      }
    }

    return false;
  }

  bool swap(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      // removing the item at oldIndex will shorten the list by 1.
      newIndex -= 1;
    }

    if ((oldIndex < 0 || oldIndex > songs.length - 1) ||
        (newIndex < 0 || newIndex > songs.length - 1)) {
      logger.d('Playlist failed to move: $oldIndex to $newIndex.');
      return false;
    }
    logger.d('Playlist moving $oldIndex to $newIndex');

    final String old = songs[oldIndex];
    if (oldIndex < newIndex) {
      // shift everything back
      for (var i = oldIndex; i < newIndex; i++) {
        songs[i] = songs[i + 1];
      }

      songs[newIndex] = old;
    } else {
      // shift everything forward
      for (var i = oldIndex; i > newIndex; i--) {
        songs[i] = songs[i - 1];
      }

      songs[newIndex] = old;
    }

    return true;
  }

  String name() {
    return basename(Uri.decodeFull(path));
  }

  Future<bool?> save(List<Audio> songs) async {
    logger.d("Attempting to save.");
    Uri playlistUri =
        Uri.parse('content://com.android.externalstorage.documents$path');

    String output = '';
    for (Audio song in songs) {
      output += '${song.path}\n';
    }

    // remove file endline
    output = output.substring(0, output.length - 1);
    logger.d('Saving playlist\n$output');

    return await writeToFileAsBytes(
      playlistUri,
      bytes: utf8.encode(output) as Uint8List,
      mode: FileMode.write,
    );
  }

  @override
  String toString() {
    return 'Playlist{path: $path, songs: ${songs.length}}';
  }
}
