import 'dart:io';

import 'package:logger/logger.dart';
import 'package:m3u_playlist/models/playlist_model.dart';

import 'mp3_parser.dart';
import 'playlist_utils.dart';

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

List playlistsAndAudio() {
  Directory dir = Directory('/storage/emulated/0/');
  List<FileSystemEntity> files =
      dir.listSync(recursive: true, followLinks: false);

  List<Object> songs = [];
  List<Playlist> playlists = [];
  for (FileSystemEntity entity in files) {
    audioFileFormats.forEach((fileType, parser) => {
          if (entity.path.endsWith(fileType)) {songs.add(parser(entity))}
        });

    // add playlists
    if (entity.path.endsWith('.m3u')) {
      playlists.add(toPlaylist(entity));
    }
  }

  logger.d("Loaded Playlists and Audio");
  logger.d([playlists, songs]);

  return [playlists, songs];
}
