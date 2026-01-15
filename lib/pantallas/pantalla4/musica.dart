import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../wicss.dart';
import '../../widev.dart';
import '../../wiauth/auth_fb.dart';
import 'player.dart';
import 'favoritos.dart';

class PantallaMusica extends StatefulWidget {
  const PantallaMusica({super.key});
  @override
  State<PantallaMusica> createState() => _PantallaMusicaState();
}

class _PantallaMusicaState extends State<PantallaMusica> {
  final _audio = AudioService();
  List<Cancion> _canciones = [];
  List<Cancion> _favs = [];
  String _q = '';
  bool _search = false;
  bool _loading = true;
  Duration _pos = Duration.zero;
  Duration _dur = Duration.zero;
  bool _play = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // 🚀 PASO 1: Cargar cache instantáneo (como citas.dart)
    final prefs = await SharedPreferences.getInstance();
    final cache = prefs.getString('canciones_cache');
    
    if (cache != null) {
      // CACHE EXISTE: Carga instantánea
      final list = jsonDecode(cache) as List;
      _canciones = list.map((m) => Cancion.fromJson(m)).toList();
      await FavoritosMusicaService.inicializar(_canciones);
      _favs = FavoritosMusicaService.obtenerFavoritosSync(_canciones);
      setState(() => _loading = false);
    } else {
      // PRIMERA VEZ: Cargar desde Firebase
      await _loadFirebase();
    }

    // 🚀 PASO 2: Inicializar player (después de cargar canciones)
    await _initPlayer();
  }

  Future<void> _initPlayer() async {
    if (_canciones.isEmpty) return;

    // Configurar listeners
    _audio.init((c) {
      if (mounted) setState(() {});
    });

    _audio.player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _pos = p);
    });

    _audio.player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _dur = d);
    });

    _audio.player.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _play = s == PlayerState.playing);
    });

    // 🎵 Cargar última canción (como biblia.dart)
    final ultimaId = await AudioService.getUltimaCancion();
    final cancion = ultimaId != null
        ? _canciones.firstWhere((x) => x.id == ultimaId, orElse: () => _canciones.first)
        : _canciones.first;

    await _audio.play(cancion, playlist: _canciones);
    await _audio.player.pause();
  }

  Future<void> _loadFirebase() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('wimusica')
          .orderBy('creado', descending: true)
          .limit(100)
          .get();

      _canciones = snap.docs
          .map((d) => Cancion.fromFirestore(d.data(), d.id))
          .toList();

      await FavoritosMusicaService.inicializar(_canciones);
      _favs = FavoritosMusicaService.obtenerFavoritosSync(_canciones);

      // Guardar en cache (como citas.dart)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'canciones_cache',
        jsonEncode(_canciones.map((c) => c.toJson()).toList()),
      );

      if (mounted) setState(() => _loading = false);
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Cancion> get _filtered {
    if (_q.isEmpty) return _canciones;
    return _canciones.where((c) =>
        c.nombre.toLowerCase().contains(_q.toLowerCase()) ||
        c.cantante.toLowerCase().contains(_q.toLowerCase())).toList();
  }

  Map<String, List<Cancion>> get _tags {
    final map = <String, List<Cancion>>{};
    for (var t in kTags) {
      map[t] = _filtered.where((c) => c.tag == t).toList();
    }
    return map;
  }

  void _fav(Cancion c) {
    FavoritosMusicaService.toggleSync(c);
    setState(() => _favs = FavoritosMusicaService.obtenerFavoritosSync(_canciones));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: AppCSS.verdeClaro,
      body: _loading
          ? _skeleton()
          : RefreshIndicator(
              onRefresh: _loadFirebase,
              color: AppCSS.verdePrimario,
              child: ListView(
                children: [
                  if (_audio.actual != null) _player(),
                  if (_favs.isNotEmpty) _favList(),
                  _list(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: _search
          ? TextField(
              autofocus: true,
              style: const TextStyle(color: AppCSS.blanco),
              decoration: const InputDecoration(
                hintText: 'Buscar...',
                hintStyle: TextStyle(color: AppCSS.blanco),
                border: InputBorder.none,
              ),
              onChanged: (v) => setState(() => _q = v),
            )
          : const Text('🎵 Música'),
      backgroundColor: AppCSS.verdePrimario,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: _search
          ? IconButton(
              icon: const Icon(Icons.close, color: AppCSS.blanco),
              onPressed: () => setState(() {
                _search = false;
                _q = '';
              }),
            )
          : null,
      actions: _search
          ? null
          : [
              IconButton(
                icon: const Icon(Icons.search, color: AppCSS.blanco),
                onPressed: () => setState(() => _search = true),
              ),
            ],
    );
  }

  Widget _skeleton() {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: List.generate(
        6,
        (i) => Container(
          height: 80,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppCSS.blanco.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _player() {
    final c = _audio.actual!;
    final p = _dur.inSeconds > 0 ? _pos.inSeconds / _dur.inSeconds : 0.0;

    return Container(
      height: 100,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppCSS.verdePrimario.withOpacity(0.2),
            AppCSS.verdeSuave.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppCSS.blanco.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: LinearProgressIndicator(
              value: p,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(
                AppCSS.verdePrimario.withOpacity(0.2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.music_note, color: AppCSS.verdePrimario, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(c.nombre, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(c.cantante, style: const TextStyle(fontSize: 12, color: AppCSS.gris), maxLines: 1),
                      Text('${_fmt(_pos)} / ${_fmt(_dur)}', style: const TextStyle(fontSize: 10, color: AppCSS.gris)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(_audio.anterior ? Icons.skip_previous : Icons.skip_previous_outlined, color: _audio.anterior ? AppCSS.verdePrimario : AppCSS.gris, size: 24),
                  onPressed: _audio.anterior ? () async { await _audio.prev(); setState(() {}); } : null,
                ),
                IconButton(
                  icon: Icon(_play ? Icons.pause_circle_filled : Icons.play_circle_filled, color: AppCSS.verdePrimario, size: 40),
                  onPressed: () async { await _audio.toggle(); setState(() {}); },
                ),
                IconButton(
                  icon: Icon(_audio.siguiente ? Icons.skip_next : Icons.skip_next_outlined, color: _audio.siguiente ? AppCSS.verdePrimario : AppCSS.gris, size: 24),
                  onPressed: _audio.siguiente ? () async { await _audio.next(); setState(() {}); } : null,
                ),
                IconButton(
                  icon: Icon(_audio.loop ? Icons.repeat_one : Icons.repeat, color: _audio.loop ? AppCSS.verdePrimario : AppCSS.gris, size: 20),
                  onPressed: () { _audio.toggleLoop(); setState(() {}); },
                ),
                IconButton(
                  icon: Icon(FavoritosMusicaService.esFavoritoSync(c.id) ? Icons.favorite : Icons.favorite_border, color: Colors.red, size: 20),
                  onPressed: () => _fav(c),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _favList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              const Icon(Icons.favorite, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              Text('Favoritos (${_favs.length})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: AppCSS.blanco, borderRadius: BorderRadius.circular(12)),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 6),
            itemCount: _favs.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 50),
            itemBuilder: (_, i) => _item(_favs[i]),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _list() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_search)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: const [
                Icon(Icons.library_music, color: AppCSS.verdePrimario, size: 18),
                SizedBox(width: 8),
                Text('Todas', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: AppCSS.blanco, borderRadius: BorderRadius.circular(12)),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 6),
            itemCount: kTags.length,
            itemBuilder: (_, i) {
              final t = kTags[i];
              final cs = _tags[t] ?? [];
              if (cs.isEmpty) return const SizedBox.shrink();

              return ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                childrenPadding: EdgeInsets.zero,
                leading: Icon(_icon(t), color: AppCSS.verdePrimario, size: 20),
                title: Text(_name(t), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text('${cs.length} canciones', style: const TextStyle(fontSize: 11)),
                children: cs.map(_item).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _item(Cancion c) {
    final actual = _audio.actual?.id == c.id;
    final fav = FavoritosMusicaService.esFavoritoSync(c.id);
    final user = AuthServicio.usuarioActual;
    final esPropia = user != null && c.email == user.email;

    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -4),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      leading: Icon(actual ? Icons.graphic_eq : Icons.music_note, color: actual ? AppCSS.verdePrimario : AppCSS.gris, size: 18),
      title: Text(c.nombre, style: TextStyle(fontSize: 13, fontWeight: actual ? FontWeight.bold : FontWeight.normal), maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(c.cantante, style: const TextStyle(fontSize: 11, color: AppCSS.gris), maxLines: 1),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (esPropia) const Icon(Icons.edit, size: 14, color: AppCSS.verdePrimario),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(fav ? Icons.favorite : Icons.favorite_border, color: fav ? Colors.red : AppCSS.gris, size: 16),
            onPressed: () => _fav(c),
          ),
        ],
      ),
      tileColor: actual ? AppCSS.verdeSuave.withOpacity(0.2) : null,
      onTap: () async {
        await _audio.play(c, playlist: _canciones);
        setState(() {});
      },
      onLongPress: esPropia ? () => _edit(c) : null,
    );
  }

  void _edit(Cancion c) async {
    final n = TextEditingController(text: c.nombre);
    final a = TextEditingController(text: c.cantante);

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          height: MediaQuery.of(ctx).size.height * 0.5,
          decoration: const BoxDecoration(
            color: AppCSS.blanco,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Text('✏️ Editar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(controller: n, decoration: const InputDecoration(labelText: 'Nombre *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.music_note))),
                      const SizedBox(height: 16),
                      TextField(controller: a, decoration: const InputDecoration(labelText: 'Cantante *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                                icon: const Icon(Icons.delete),
                                label: const Text('Eliminar'),
                                onPressed: () async {
                                  final confirmar = await showDialog<bool>(
                                    context: ctx,
                                    builder: (_) => AlertDialog(
                                      title: const Text('¿Eliminar?'),
                                      content: const Text('No se puede deshacer'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
                                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sí', style: TextStyle(color: Colors.red))),
                                      ],
                                    ),
                                  );
                                  if (confirmar == true) {
                                    await FirebaseFirestore.instance.collection('wimusica').doc(c.id).delete();
                                    Navigator.pop(ctx, true);
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: AppCSS.verdePrimario, foregroundColor: AppCSS.blanco),
                                icon: const Icon(Icons.save),
                                label: const Text('Guardar'),
                                onPressed: () async {
                                  if (n.text.isEmpty || a.text.isEmpty) return;
                                  await FirebaseFirestore.instance.collection('wimusica').doc(c.id).update({
                                    'nombre': n.text.trim(),
                                    'cantante': a.text.trim(),
                                    'actualizado': FieldValue.serverTimestamp(),
                                  });
                                  Navigator.pop(ctx, true);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (ok == true) {
      await _loadFirebase();
      if (mounted) MensajeHelper.mostrarExito(context, '✅');
    }
  }

  String _fmt(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  IconData _icon(String t) {
    if (t == 'adoracion') return Icons.church;
    if (t == 'alabanza') return Icons.music_note;
    return Icons.self_improvement;
  }

  String _name(String t) {
    if (t == 'adoracion') return 'Adoración';
    if (t == 'alabanza') return 'Alabanza';
    return 'Reflexión';
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }
}