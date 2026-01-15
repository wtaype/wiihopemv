import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cancion {
  final String id, url, nombre, cantante, tag, usuario, email;
  bool favorito;
  final dynamic creado, actualizado;

  Cancion({
    required this.id,
    required this.url,
    required this.nombre,
    required this.cantante,
    this.tag = 'adoracion',
    this.favorito = false,
    required this.usuario,
    required this.email,
    this.creado,
    this.actualizado,
  });

  factory Cancion.fromFirestore(Map<String, dynamic> m, String id) => Cancion(
        id: id,
        url: m['url'] ?? '',
        nombre: m['nombre'] ?? '',
        cantante: m['cantante'] ?? '',
        tag: m['tag'] ?? 'adoracion',
        favorito: m['favorito'] ?? false,
        usuario: m['usuario'] ?? '',
        email: m['email'] ?? '',
        creado: m['creado'],
        actualizado: m['actualizado'],
      );

  factory Cancion.fromJson(Map<String, dynamic> m) => Cancion(
        id: m['id'],
        url: m['url'],
        nombre: m['nombre'],
        cantante: m['cantante'],
        tag: m['tag'],
        favorito: m['favorito'],
        usuario: m['usuario'],
        email: m['email'],
        creado: m['creado'],
        actualizado: m['actualizado'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'nombre': nombre,
        'cantante': cantante,
        'tag': tag,
        'favorito': favorito,
        'usuario': usuario,
        'email': email,
        'creado': creado,
        'actualizado': actualizado,
      };
}

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  List<Cancion> _playlist = [];
  int _indice = 0;
  bool _loop = false;
  Function(Cancion?)? _onChange;

  AudioPlayer get player => _player;
  Cancion? get actual => _playlist.isEmpty ? null : _playlist[_indice];
  bool get anterior => _indice > 0;
  bool get siguiente => _indice < _playlist.length - 1;
  bool get loop => _loop;

  void init(Function(Cancion?) onChange) {
    _onChange = onChange;
    _player.onPlayerComplete.listen((_) async {
      if (_loop && actual != null) {
        await play(actual!);
      } else if (siguiente) {
        await next();
      }
    });
  }

  Future<void> play(Cancion c, {List<Cancion>? playlist}) async {
    try {
      if (playlist != null) {
        _playlist = playlist;
        _indice = playlist.indexWhere((x) => x.id == c.id);
        if (_indice == -1) _indice = 0;
      }
      await _player.stop();
      await _player.play(UrlSource(c.url));
      await _guardarEstado();
      _onChange?.call(actual);
    } catch (e) {
      print('Error play: $e');
    }
  }

  Future<void> toggle() async {
    if (_player.state == PlayerState.playing) {
      await _player.pause();
    } else {
      await _player.resume();
    }
  }

  Future<void> next() async {
    if (siguiente) {
      _indice++;
      await play(_playlist[_indice]);
    }
  }

  Future<void> prev() async {
    if (anterior) {
      _indice--;
      await play(_playlist[_indice]);
    }
  }

  void toggleLoop() {
    _loop = !_loop;
    _onChange?.call(actual);
  }

  Future<void> _guardarEstado() async {
    if (actual == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ultima_cancion_id', actual!.id);
  }

  static Future<String?> getUltimaCancion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('ultima_cancion_id');
  }

  void dispose() => _player.dispose();
}

const kTags = ['adoracion', 'alabanza', 'reflexion'];