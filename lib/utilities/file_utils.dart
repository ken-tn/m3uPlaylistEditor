import 'dart:io';

import 'package:logger/logger.dart';
import 'package:m3u_playlist/models/audio_model.dart';
import 'package:m3u_playlist/models/playlist_model.dart';
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

Future<void> _requestPermission(List<Permission> permission) async {
  // Map<Permission, PermissionStatus> statuses = await permission.request();
  await permission.request();
}

Future<File> createPlaylistFile(String name) async {
  await _requestPermission(<Permission>[
    Permission.storage,
    Permission.accessMediaLocation,
  ]);

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

Future<List> playlistsAndAudio() async {
  await _requestPermission(<Permission>[
    Permission.storage,
    Permission.accessMediaLocation,
  ]);

  Directory dir = Directory('/storage/emulated/0/');
  List<FileSystemEntity> files =
      dir.listSync(recursive: true, followLinks: false);

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

  return [playlists, songs];
}
