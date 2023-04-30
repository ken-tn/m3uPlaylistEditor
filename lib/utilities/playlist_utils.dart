import 'dart:io';

import 'package:m3u_playlist/models/playlist_model.dart';

Playlist toPlaylist(FileSystemEntity file) {
  return Playlist(path: file.path);
}
