import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:m3u_playlist/models/playlist_model.dart';
import 'package:m3u_playlist/utilities/sql_utils.dart';
import 'package:shared_storage/saf.dart';
import 'file_utils.dart';

Future<Playlist> toPlaylist(DocumentFile file) async {
  List<String> songs = [];

  Uint8List content = (await file.getContent())!;
  if (content.isEmpty) {
    return Playlist(path: file.uri.path, songs: []);
  }

  const splitter = LineSplitter();
  splitter
      .convert(utf8.decode(content))
      .forEach((line) => songs.add(toUriPath(line)));

  Playlist newPlaylist = Playlist(path: file.uri.path, songs: songs);
  insertPlaylist(newPlaylist);

  return newPlaylist;
}
