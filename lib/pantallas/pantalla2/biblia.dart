class AudioLibro {
  final int id;
  final String nombre;
  final int capitulos;
  final String urlBase;
  final String nombreArchivo;
  final int trackInicio;

  const AudioLibro({
    required this.id,
    required this.nombre,
    required this.capitulos,
    required this.urlBase,
    required this.nombreArchivo,
    required this.trackInicio,
  });

  String getUrl(int cap) =>
      '$urlBase/${trackInicio + cap}_${nombreArchivo}_${(cap + 1).toString().padLeft(2, '0')}.mp3';
}

class BibliaData {
  static const _baseUrl = 'https://raw.githubusercontent.com/geluksee/hope/main';
  static const _libros = {
    'San Mateo': 28, 'San Marcos': 16, 'San Lucas': 24, 'San Juan': 21,
    'Hechos': 28, 'Romanos': 16, '1 Corintios': 16, '2 Corintios': 13,
    'Galatas': 6, 'Efesios': 6, 'Filipenses': 4, 'Colosenses': 4,
    '1 Tesalonicenses': 5, '2 Tesalonicenses': 3, '1 Timoteo': 6,
    '2 Timoteo': 4, 'Tito': 3, 'Filemon': 1, 'Hebreos': 13,
    'Santiago': 5, '1 San Pedro': 5, '2 San Pedro': 3, '1 San Juan': 5,
    '2 San Juan': 1, '3 San Juan': 1, 'Judas': 1, 'Apocalipsis': 22,
  };

  static List<AudioLibro> cargarLibros() {
    var trackId = 1;
    return _libros.entries.map((e) {
      final libro = AudioLibro(
        id: trackId,
        nombre: e.key,
        capitulos: e.value,
        urlBase: _baseUrl,
        nombreArchivo: e.key.replaceAll(' ', '_'),
        trackInicio: trackId,
      );
      trackId += e.value;
      return libro;
    }).toList();
  }
}