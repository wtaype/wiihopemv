import 'dart:convert';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../wicss.dart';
import '../../wiauth/auth_fb.dart';
import 'player.dart';
import 'favoritos.dart';

class PantallaMusica extends StatefulWidget {
  const PantallaMusica({super.key});
  @override
  State<PantallaMusica> createState() => _PantallaMusicaState();
}

class _PantallaMusicaState extends State<PantallaMusica> with TickerProviderStateMixin {
  final _audio = AudioService();
  List<Cancion> _canciones = [];
  String _q = '';
  bool _search = false;
  bool _loading = true;
  Duration _pos = Duration.zero;
  Duration _dur = Duration.zero;
  bool _play = false;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final cache = prefs.getString('canciones_cache');

    if (cache != null) {
      final list = jsonDecode(cache) as List;
      _canciones = list.map((m) => Cancion.fromJson(m)).toList();
      await FavoritosMusicaService.init(_canciones, AuthServicio.usuarioActual?.email);
      setState(() => _loading = false);
    }

    await _loadFirebase();
    await _initPlayer();
  }

  Future<void> _initPlayer() async {
    if (_canciones.isEmpty) return;

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
      if (mounted) {
        setState(() => _play = s == PlayerState.playing);
        if (s == PlayerState.playing) {
          _waveController.repeat();
        } else {
          _waveController.stop();
        }
      }
    });

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

      _canciones = snap.docs.map((d) => Cancion.fromFirestore(d.data(), d.id)).toList();

      await FavoritosMusicaService.init(_canciones, AuthServicio.usuarioActual?.email);

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

  Future<void> _fav(Cancion c) async {
    final user = AuthServicio.usuarioActual;
    if (user == null) return;
    await FavoritosMusicaService.toggle(c, user.email!);
    setState(() {});
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
                  if (_audio.actual != null) _playerModerno(),
                  if (FavoritosMusicaService.getFavs(_canciones).isNotEmpty) _favList(),
                  _list(),
                  const SizedBox(height: 100),
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

  // 🎨 PLAYER MODERNO ESTILO SPOTIFY
  Widget _playerModerno() {
    final c = _audio.actual!;
    final p = _dur.inSeconds > 0 ? _pos.inSeconds / _dur.inSeconds : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppCSS.verdePrimario.withOpacity(0.8),
            AppCSS.verdeSuave.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppCSS.verdePrimario.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // WAVES ANIMADAS
          SizedBox(
            height: 100,
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (_, __) => CustomPaint(
                painter: _WavePainter(
                  animation: _waveController.value,
                  isPlaying: _play,
                ),
                size: const Size(double.infinity, 100),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // INFO CANCIÓN
          Text(
            c.nombre,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppCSS.blanco,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            c.cantante,
            style: TextStyle(
              fontSize: 14,
              color: AppCSS.blanco.withOpacity(0.7),
            ),
            maxLines: 1,
          ),
          const SizedBox(height: 20),
          // BARRA PROGRESO
          SliderTheme(
            data: SliderThemeData(
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              trackHeight: 4,
              activeTrackColor: AppCSS.blanco,
              inactiveTrackColor: AppCSS.blanco.withOpacity(0.3),
              thumbColor: AppCSS.blanco,
            ),
            child: Slider(
              value: p,
              onChanged: (v) async {
                final newPos = Duration(seconds: (v * _dur.inSeconds).toInt());
                await _audio.player.seek(newPos);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_fmt(_pos), style: TextStyle(color: AppCSS.blanco.withOpacity(0.7), fontSize: 12)),
              Text(_fmt(_dur), style: TextStyle(color: AppCSS.blanco.withOpacity(0.7), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          // CONTROLES
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  FavoritosMusicaService.isFav(c.id) ? Icons.favorite : Icons.favorite_border,
                  color: AppCSS.blanco,
                  size: 28,
                ),
                onPressed: () => _fav(c),
              ),
              IconButton(
                icon: Icon(
                  Icons.skip_previous,
                  color: _audio.anterior ? AppCSS.blanco : AppCSS.blanco.withOpacity(0.3),
                  size: 36,
                ),
                onPressed: _audio.anterior ? () async { await _audio.prev(); setState(() {}); } : null,
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppCSS.blanco,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    _play ? Icons.pause : Icons.play_arrow,
                    color: AppCSS.verdePrimario,
                    size: 40,
                  ),
                  onPressed: () async { await _audio.toggle(); setState(() {}); },
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.skip_next,
                  color: _audio.siguiente ? AppCSS.blanco : AppCSS.blanco.withOpacity(0.3),
                  size: 36,
                ),
                onPressed: _audio.siguiente ? () async { await _audio.next(); setState(() {}); } : null,
              ),
              IconButton(
                icon: Icon(
                  _audio.loop ? Icons.repeat_one : Icons.repeat,
                  color: _audio.loop ? AppCSS.blanco : AppCSS.blanco.withOpacity(0.5),
                  size: 28,
                ),
                onPressed: () { _audio.toggleLoop(); setState(() {}); },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _favList() {
    final favs = FavoritosMusicaService.getFavs(_canciones);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              const Icon(Icons.favorite, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              Text('Favoritos (${favs.length})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
            itemCount: favs.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 50),
            itemBuilder: (_, i) => _item(favs[i]),
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
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
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
    final fav = FavoritosMusicaService.isFav(c.id);

    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -4),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      leading: Icon(actual ? Icons.graphic_eq : Icons.music_note, color: actual ? AppCSS.verdePrimario : AppCSS.gris, size: 18),
      title: Text(c.nombre, style: TextStyle(fontSize: 13, fontWeight: actual ? FontWeight.bold : FontWeight.normal), maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(c.cantante, style: const TextStyle(fontSize: 11, color: AppCSS.gris), maxLines: 1),
      trailing: IconButton(
        icon: Icon(fav ? Icons.favorite : Icons.favorite_border, color: fav ? Colors.red : AppCSS.gris, size: 16),
        onPressed: () => _fav(c),
      ),
      tileColor: actual ? AppCSS.verdeSuave.withOpacity(0.2) : null,
      onTap: () async {
        await _audio.play(c, playlist: _canciones);
        setState(() {});
      },
    );
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
    // ❌ NO llamar _audio.dispose() - mantener audio activo
    _waveController.dispose();
    super.dispose();
  }
}

// 🎨 PAINTER PARA WAVES ANIMADAS
class _WavePainter extends CustomPainter {
  final double animation;
  final bool isPlaying;

  _WavePainter({required this.animation, required this.isPlaying});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppCSS.blanco.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = isPlaying ? 20.0 : 5.0;
    final waveCount = 3;

    for (var i = 0; i < waveCount; i++) {
      path.reset();
      final offset = (animation + i / waveCount) * 2 * math.pi;

      path.moveTo(0, size.height / 2);

      for (var x = 0.0; x <= size.width; x++) {
        final y = size.height / 2 +
            math.sin((x / size.width) * 4 * math.pi + offset) * waveHeight;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      canvas.drawPath(path, paint);
      paint.color = paint.color.withOpacity(paint.color.opacity * 0.7);
    }
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => true;
}