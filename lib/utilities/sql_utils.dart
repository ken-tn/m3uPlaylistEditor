// Define a function that inserts dogs into the database
import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:m3u_playlist/models/playlist_model.dart';
import 'package:m3u_playlist/models/audio_model.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

const databaseVersion = 6;
const databaseName = 'm3u_playlist_data.db';

Future<Database> connectToDatabase() async {
  return openDatabase(
    join(await getDatabasesPath(), databaseName),
    version: databaseVersion,
  );
}

Future<Database> loadDatabase() async {
  final db = await openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'm3u_playlist_data.db'),
    // When the database is first created, create a table to store the models.
    onCreate: (db, version) {
      logger.d("Database: Creating database.");
      // Run the CREATE TABLE statement on the database.
      db.execute(
        'CREATE TABLE IF NOT EXISTS Playlist(path VARCHAR PRIMARY KEY);',
      );
      db.execute(
        'CREATE TABLE IF NOT EXISTS Audio(path VARCHAR PRIMARY KEY, filetype VARCHAR, tags VARCHAR);',
      );
    },

    onUpgrade: (db, oldVersion, newVersion) {
      logger.d("Database: Updating database from $oldVersion to $newVersion.");
      db.execute(
        'DROP TABLE Playlist',
      );
      db.execute(
        'DROP TABLE Audio',
      );
      logger.d("Database: Dropped tables.");

      db.execute(
        'CREATE TABLE IF NOT EXISTS Playlist(path VARCHAR PRIMARY KEY);',
      );
      db.execute(
        'CREATE TABLE IF NOT EXISTS Audio(path VARCHAR PRIMARY KEY, filetype VARCHAR, tags VARCHAR);',
      );
      logger.d("Database: Created new tables.");
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: databaseVersion,
  );

  return db;
}

Future<List> findAudio(String path) async {
  Database db = await connectToDatabase();
  List result = await db.query(
    'Audio',
    columns: ['path', 'filetype', 'tags'],
    where: 'path = ?',
    whereArgs: [path],
  );

  logger.d('Query complete: findAudio($path)');
  return result;
}

Future<void> insertPlaylist(Playlist playlist) async {
  // Insert the Playlist into the correct table. You might also specify the
  // `conflictAlgorithm` to use in case the same Playlist is inserted twice.
  //
  // In this case, replace any previous data.
  Database db = await connectToDatabase();
  db.insert(
    'Playlist',
    playlist.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<void> insertAudio(Audio audio) async {
  Database db = await connectToDatabase();
  db.insert(
    'Audio',
    audio.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}
