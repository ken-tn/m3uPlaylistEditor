import 'dart:async';

import 'package:flutter/material.dart';
import 'package:m3u_playlist/models/playlist_model.dart';
import 'package:m3u_playlist/utilities/file_utils.dart';

import '../models/audio_model.dart';

class AppState extends ChangeNotifier {
  bool isLoading = true;
  Future<List<Playlist>> playlists = loadPlaylists();
  Future<List<Audio>> audio = loadAudio();
  late Playlist selectedPlaylist;

  AppState() {
    Future.wait([audio, playlists]).then((value) => isLoading = false);
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

  Future<bool> updateMusicData() async {
    if (isLoading) {
      return false;
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

    return true;
  }
}
