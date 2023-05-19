import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:flutter/material.dart';
import 'package:m3u_playlist/widgets/main_app.dart';

import 'package:m3u_playlist/utilities/sql_utils.dart';

void main() async {
  // Avoid errors caused by flutter upgrade.
  WidgetsFlutterBinding.ensureInitialized();

  // >10 sessions https://github.com/arthenica/ffmpeg-kit/issues/633
  FFmpegKitConfig.setSessionHistorySize(30);
  loadDatabase();

  runApp(const MainApp());
}
