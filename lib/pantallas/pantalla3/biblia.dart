// 📚 MODELO DE LIBRO
class AudioLibro {
  final int id;
  final String nombre;
  final int capitulos;
  final String urlBase;
  final String nombreArchivo;
  final int trackInicio;

  AudioLibro({
    required this.id,
    required this.nombre,
    required this.capitulos,
    required this.urlBase,
    required this.nombreArchivo,
    required this.trackInicio,
  });

  String getUrl(int capitulo) {
    final trackNum = trackInicio + capitulo;
    final capStr = (capitulo + 1).toString().padLeft(2, '0');
    return '$urlBase/${trackNum}_${nombreArchivo}_$capStr.mp3';
  }
}

// 📚 DATOS DE LIBROS
class BibliaData {
  static List<AudioLibro> cargarLibros() {
    const baseUrl = 'https://raw.githubusercontent.com/geluksee/hope/main';
    const librosData = {
      'San Mateo': 28,
      'San Marcos': 16,
      'San Lucas': 24,
      'San Juan': 21,
      'Hechos': 28,
      'Romanos': 16,
      '1 Corintios': 16,
      '2 Corintios': 13,
      'Galatas': 6,
      'Efesios': 6,
      'Filipenses': 4,
      'Colosenses': 4,
      '1 Tesalonicenses': 5,
      '2 Tesalonicenses': 3,
      '1 Timoteo': 6,
      '2 Timoteo': 4,
      'Tito': 3,
      'Filemon': 1,
      'Hebreos': 13,
      'Santiago': 5,
      '1 San Pedro': 5,
      '2 San Pedro': 3,
      '1 San Juan': 5,
      '2 San Juan': 1,
      '3 San Juan': 1,
      'Judas': 1,
      'Apocalipsis': 22,
    };

    List<AudioLibro> libros = [];
    int trackId = 1;

    librosData.forEach((nombre, caps) {
      libros.add(
        AudioLibro(
          id: trackId,
          nombre: nombre,
          capitulos: caps,
          urlBase: baseUrl,
          nombreArchivo: nombre.replaceAll(' ', '_'),
          trackInicio: trackId,
        ),
      );
      trackId += caps;
    });

    return libros;
  }
}
