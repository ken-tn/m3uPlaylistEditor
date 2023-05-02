import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:m3u_playlist/models/audio_model.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

Future<Audio> toMP3(FileSystemEntity file) async {
  return await FFprobeKit.getMediaInformation(file.path).then((session) async {
    final information = session.getMediaInformation();
    logger.d(information);

    if (information == null) {
      // CHECK THE FOLLOWING ATTRIBUTES ON ERROR
      final returnCode = await session.getReturnCode();
      final failStackTrace = await session.getFailStackTrace();
      logger.d(returnCode, failStackTrace);
    } else {
      final format = information.getFormatProperties();
      if (format != null) {
        logger.d(format['tags']);
        return Audio(
          path: file.path,
          filetype: 'Mp3',
          tags: Map<String, Object>.from(format['tags']),
        );
      }
    }

    return Audio(
      path: file.path,
      filetype: 'Mp3',
      tags: {},
    );
  });
}
