import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:m3u_playlist/models/audio_model.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

const uuid = Uuid();

Future<Audio> toMP3(FileSystemEntity file) async {
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String coverPath = documentsDirectory.path;
  String imageUUID = uuid.v4();
  String imagePath = "$coverPath/$imageUUID.jpg";
  final path = file.path;
  final session = await FFprobeKit.getMediaInformation(path);
  final information = session.getMediaInformation();
  await FFmpegKit.execute(
          '-i "$path" -an -vcodec copy -frames:v 1 -update 1 "$imagePath"')
      .then((session) async {
    // Command arguments
    final commandArguments = session.getArguments();

    logger.d(commandArguments);
  });

  Audio audio = Audio(
    path: file.path,
    filetype: 'Mp3',
    tags: {},
  );

  if (information == null) {
    // CHECK THE FOLLOWING ATTRIBUTES ON ERROR
    logger.d("Failed to get information on $file.");
    final returnCode = session.getReturnCode();
    final failStackTrace = session.getFailStackTrace();
    logger.d(returnCode, failStackTrace);
    return audio;
  }

  if (await File(imagePath).exists()) {
    audio.tags['cover'] = imagePath.substring(1);
    logger.d("Set cover for $file.");
  }

  final format = information.getFormatProperties();
  if (format != null) {
    final tags = format['tags'];
    audio.tags.addAll(Map<String, Object>.from(tags));
    logger.d(audio.tags);
    return audio;
  }

  throw Exception();
}
