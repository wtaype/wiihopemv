import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'player.dart';

class FavoritosMusicaService {
  static final _cache = <String, bool>{};

  // Inicializar cache desde lista de canciones
  static Future<void> init(List<Cancion> canciones, String? userEmail) async {
    if (userEmail == null) return;
    _cache.clear();
    for (var c in canciones) {
      _cache[c.id] = c.favorito;
    }
  }

  // Toggle favorito: actualiza Firebase + cache local
  static Future<void> toggle(Cancion c, String userEmail) async {
    final nuevoEstado = !(_cache[c.id] ?? false);
    _cache[c.id] = nuevoEstado;

    // Actualizar en Firebase
    FirebaseFirestore.instance.collection('wimusica').doc(c.id).update({
      'favorito': nuevoEstado,
    }).catchError((_) {});

    // Guardar en cache local
    final prefs = await SharedPreferences.getInstance();
    final favIds = prefs.getStringList('favoritos_cache') ?? [];
    if (nuevoEstado) {
      if (!favIds.contains(c.id)) favIds.add(c.id);
    } else {
      favIds.remove(c.id);
    }
    await prefs.setStringList('favoritos_cache', favIds);
  }

  static bool isFav(String id) => _cache[id] ?? false;

  static List<Cancion> getFavs(List<Cancion> todas) =>
      todas.where((c) => _cache[c.id] ?? false).toList();
}