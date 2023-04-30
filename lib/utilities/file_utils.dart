import 'dart:io';

const audioFileFormats = <String>[
  '.mp3',
  '.mp4',
  '.wav',
  '.opus',
];

Map<String, List<FileSystemEntity>> getPlaylistsAndAudio() {
  Directory dir = Directory('/storage/emulated/0/');
  List<FileSystemEntity> files =
      dir.listSync(recursive: true, followLinks: false);

  List<FileSystemEntity> songs = [];
  List<FileSystemEntity> playlists = [];
  for (FileSystemEntity entity in files) {
    // add songs
    for (String fileType in audioFileFormats) {
      if (entity.path.endsWith(fileType)) {
        songs.add(entity);
      }
    }

    // add playlists
    if (entity.path.endsWith('.m3u')) {
      playlists.add(entity);
    }
  }

  print(songs);
  print(playlists);
  return {'playlists': playlists, 'audio': songs};
}
