import 'package:flutter/material.dart';
import 'package:m3u_playlist/models/playlist_model.dart';
import 'package:m3u_playlist/utilities/file_utils.dart';

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
  }
}
