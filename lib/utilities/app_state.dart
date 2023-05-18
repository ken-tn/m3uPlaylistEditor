import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:m3u_playlist/models/playlist_model.dart';
import 'package:m3u_playlist/utilities/file_utils.dart';

import '../models/audio_model.dart';
import 'log.dart';

class AppState extends ChangeNotifier {
  bool isLoading = false;
  Future<List<Playlist>> playlists = loadPlaylists();
  Future<List<Audio>> audio = loadAudio();
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

  void updatePlaylists() async {
    if (isLoading) {
      return;
    }

    isLoading = true;
    Future<List<Playlist>> newPlaylists = loadPlaylists();
    await newPlaylists;
    playlists = newPlaylists;

    isLoading = false;
    notifyListeners();
  }

  void updateMusicData() async {
    if (isLoading) {
      return;
    }

    isLoading = true;
    // load in background
    Future<List<Playlist>> newPlaylists = loadPlaylists();
    await newPlaylists;
    playlists = newPlaylists;
    Future<List<Audio>> newAudio = loadAudio();
    await newAudio;
    audio = newAudio;
    isLoading = false;
    notifyListeners();
  }
}
