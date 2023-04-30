// Define a function that inserts dogs into the database
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:m3u_playlist/models/playlist_model.dart';
import 'package:m3u_playlist/models/audio_model.dart';

Future<Database> loadDatabase() async {
  return openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'm3u_playlist_data.db'),
    // When the database is first created, create a table to store the models.
    onCreate: (db, version) {},
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
}

Future<void> insertPlaylist(Playlist playlist) async {
  // Get a reference to the database.
  final db = await loadDatabase();

  // Insert the Playlist into the correct table. You might also specify the
  // `conflictAlgorithm` to use in case the same Playlist is inserted twice.
  //
  // In this case, replace any previous data.
  await db.insert(
    'Playlist',
    playlist.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<void> insertAudio(Audio audio) async {
  final db = await loadDatabase();

  await db
      .insert(
        'Audio',
        audio.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      )
      .then((value) => {
            db.insert(
              audio.type,
              audio.audioObject.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            )
          });
}
