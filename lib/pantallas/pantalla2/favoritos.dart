import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritosBibliaService {
  static const _key = 'favoritos_biblia';
  static Set<String> _cache = {};
  static bool _cacheIniciado = false;

  // 🚀 Inicializar cache en memoria (llamar al inicio)
  static Future<void> inicializar() async {
    if (_cacheIniciado) return;
    final prefs = await SharedPreferences.getInstance();
    _cache = (prefs.getStringList(_key) ?? []).toSet();
    _cacheIniciado = true;
  }

  // 💚 Toggle favorito (SYNC - sin await)
  static void toggleFavoritoSync(String libro, int cap) {
    final id = _id(libro, cap);
    _cache.contains(id) ? _cache.remove(id) : _cache.add(id);
    _guardarAsync(); // Guarda en background
  }

  // 📋 Obtener favoritos (SYNC - instantáneo)
  static List<Map<String, dynamic>> obtenerFavoritosSync() {
    return _cache.map((id) {
      final parts = id.split('|');
      return {
        'libro': parts[0],
        'capitulo': int.parse(parts[1]),
      };
    }).toList();
  }

  // 🔍 Verificar si es favorito (SYNC)
  static bool esFavoritoSync(String libro, int cap) => _cache.contains(_id(libro, cap));

  // 💾 Guardar en background (sin bloquear UI)
  static void _guardarAsync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _cache.toList());
  }

  static String _id(String libro, int cap) => '$libro|$cap';
}