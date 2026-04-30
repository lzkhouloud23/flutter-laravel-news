import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/article.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'favorites.db');

    return await openDatabase(
      path,
      version: 2, // Changed from 1 to 2 to trigger an update if needed
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorites (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            content TEXT,
            category TEXT,
            image_url TEXT,
            published_at TEXT,
            personal_note TEXT  -- New column added here
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db
              .execute('ALTER TABLE favorites ADD COLUMN personal_note TEXT');
        }
      },
    );
  }

  // CREATE - Add article to favorites
  Future<void> insertArticle(Article article) async {
    final db = await database;
    await db.insert(
      'favorites',
      article.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ - Get all favorite articles
  Future<List<Article>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');
    return List.generate(maps.length, (i) => Article.fromMap(maps[i]));
  }

  // UPDATE - Update an article (including the note!)
  Future<void> updateArticle(Article article) async {
    final db = await database;
    await db.update(
      'favorites',
      article.toMap(),
      where: 'id = ?',
      whereArgs: [article.id],
    );
  }

  // DELETE - Remove one article from favorites
  Future<void> deleteArticle(int id) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Check if article is already in favorites
  Future<bool> isFavorite(int id) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }
}
