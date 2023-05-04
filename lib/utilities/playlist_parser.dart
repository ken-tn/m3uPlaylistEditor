import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:m3u_playlist/models/playlist_model.dart';

Future<Playlist> toPlaylist(FileSystemEntity file) async {
  List<String> songs = [];

  if (file is File) {
    await file
        .openRead()
        .map(utf8.decode)
        .transform(const LineSplitter())
        .forEach((l) => {songs.add(l)});

    return Playlist(path: file.path, songs: songs);
  }

  return Playlist(path: file.path, songs: songs);
}
