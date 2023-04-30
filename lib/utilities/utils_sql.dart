// Define a function that inserts dogs into the database
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/playlist.dart';

Future<Database> database = main();

Future<Database> main() async {
  return database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'm3u_playlist_data.db'),
    // When the database is first created, create a table to store the models.
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.

      // TODO: use json tag data instead of explicit tags for files?
      return db.execute(
        """
        CREATE TABLE Playlist(id INTEGER PRIMARY KEY, path TEXT);
        CREATE TABLE Audio(id INTEGER, path TEXT, type TEXT);
        CREATE TABLE Mp3ID3v1(id INTEGER, title TEXT, artist TEXT,
            album TEXT, year INTEGER, genre TEXT,
            FOREIGN KEY(id) REFERENCES Audio(id))
        """,
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
}

Future<void> insertPlaylist(Playlist playlist) async {
  // Get a reference to the database.
  final db = await database;

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

Future<void> insertAudio(var audioModel) async {
  final db = await database;

  await db.insert(
    'Audio',
    audioModel.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}
