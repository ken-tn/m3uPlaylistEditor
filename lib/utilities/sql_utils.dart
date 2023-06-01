// Define a function that inserts dogs into the database
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:m3u_playlist/models/playlist_model.dart';
import 'package:m3u_playlist/models/audio_model.dart';

import 'log.dart';

const String databaseName = 'm3u_playlist_data.db';
const int databaseVersion = 8;

Future<Database> connectToDatabase() async {
  return openDatabase(
    join(await getDatabasesPath(), databaseName),
    version: databaseVersion,
  );
}

Future<Database> loadDatabase() async {
  const String createPlaylistsSql =
      'CREATE TABLE IF NOT EXISTS Playlist(path VARCHAR PRIMARY KEY);';
  const String createAudioSql =
      'CREATE TABLE IF NOT EXISTS Audio(path VARCHAR PRIMARY KEY, filetype VARCHAR, tags VARCHAR);';
  const String createDeletedSql =
      'CREATE TABLE IF NOT EXISTS Deleted(id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR, data VARCHAR)';
  final db = await openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'm3u_playlist_data.db'),
    // When the database is first created, create a table to store the models.
    onCreate: (db, version) {
      logger.d("Database: Creating database.");
      // Run the CREATE TABLE statement on the database.
      db.execute(createPlaylistsSql);
      db.execute(createAudioSql);
      db.execute(createDeletedSql);
    },

    onUpgrade: (db, oldVersion, newVersion) async {
      logger.d("Database: Updating database from $oldVersion to $newVersion.");
      Future f1 = db.execute(
        'DROP TABLE Playlist',
      );
      Future f2 = db.execute(
        'DROP TABLE Audio',
      );
      // Keep deleted table
      await Future.wait([f1, f2]);
      logger.d("Database: Dropped tables.");

      db.execute(createPlaylistsSql);
      db.execute(createAudioSql);
      db.execute(createDeletedSql);
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

  return result;
}

Future<int> insertPlaylist(Playlist playlist) async {
  // Insert the Playlist into the correct table. You might also specify the
  // `conflictAlgorithm` to use in case the same Playlist is inserted twice.
  //
  // In this case, replace any previous data.
  Database db = await connectToDatabase();
  return await db.insert(
    'Playlist',
    playlist.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<int> insertAudio(Audio audio) async {
  Database db = await connectToDatabase();
  return await db.insert(
    'Audio',
    audio.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<int> insertDeleted(String name, String fileContent) async {
  Database db = await connectToDatabase();
  return await db.insert(
    'Deleted',
    {'name': name, 'data': fileContent},
  );
}
