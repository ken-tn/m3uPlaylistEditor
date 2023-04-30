import "dart:io";

import "package:m3u_playlist/models/playlist.dart";

Playlist toPlaylist(FileSystemEntity file) {
  return Playlist(id: 0, path: file.path);
}
