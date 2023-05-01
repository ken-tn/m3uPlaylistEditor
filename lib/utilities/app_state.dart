import 'package:flutter/material.dart';
import 'package:m3u_playlist/utilities/file_utils.dart';
import 'package:m3u_playlist/utilities/sql_utils.dart';
import 'package:permission_handler/permission_handler.dart';

class AppState extends ChangeNotifier {
  var musicData = playlistsAndAudio();

  Future<void> requestPermission(List<Permission> permission) async {
    // Map<Permission, PermissionStatus> statuses = await permission.request();
    await permission.request();
  }

  void updateMusicData() async {
    for (var playlist in musicData.elementAt(0)) {
      insertPlaylist(playlist);
    }

    for (var audio in musicData.elementAt(1)) {
      insertAudio(await audio);
    }
  }
}
