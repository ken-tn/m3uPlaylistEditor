import 'package:m3u_playlist/models/audio_model.dart';
import 'package:path/path.dart';

class Playlist {
  final String path;
  final List<String> songs;

  const Playlist({
    required this.path,
    required this.songs,
  });

  // Convert a PlaylistFile into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'path': path,
    };
  }

  Map<String, Audio> mapToAudio(List<Audio> loadedSongs) {
    Map<String, Audio> mapped = {};

    for (String path in songs) {
      for (Audio loadedAudio in loadedSongs) {
        if (path == loadedAudio.path) {
          mapped.addAll({path: loadedAudio});
          continue;
        }

        // no audio found, add null entry
        mapped.addAll({
          path: Audio(
              path: path, filetype: extension(path), tags: {'isMissing': true})
        });
      }
    }

    return mapped;
  }

  String name() {
    return basename(path);
  }

  @override
  String toString() {
    return 'Playlist{path: $path songs: ${songs.length}';
  }
}
