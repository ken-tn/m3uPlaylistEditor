import 'dart:convert';

import 'package:path/path.dart';

class Audio {
  final String path;
  final String filetype;
  final Map<String, dynamic> tags;

  const Audio({
    required this.path,
    required this.filetype,
    required this.tags,
  });

  String name() {
    if (tags.containsKey('title')) {
      return tags['title'] as String;
    }

    return basename(path);
  }

  // Convert a PlaylistFile into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'filetype': filetype,
      'tags': json.encode(tags),
    };
  }

  int compareTitle(Audio other) {
    String title = tags.containsKey('title') ? tags['title'] : basename(path);
    String otherTitle = other.tags.containsKey('title')
        ? other.tags['title']
        : basename(other.path);

    return title.toLowerCase().compareTo(otherTitle.toLowerCase());
  }

  int compareArtist(Audio other) {
    bool hasArtist = tags.containsKey('artist');
    bool otherHasArtist = other.tags.containsKey('artist');

    // has artist?
    if (!hasArtist || !otherHasArtist) {
      if (!otherHasArtist && !hasArtist) {
        return 0;
      } else if (otherHasArtist && !hasArtist) {
        return -1;
      } else if (!otherHasArtist && hasArtist) {
        return 1;
      }
    }

    return tags['artist']
        .toLowerCase()
        .compareTo(other.tags['artist'].toLowerCase());
  }
}
