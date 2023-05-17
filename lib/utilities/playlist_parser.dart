import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:m3u_playlist/models/playlist_model.dart';
import 'package:shared_storage/saf.dart';

Future<Playlist> toPlaylist(DocumentFile file) async {
  List<String> songs = [];
  logger.d(file.name);

  Uint8List content = (await file.getContent())!;
  if (content.isEmpty) {
    return Playlist(path: file.uri.path, songs: []);
  }

  const splitter = LineSplitter();
  splitter
      .convert(String.fromCharCodes(content))
      .forEach((l) => {songs.add(l)});

  logger.d('songs: $songs');

  return Playlist(path: file.uri.path, songs: songs);
}
