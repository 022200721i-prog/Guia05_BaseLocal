// Definición de la clase Libro, que representa el modelo de datos para la base de datos
class Libro {
  // Atributo 'id' de tipo entero. Es opcional porque lo asigna automáticamente la base de datos al insertar.
  int? id;

  // Atributo 'tituloLibro' de tipo String. Es obligatorio y representa el título del libro.
  String tituloLibro;

  // Constructor de la clase 'Libro'.
  // - 'id' es opcional porque se genera automáticamente por SQLite.
  // - 'tituloLibro' es requerido porque siempre debe tener un valor.
  Libro({this.id, required this.tituloLibro});

  // Método que convierte un objeto Libro en un Map<String, dynamic>,
  // que es el formato necesario para insertar o actualizar datos en SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id':
          id, // Clave 'id' con su valor correspondiente (puede ser null si es un nuevo libro)
      'tituloLibro': tituloLibro, // Clave 'tituloLibro' con el valor del título
    };
  }

  // Método estático opcional para crear un objeto Libro desde un mapa (por ejemplo, desde una fila de la base de datos)
  // Esto no estaba en tu código original, pero es útil al leer los datos de SQLite.
  factory Libro.fromMap(Map<String, dynamic> map) {
    return Libro(
      id: map['id'], // Asigna el valor del campo 'id' del mapa
      tituloLibro:
          map['tituloLibro'], // Asigna el valor del campo 'tituloLibro' del mapa
    );
  }
}
