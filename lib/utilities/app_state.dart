import 'package:flutter/material.dart';
import 'package:m3u_playlist/models/playlist_model.dart';
import 'package:m3u_playlist/utilities/file_utils.dart';
import 'package:m3u_playlist/utilities/sql_utils.dart';
import 'package:permission_handler/permission_handler.dart';

class AppState extends ChangeNotifier {
  Future<List> musicData = playlistsAndAudio();
  late Playlist selectedPlaylist;
  bool isLoadingData = false;

  void updateSelectedPlaylist(Playlist playlist) {
    selectedPlaylist = playlist;
    notifyListeners();
  }

  void updateMusicData() async {
    musicData = playlistsAndAudio();
    notifyListeners();

    List data = await musicData;

    for (var playlist in data.elementAt(0)) {
      insertPlaylist(playlist);
    }

    for (var audio in data.elementAt(1)) {
      insertAudio(audio);
    }
  }
}
