import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m3u_playlist/widgets/editor_widget.dart';

class EditorPage extends StatelessWidget {
  const EditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);

    return WillPopScope(
      onWillPop: () {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

        // trigger leaving and use own data
        Navigator.pop(context, false);

        // we need to return a future
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(),
        body: const EditorWidget(),
      ),
    );
  }
}
