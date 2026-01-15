import 'package:cloud_firestore/cloud_firestore.dart';
import 'player.dart';

class FavoritosMusicaService {
  static final _cache = <String, bool>{};
  static bool _iniciado = false;

  static Future<void> inicializar(List<Cancion> canciones) async {
    if (_iniciado) return;
    _cache.clear();
    for (var c in canciones) {
      _cache[c.id] = c.favorito;
    }
    _iniciado = true;
  }

  static void toggleSync(Cancion cancion) {
    cancion.favorito = !cancion.favorito;
    _cache[cancion.id] = cancion.favorito;
    _guardarAsync(cancion);
  }

  static bool esFavoritoSync(String id) => _cache[id] ?? false;

  static List<Cancion> obtenerFavoritosSync(List<Cancion> todas) =>
      todas.where((c) => _cache[c.id] ?? false).toList();

  static void _guardarAsync(Cancion c) {
    FirebaseFirestore.instance.collection('wimusica').doc(c.id).update({
      'favorito': c.favorito,
      'actualizado': FieldValue.serverTimestamp(),
    }).catchError((_) {});
  }

  static void limpiar() {
    _cache.clear();
    _iniciado = false;
  }
}