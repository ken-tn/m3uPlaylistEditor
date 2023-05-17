import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:path/path.dart';

final logger = Logger();

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

  int compareDateModified(Audio other) {
    // File file = File(path);
    // File otherFile = File(other.path);

    // return file.lastModifiedSync().compareTo(otherFile.lastAccessedSync());
    return 0;
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

    int artistCompare = tags['artist']
        .toLowerCase()
        .compareTo(other.tags['artist'].toLowerCase());

    // apply album sort
    if (artistCompare == 0) {
      int albumCompare = compareAlbum(other);
      if (albumCompare == 0) {
        return compareTrack(other);
      }
      return albumCompare;
    }

    return artistCompare;
  }

  int compareAlbum(Audio other) {
    bool hasAlbum = tags.containsKey('album');
    bool otherHasAlbum = other.tags.containsKey('album');

    // has album?
    if (!hasAlbum || !otherHasAlbum) {
      if (!otherHasAlbum && !hasAlbum) {
        return 0;
      } else if (otherHasAlbum && !hasAlbum) {
        return -1;
      } else if (!otherHasAlbum && hasAlbum) {
        return 1;
      }
    }

    int albumCompare = tags['album']
        .toLowerCase()
        .compareTo(other.tags['album'].toLowerCase());

    if (albumCompare == 0) {
      return compareTrack(other);
    }
    return albumCompare;
  }

  int compareTrack(Audio other) {
    bool hasTrackNo = tags.containsKey('track');
    bool otherHasTrackNo = other.tags.containsKey('track');

    if (!hasTrackNo || !otherHasTrackNo) {
      if (!otherHasTrackNo && !hasTrackNo) {
        return 0;
      } else if (!otherHasTrackNo && hasTrackNo) {
        return -1;
      } else if (otherHasTrackNo && !hasTrackNo) {
        return 1;
      }
    }

    /*
    get first number from track
    track examples: 4/13, 4
    */

    final firstInt = RegExp('^[0-9]+');
    return int.parse(firstInt.firstMatch(tags['track'])?.group(0) as String)
        .compareTo(int.parse(
            firstInt.firstMatch(other.tags['track'])?.group(0) as String));
  }
}
