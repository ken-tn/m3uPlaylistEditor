import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:logger/logger.dart';
import 'package:m3u_playlist/models/audio_model.dart';
import 'package:m3u_playlist/models/playlist_model.dart';
import 'package:m3u_playlist/utilities/sql_utils.dart';
import 'package:permission_handler/permission_handler.dart';

import 'mp3_parser.dart';
import 'playlist_parser.dart';

final logger = Logger(
  printer: PrettyPrinter(),
);

const Map<String, Function> audioFileFormats = {
  'mp3': toMP3,
};
// '.mp4',
// '.m4a',
// '.m4b',
// '.aac',
// '.flac',
// '.ogg',
// '.wav',
// '.opus',

Future<void> _requestPermissions() async {
  if (Platform.isAndroid) {
    var androidInfo = await DeviceInfoPlugin().androidInfo;
    final int sdkInt = androidInfo.version.sdkInt;
    if (sdkInt <= 29) {
      await [
        Permission.storage,
      ].request();
    } else if (sdkInt >= 30) {
      await [
        Permission.manageExternalStorage,
      ].request();
    }

    return;
  }

  if (Platform.isIOS) {
    // var iosInfo = await DeviceInfoPlugin().iosInfo;
    // var systemName = iosInfo.systemName;
    // var version = iosInfo.systemVersion;
    // var name = iosInfo.name;
    // var model = iosInfo.model;
    // print('$systemName $version, $name $model');
    // iOS 13.1, iPhone 11 Pro Max iPhone

    return;
  }
}

Future<File> createPlaylistFile(String name) async {
  await _requestPermissions();
  Directory dir = Directory('/storage/emulated/0/Playlists');
  if (!dir.existsSync()) {
    dir = await Directory(dir.path).create();
  }
  File playlistFile = File('${dir.path}/$name.m3u');
  if (!playlistFile.existsSync()) {
    playlistFile = await File(playlistFile.path).create();
  } else {
    return playlistFile;
  }
  return await playlistFile.writeAsString('');
}

List<FileSystemEntity> ignoredListSync(Directory currentDir,
    [List<FileSystemEntity>? foundFiles]) {
  List<FileSystemEntity> files = currentDir.listSync(followLinks: false);
  if (files.isEmpty) {
    return files;
  }

  // solves concurrency error
  List<FileSystemEntity> subFiles = [];
  for (FileSystemEntity dir in files) {
    // android 11: /Android/ access not allowed
    if (dir is Directory && !dir.path.toLowerCase().contains('android')) {
      subFiles.addAll(ignoredListSync(dir, foundFiles));
    }
  }

  files.addAll(subFiles);

  return files;
}

Future<List> playlistsAndAudio() async {
  await _requestPermissions();

  Directory dir = Directory('/storage/emulated/0/');
  Iterable<FileSystemEntity> files = ignoredListSync(dir);

  List<Audio> songs = [];
  List<Playlist> playlists = [];
  logger.d("Asynchronously loading playlists and audio.");
  await Future.forEach(files, (entity) async {
    // apply parser to matching file format
    for (var entry in audioFileFormats.entries) {
      if (entity.path.endsWith(entry.key)) {
        songs.add(await entry.value(entity));
      }
    }

    // parse playlist
    if (entity.path.endsWith('.m3u')) {
      playlists.add(await toPlaylist(entity));
    }
  });

  // List<Audio> songs = [];
  // await Future.forEach(unresolved, (element) async => songs.add(await element));

  logger.d([playlists, songs]);
  logger.d("Parsed all audio");

  Future.forEach(playlists, (element) => insertPlaylist(element));
  Future.forEach(songs, (element) => insertAudio(element));

  return [playlists, songs];
}
