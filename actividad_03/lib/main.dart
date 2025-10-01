// Instalar los paquetes necesarios antes de ejecutar:
// flutter pub add sqflite path

// Importa los paquetes principales de Flutter y los archivos locales del proyecto
import 'package:flutter/material.dart';
import 'package:actividad_01/database_helper.dart'; // Clase para manejar la base de datos SQLite
import 'libros.dart'; // Modelo de datos que representa la entidad "Libro"

// Función principal: punto de entrada de la aplicación
void main() {
  runApp(const MyApp()); // Ejecuta la aplicación con el widget raíz MyApp
}

// Widget principal sin estado (StatelessWidget)
// Define el diseño base de la app y configura el tema
class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Constructor con clave opcional

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo', // Título que se muestra en la parte superior
      theme: ThemeData(
        // Configuración de colores usando Material Design 3
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true, // Usa el estilo visual de Material 3
      ),
      home: const MyHomePage(), // Pantalla principal al iniciar la app
    );
  }
}

// Widget con estado (StatefulWidget) que representa la pantalla principal de la app
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Clase que maneja el estado, la lógica y la interfaz de la pantalla principal
class _MyHomePageState extends State<MyHomePage> {
  final DatabaseHelper _dbHelper =
      DatabaseHelper(); // Instancia para interactuar con la base de datos
  List<Libro> _items = []; // Lista local de libros obtenidos desde SQLite

  @override
  void initState() {
    super.initState();
    _cargarListaLibros(); // Al iniciar la pantalla, se cargan los libros guardados
  }

  // 🔹 Método para cargar los libros desde la base de datos SQLite
  Future<void> _cargarListaLibros() async {
    final items = await _dbHelper.getItems(); // Obtiene todos los registros de la tabla
    setState(() {
      _items = items; // Actualiza la lista de libros mostrada en pantalla
    });
  }

  // 🔹 Método para insertar un nuevo libro en la base de datos
  void _agregarNuevoLibro(String tituloLibro) async {
    final nuevoLibro = Libro(tituloLibro: tituloLibro); // Crea un nuevo objeto Libro
    await _dbHelper.insertLibro(nuevoLibro); // Inserta el libro en la base de datos
    _cargarListaLibros(); // Recarga la lista actualizada en la interfaz
  }

  // 🔹 Método para eliminar un libro usando su ID
  void _eliminarLibro(int id) async {
    await _dbHelper.eliminar('libros', where: 'id = ?', whereArgs: [id]);
    _cargarListaLibros(); // Recarga la lista después de eliminar
  }

  // 🔹 Muestra un cuadro de confirmación antes de eliminar un libro
  void _mostrarMensajeEliminar(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmar eliminación"), // Título del cuadro
          content: const Text("¿Estás seguro de que quieres eliminar este libro?"), // Mensaje
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cierra sin eliminar
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                _eliminarLibro(id); // Llama al método para eliminar el libro
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  // 🔹 Método para actualizar el título de un libro existente
  void _actualizarLibro(int id, String nuevoTitulo) async {
    await _dbHelper.actualizar(
      'libros', // Nombre de la tabla
      {'tituloLibro': nuevoTitulo}, // Campo a actualizar
      where: 'id = ?', // Condición para encontrar el libro
      whereArgs: [id], // Argumento de la condición
    );
    _cargarListaLibros(); // Recarga la lista actualizada
  }

  // 🔹 Cuadro de diálogo para editar un libro existente (modificar título)
  void _ventanaEditar(int id, String tituloActual) {
    // Controlador para manejar el texto en el campo de edición
    TextEditingController _tituloController = TextEditingController(text: tituloActual);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Modificar Título del Libro"),
          content: TextField(
            controller: _tituloController, // Campo con el texto actual
            decoration: const InputDecoration(hintText: "Escribe el nuevo título"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cierra sin cambios
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                // Solo actualiza si el campo no está vacío
                if (_tituloController.text.isNotEmpty) {
                  _actualizarLibro(id, _tituloController.text); // Actualiza el libro
                  Navigator.of(context).pop(); // Cierra el cuadro
                }
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  // 🔹 Método para abrir el formulario que agrega un nuevo libro
  // Reemplaza al antiguo showDialog de agregar
  void _abrirFormularioAgregar() async {
    // Navega a la nueva pantalla del formulario
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioLibroPage(), // Abre la clase del formulario
      ),
    );

    // Si se recibe un resultado válido (no vacío), se agrega el libro
    if (resultado != null && resultado is String && resultado.isNotEmpty) {
      _agregarNuevoLibro(resultado);
    }
  }

  // 🔹 Construye la interfaz principal de la pantalla
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SqfLite Flutter"), // Título de la aplicación
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      // Muestra la lista de libros usando ListView.separated
      body: ListView.separated(
        itemCount: _items.length, // Número total de libros
        separatorBuilder: (context, index) => const Divider(), // Línea entre elementos
        itemBuilder: (context, index) {
          final libro = _items[index]; // Obtiene un libro específico
          return ListTile(
            title: Text(libro.tituloLibro), // Muestra el título
            subtitle: Text('ID: ${libro.id}'), // Muestra el ID como subtítulo
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.grey), // Botón eliminar
              onPressed: () => _mostrarMensajeEliminar(libro.id!), // Elimina el libro
            ),
            onTap: () => _ventanaEditar(libro.id!, libro.tituloLibro), // Edita al tocar
          );
        },
      ),
      // Botón flotante para abrir el formulario
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirFormularioAgregar, // Llama al método que abre el formulario
        child: const Icon(Icons.add), // Icono de "+"
      ),
    );
  }
}

// 🧾 NUEVA PANTALLA: Formulario para agregar un nuevo libro
class FormularioLibroPage extends StatefulWidget {
  @override
  _FormularioLibroPageState createState() => _FormularioLibroPageState();
}

class _FormularioLibroPageState extends State<FormularioLibroPage> {
  final _formKey =
      GlobalKey<FormState>(); // Clave para validar el formulario correctamente
  final TextEditingController _tituloController =
      TextEditingController(); // Controlador del campo de texto

  // 🔹 Método que valida y guarda el libro
  void _guardarLibro() {
    // Si el formulario es válido (no vacío), devuelve el texto a la pantalla anterior
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context,
          _tituloController.text.trim()); // Devuelve el título al MyHomePage
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("Agregar nuevo libro")), // Título del formulario
      body: Padding(
        padding: const EdgeInsets.all(20), // Espaciado interior
        child: Form(
          key: _formKey, // Asigna la clave al formulario
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ingrese el título del libro:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Campo de texto con validación
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: "Título del libro",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book), // Icono de libro
                ),
                validator: (value) {
                  // Validación para evitar campos vacíos
                  if (value == null || value.trim().isEmpty) {
                    return "Por favor, ingrese un título válido";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Botón centrado para guardar el libro
              Center(
                child: ElevatedButton.icon(
                  onPressed: _guardarLibro, // Guarda el libro al presionar
                  icon: const Icon(Icons.save), // Icono de guardar
                  label: const Text("Guardar"), // Texto del botón
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
