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

  File.fromRawPath(content)
      .openRead()
      .map(utf8.decode)
      .transform(const LineSplitter())
      .forEach((l) => {songs.add(l)});

  return Playlist(path: file.uri.path, songs: songs);
}
