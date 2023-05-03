import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:m3u_playlist/models/audio_model.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

Future<Audio> toMP3(FileSystemEntity file) async {
  final path = file.path;
  final session = await FFprobeKit.getMediaInformation(path);
  final information = session.getMediaInformation();

  if (information == null) {
    // CHECK THE FOLLOWING ATTRIBUTES ON ERROR
    logger.d("Failed to get information on $file.");
    final returnCode = session.getReturnCode();
    final failStackTrace = session.getFailStackTrace();
    logger.d(returnCode, failStackTrace);
    return Audio(
      path: file.path,
      filetype: 'Mp3',
      tags: {},
    );
  }

  final format = information.getFormatProperties();
  if (format != null) {
    final tags = format['tags'];
    logger.d(tags);
    return Audio(
      path: file.path,
      filetype: 'Mp3',
      tags: Map<String, Object>.from(tags),
    );
  }

  throw Exception();
}
