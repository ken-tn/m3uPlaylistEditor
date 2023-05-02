import 'package:flutter/material.dart';
import 'package:m3u_playlist/utilities/app_state.dart';
import 'package:m3u_playlist/utilities/file_utils.dart';
import 'package:m3u_playlist/widgets/playlist_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var musicData = appState.musicData;

    Future<void> _pullRefresh() async {
      appState.updateMusicData();
    }

    return FutureBuilder<List>(
      future: musicData,
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Add your onPressed code here!
            },
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: const Icon(Icons.add),
          ),
          body: RefreshIndicator(
            onRefresh: _pullRefresh,
            child: PlaylistWidget(snapshot: snapshot),
          ),
        );
      },
    );
  }
}
