import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:m3u_playlist/models/playlist_model.dart';
import 'package:m3u_playlist/utilities/file_utils.dart';

import 'log.dart';

class AppState extends ChangeNotifier {
  bool isLoading = false;
  Future<List> musicData = playlistsAndAudio();
  late Playlist selectedPlaylist;
  String consoleText = '';
  Timer? timer;

  void startTimer() {
    if (timer != null) {
      return;
    }

    logger.d("started timer");
    timer = Timer.periodic(
        const Duration(milliseconds: 5),
        (Timer t) => {
              if (consoleText != buffer.lastLogLine)
                {
                  consoleText =
                      '${buffer.lastLogLine.substring(0, min(buffer.lastLogLine.length, 100))}...',
                  notifyListeners(),
                }
            });
  }

  void stopTimer() {
    if (timer == null) {
      return;
    }
    logger.d("stopped timer");
    timer!.cancel();
  }

  void updateSelectedPlaylist(Playlist playlist) {
    selectedPlaylist = playlist;
    notifyListeners();
  }

  void updateMusicData() async {
    if (isLoading) {
      return;
    }

    isLoading = true;
    // load in background
    Future<List> newMusicData = playlistsAndAudio();
    await newMusicData;

    // apply new loaded data
    musicData = newMusicData;
    isLoading = false;
    notifyListeners();
  }
}
