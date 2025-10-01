// Importa la clase Libro desde el archivo libros.dart
import 'package:actividad_01/libros.dart';
// Importa las librerías necesarias para trabajar con bases de datos SQLite
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Clase helper para gestionar la base de datos SQLite
class DatabaseHelper {
  // Instancia estática única del DatabaseHelper (Singleton Pattern)
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  // Factory constructor que retorna la instancia única
  factory DatabaseHelper() => _instance;

  // Variable privada que contiene la base de datos
  static Database? _database;

  // Constructor privado para evitar la creación de instancias fuera de la clase
  DatabaseHelper._internal();

  // Getter para obtener la base de datos, si ya existe la retorna, si no la inicializa
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Método privado para inicializar la base de datos
  Future<Database> _initDatabase() async {
    // Obtiene la ruta donde se guardará la base de datos
    String path = join(await getDatabasesPath(), 'bdlibros.db');

    // Crea o abre la base de datos con la ruta especificada
    return await openDatabase(
      path,
      onCreate: (db, version) {
        // Crea la tabla 'libros' con las columnas id y tituloLibro
        return db.execute(
          "CREATE TABLE libros (id INTEGER PRIMARY KEY AUTOINCREMENT, tituloLibro TEXT)",
        );
      },
      version: 1, // Versión de la base de datos
    );
  }

  // Método para insertar un libro en la base de datos
  Future<void> insertLibro(Libro item) async {
    final db = await database; // Obtiene la instancia de la base de datos
    // Inserta el libro usando el mapa generado desde el objeto Libro
    await db.insert(
      'libros', // Nombre de la tabla
      item.toMap(), // Datos a insertar, convertidos a mapa
      conflictAlgorithm:
          ConflictAlgorithm.replace, // En caso de conflicto, reemplaza
    );
  }

  // Método para obtener todos los libros de la base de datos
  Future<List<Libro>> getItems() async {
    final db = await database; // Obtiene la instancia de la base de datos
    final List<Map<String, dynamic>> maps = await db.query(
      'libros',
    ); // Realiza la consulta a la tabla 'libros'

    // Convierte los resultados en una lista de objetos Libro
    return List.generate(maps.length, (i) {
      return Libro(
        id: maps[i]['id'], // Obtiene el id del libro
        tituloLibro: maps[i]['tituloLibro'], // Obtiene el título del libro
      );
    });
  }

  // Método para eliminar un registro de una tabla específica
  Future<int> eliminar(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db =
        await _initDatabase(); // Obtiene la instancia de la base de datos
    // Elimina el registro según la condición especificada
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  // Método para actualizar un registro en una tabla específica
  Future<int> actualizar(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db =
        await _initDatabase(); // Obtiene la instancia de la base de datos
    // Actualiza el registro según las condiciones especificadas
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }
}
