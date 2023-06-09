import 'dart:convert';
import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:m3u_playlist/models/audio_model.dart';
import 'package:m3u_playlist/utilities/sql_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_storage/saf.dart';
import 'package:uuid/uuid.dart';

import 'log.dart';

const uuid = Uuid();

Future<Audio> toMP3(DocumentFile file) async {
  // check the database first
  String uripath = file.uri.path;
  logger.i(uripath);
  List results = await findAudio(uripath);
  int lastModified = file.lastModified!.millisecondsSinceEpoch;
  if (results.isNotEmpty) {
    logger.d("Loading database entry for $uripath");
    var entry = results[0].row;

    return Audio(
        path: entry[0],
        fileType: entry[1],
        lastModified: lastModified,
        tags: json.decode(entry[2]) as Map<String, dynamic>);
  }

  Directory supportDirectory = await getApplicationSupportDirectory();
  String coverPath = supportDirectory.path;
  String coverName = uuid.v4();
  String imagePath = "$coverPath/$coverName.jpg";
  File mp3copy = File("${(await getTemporaryDirectory()).path}/$coverName.mp3");
  mp3copy.writeAsBytes((await file.getContent())!);
  final session = await FFprobeKit.getMediaInformation(mp3copy.path);
  final information = session.getMediaInformation();
  await FFmpegKit.execute(
          '-i "${mp3copy.path}" -an -vcodec copy -frames:v 1 -update 1 "$imagePath"')
      .then((session) async {
    // Command arguments
    final commandArguments = session.getArguments();

    logger.d(commandArguments);
  });
  mp3copy.delete();

  if (information == null) {
    // CHECK THE FOLLOWING ATTRIBUTES ON ERROR
    logger.e("Failed to get information on $uripath.");
    final returnCode = await session.getReturnCode();
    final failStackTrace = await session.getFailStackTrace();
    logger.e(returnCode, failStackTrace);

    // TODO: This could lock the app if a file is corrupt

    session.cancel();
    return await toMP3(file);
  }

  session.cancel();
  Audio audio = Audio(
    path: uripath,
    fileType: 'Mp3',
    lastModified: lastModified,
    tags: {},
  );

  if (await File(imagePath).exists()) {
    audio.tags['cover'] = imagePath.substring(1);
    logger.d("Set cover for $uripath.");
  }

  final format = information.getFormatProperties();
  if (format != null) {
    final tags = format['tags'];
    if (tags != null) {
      audio.tags.addAll(Map<String, Object>.from(tags));
    }
    logger.d(audio.tags);

    insertAudio(audio);
    return audio;
  }

  throw Exception();
}
