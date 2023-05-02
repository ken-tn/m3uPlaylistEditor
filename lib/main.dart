import 'package:flutter/material.dart';
import 'package:m3u_playlist/widgets/main_app.dart';

import 'package:m3u_playlist/utilities/sql_utils.dart';

void main() async {
  // Avoid errors caused by flutter upgrade.
  WidgetsFlutterBinding.ensureInitialized();
  loadDatabase();

  runApp(const MainApp());
}
