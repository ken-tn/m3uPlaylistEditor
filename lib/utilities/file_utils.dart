import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:m3u_playlist/models/audio_model.dart';
import 'package:m3u_playlist/models/playlist_model.dart';
import 'package:path/path.dart';
import 'package:shared_storage/shared_storage.dart';

import 'log.dart';
import 'mp3_parser.dart';
import 'playlist_parser.dart';

const Map<String, Function> audioFileFormats = {
  'audio/mpeg': toMP3,
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
      // await [
      //   Permission.storage,
      // ].request();
    } else if (sdkInt >= 30) {
      // await [
      //   Permission.manageExternalStorage,
      // ].request();
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

Future<Object?> createPlaylistFile(String name) async {
  //await _requestPermissions();
  final Uri playlistUriPath = Uri.parse(
      'content://com.android.externalstorage.documents/tree/primary%3APlaylists');

  Uri playlistUri = await waitSafPermission(playlistUriPath);
  Directory dir = Directory('/storage/emulated/0/Playlists');
  if (!dir.existsSync()) {
    dir = await Directory(dir.path).create();
  }
  File playlistFile = File('${dir.path}/$name.m3u');
  if (playlistFile.existsSync()) {
    return playlistFile;
  }

  return await createFile(
    playlistUri,
    mimeType: 'audio/x-mpegurl',
    displayName: '$name.m3u',
    content: '',
  );
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

Future<Uri?> hasSafPermission(Uri uri) async {
  List<UriPermission> grantedUris = await persistedUriPermissions() ?? [];
  logger.d('Granted URIs: $grantedUris');
  if (grantedUris.isEmpty) {
    return null;
  }

  for (UriPermission permission in grantedUris) {
    if (permission.uri == uri) {
      return permission.uri;
    }
  }

  return null;
}

Future<Uri> waitSafPermission(Uri uri) async {
  Uri? tempUri = await hasSafPermission(uri);

  while (tempUri == null) {
    tempUri ??= await openDocumentTree(initialUri: uri);
  }

  return tempUri;
}

String toRealPath(String uriPath) {
  String realPath = Uri.decodeFull(basename(uriPath));
  String asdf = realPath.substring(realPath.indexOf(':') + 1);

  return '/storage/emulated/0/$asdf';
}

const List<DocumentFileColumn> columns = <DocumentFileColumn>[
  DocumentFileColumn.displayName,
  DocumentFileColumn.lastModified,
  DocumentFileColumn.mimeType,
];
Future<List<DocumentFile>> recursiveListFiles(Uri directoryUri) async {
  if (directoryUri.path.contains('.thumbnails')) {
    return [];
  }

  bool hasPermission = await canRead(directoryUri) ?? false;
  if (!hasPermission) {
    logger.d('Failed to read $directoryUri.');
    return [];
  }

  logger.d(directoryUri);
  List<DocumentFile> unfilteredfiles = [];
  Stream<DocumentFile> stream = listFiles(directoryUri, columns: columns);

  // take files from the stream and close it
  StreamSubscription sub = stream.listen((file) {
    unfilteredfiles.add(file);
  });
  await sub.asFuture();
  sub.cancel();

  List<DocumentFile> files = [];
  for (DocumentFile file in unfilteredfiles) {
    logger.d('Found ${file.name}.');
    if (file.isDirectory ?? false) {
      files.addAll(await recursiveListFiles(file.uri));
    } else if (file.type == 'audio/mpeg' || file.type == 'audio/x-mpegurl') {
      files = [...files, file];
    }
  }

  return files;
}

Future? isLoading;
Future<List<Playlist>> loadPlaylists() async {
  if (isLoading != null) {
    await isLoading;
  }
  final Completer completer = Completer<bool>();
  isLoading = completer.future;
  List<Playlist> playlists = [];

  if (Platform.isAndroid) {
    final Uri playlistUri = Uri.parse(
        'content://com.android.externalstorage.documents/tree/primary%3APlaylists');
    await waitSafPermission(playlistUri);

    List<DocumentFile> playlistFiles = await recursiveListFiles(playlistUri);
    logger.d("Asynchronously loading playlists.");
    for (DocumentFile entity in playlistFiles) {
      if (entity.type == 'audio/x-mpegurl') {
        playlists.add(await toPlaylist(entity));
      }
    }
  }

  completer.complete(true);
  logger.d("Parsed all playlists");
  return playlists;
}

Future<List<Audio>> loadAudio() async {
  if (isLoading != null) {
    await isLoading;
  }
  final Completer completer = Completer<bool>();
  //await _requestPermissions();

  List<Audio> songs = [];
  List<Future<Audio>> parsingSongs = [];
  if (Platform.isAndroid) {
    final Uri musicUri = Uri.parse(
        'content://com.android.externalstorage.documents/tree/primary%3AMusic');
    await waitSafPermission(musicUri);

    int processing = 0;
    int batchSize = 20;
    List<DocumentFile> audioFiles = await recursiveListFiles(musicUri);
    logger.d("Asynchronously loading audio.");
    for (DocumentFile entity in audioFiles) {
      for (var entry in audioFileFormats.entries) {
        if (entity.type == entry.key) {
          // process in batches of batchSize
          if (processing > batchSize) {
            await Future.wait(parsingSongs).then(
              (loadedAudios) => {
                songs.addAll(loadedAudios),
                parsingSongs = [],
                processing = 0,
              },
            );
          }
          processing++;
          Future<Audio> parsedAudio = entry.value(entity);
          parsingSongs.add(parsedAudio);
        }
      }
    }
  }

  // wait for the last futures to finish
  await Future.wait(parsingSongs).then(
    (loadedAudios) => {songs.addAll(loadedAudios)},
  );
  completer.complete(true);
  logger.d("Parsed all audio");
  return songs;
}
