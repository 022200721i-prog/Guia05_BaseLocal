//Intalar: flutter pub add sqflite path
// Importa las bibliotecas necesarias de Flutter y los archivos locales del proyecto
import 'package:flutter/material.dart';
import 'package:actividad_01/database_helper.dart'; // Clase para gestionar la base de datos SQLite
import 'libros.dart'; // Modelo de datos "Libro"

// Punto de entrada principal de la aplicación
void main() {
  runApp(const MyApp()); // Lanza la app con el widget MyApp como raíz
}

// Widget principal que configura la apariencia general de la app
class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Constructor con clave opcional

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo', // Título de la aplicación
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ), // Tema de colores
        useMaterial3: true, // Uso del diseño Material 3
      ),
      home: const MyHomePage(), // Pantalla inicial al ejecutar la app
    );
  }
}

// Widget con estado que representa la pantalla principal
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key}); // Constructor

  @override
  State<MyHomePage> createState() => _MyHomePageState(); // Crea el estado asociado
}

// Estado que maneja la lógica y el UI de la página principal
class _MyHomePageState extends State<MyHomePage> {
  final DatabaseHelper _dbHelper =
      DatabaseHelper(); // Instancia para acceder a la base de datos
  final TextEditingController _EditTituloLibro =
      TextEditingController(); // Controlador del campo de texto
  List<Libro> _items = []; // Lista de libros obtenidos de la base de datos

  @override
  void initState() {
    super.initState();
    _cargarListaLibros(); // Al iniciar la pantalla, se carga la lista de libros desde la base de datos
  }

  // Método para obtener los libros guardados en la base de datos y actualiza el estado
  Future<void> _cargarListaLibros() async {
    final items = await _dbHelper.getItems(); // Consulta todos los libros
    setState(() {
      _items = items; // Actualiza la lista que se muestra en pantalla
    });
  }

  // Método para insertar un nuevo libro en la base de datos
  void _agregarNuevoLibro(String tituloLibro) async {
    final nuevoLibro = Libro(
      tituloLibro: tituloLibro,
    ); // Crea un objeto Libro con el título proporcionado
    await _dbHelper.insertLibro(
      nuevoLibro,
    ); // Inserta el libro en la base de datos
    print("SE AGREGO EL NUEVO LIBRO"); // Mensaje de confirmación en consola
    _cargarListaLibros(); // Recarga la lista para mostrar el nuevo libro
  }

  // Muestra un cuadro de diálogo que permite al usuario ingresar un nuevo título
  void _mostrarVentanaAgregar() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Agregar Título"), // Título del cuadro de diálogo
          content: TextField(
            controller:
                _EditTituloLibro, // Controlador vinculado al campo de texto
            decoration: const InputDecoration(
              hintText: "Ingrese el título",
            ), // Texto de ayuda
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_EditTituloLibro.text.isNotEmpty) {
                  // Verifica que el campo no esté vacío
                  _agregarNuevoLibro(_EditTituloLibro.text); // Agrega el libro
                  Navigator.of(context).pop(); // Cierra el cuadro de diálogo
                }
              },
              child: Text("Agregar"), // Botón para confirmar
            ),
          ],
        );
      },
    );
  }

  // Método para eliminar un libro según su ID
  void _eliminarLibro(int id) async {
    await _dbHelper.eliminar(
      'libros',
      where: 'id = ?',
      whereArgs: [id],
    ); // Elimina el libro de la base de datos
    _cargarListaLibros(); // Actualiza la lista después de eliminar
  }

  // Muestra un cuadro de diálogo para confirmar la eliminación de un libro
  void _mostrarMensajeModificar(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirmar eliminación"), // Título del diálogo
          content: Text(
            "¿Estás seguro de que quieres eliminar este libro?",
          ), // Mensaje de confirmación
          actions: [
            TextButton(
              onPressed: () => Navigator.of(
                context,
              ).pop(), // Cierra el cuadro sin hacer nada
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                _eliminarLibro(id); // Llama a la función para eliminar el libro
                Navigator.of(context).pop(); // Cierra el cuadro de diálogo
              },
              child: Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  // Método para actualizar el título de un libro dado su ID
  void _actualizarLibro(int id, String nuevoTitulo) async {
    await _dbHelper.actualizar(
      'libros', // Nombre de la tabla
      {'tituloLibro': nuevoTitulo}, // Datos a actualizar
      where: 'id = ?', // Condición
      whereArgs: [id], // Argumentos de la condición
    );
    _cargarListaLibros(); // Recarga la lista con los datos actualizados
  }

  // Muestra un diálogo que permite modificar el título de un libro
  void _ventanaEditar(int id, String tituloActual) {
    // Controlador con el valor inicial del título actual
    TextEditingController _tituloController = TextEditingController(
      text: tituloActual,
    );

    // Cuadro de diálogo para editar el título
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Modificar Título del Libro"),
          content: TextField(
            controller: _tituloController, // Controlador con el texto a editar
            decoration: InputDecoration(
              hintText: "Escribe el nuevo título",
            ), // Texto de ayuda
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cancelar edición
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                if (_tituloController.text.isNotEmpty) {
                  // Validación
                  _actualizarLibro(
                    id,
                    _tituloController.text,
                  ); // Actualiza el libro
                  Navigator.of(context).pop(); // Cierra el cuadro de diálogo
                }
              },
              child: Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  // Método que construye la interfaz de usuario
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SqfLite Flutter"), // Título de la app en la parte superior
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primaryContainer, // Color de fondo de la AppBar
      ),
      body: ListView.separated(
        itemCount: _items.length, // Número de elementos a mostrar
        separatorBuilder: (context, index) =>
            Divider(), // Separador entre elementos
        itemBuilder: (context, index) {
          final libro = _items[index]; // Obtiene un libro de la lista
          return ListTile(
            title: Text(libro.tituloLibro), // Muestra el título del libro
            subtitle: Text('ID: ${libro.id}'), // Muestra el ID como subtítulo
            trailing: IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.grey,
              ), // Icono para eliminar
              onPressed: () =>
                  _mostrarMensajeModificar(libro.id!), // Elimina al presionar
            ),
            onTap: () => _ventanaEditar(
              libro.id!,
              libro.tituloLibro,
            ), // Permite editar al tocar el item
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            _mostrarVentanaAgregar, // Abre el diálogo para agregar un nuevo libro
        child: Icon(Icons.add), // Icono del botón flotante
      ),
    );
  }
}
