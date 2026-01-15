import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../wicss.dart';
import '../../widev.dart';
import 'biblia.dart';
import 'favoritos.dart';

class PantallaAudio extends StatefulWidget {
  const PantallaAudio({super.key});
  @override
  State<PantallaAudio> createState() => _PantallaAudioState();
}

class _PantallaAudioState extends State<PantallaAudio> {
  final _player = AudioPlayer();
  List<AudioLibro> _libros = [];
  AudioLibro? _libroActual;
  int _capituloActual = 0;
  bool _buscadorExpandido = false;
  String _query = '';
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _libros = BibliaData.cargarLibros();
    await FavoritosBibliaService.inicializar();
    await _cargarEstado();

    // 🔥 AUTO-NEXT cuando termina
    _player.onPlayerComplete.listen((_) {
      if (_libroActual != null && _capituloActual < _libroActual!.capitulos - 1) {
        _reproducir(_libroActual!, _capituloActual + 1);
      }
    });

    // 🚀 Stream de posición
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });

    // 🚀 Stream de duración
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });

    // 🚀 Stream de estado
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });
  }

  Future<void> _cargarEstado() async {
    final prefs = await SharedPreferences.getInstance();
    final libroId = prefs.getInt('libro_actual') ?? 1;
    final capId = prefs.getInt('capitulo_actual') ?? 0;
    final libro = _libros.firstWhere((l) => l.id == libroId, orElse: () => _libros[0]);
    await _reproducir(libro, capId, autoPlay: false);
  }

  Future<void> _guardarEstado() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('libro_actual', _libroActual?.id ?? 1);
    await prefs.setInt('capitulo_actual', _capituloActual);
  }

  Future<void> _reproducir(AudioLibro libro, int cap, {bool autoPlay = true}) async {
    setState(() {
      _libroActual = libro;
      _capituloActual = cap;
    });

    try {
      await _player.stop();
      await _player.play(UrlSource(libro.getUrl(cap)));
      if (!autoPlay) await _player.pause();
      await _guardarEstado();
    } catch (e) {
      if (mounted) MensajeHelper.mostrarError(context, 'Error al reproducir');
    }
  }

  void _togglePlay() => _isPlaying ? _player.pause() : _player.resume();
  
  void _anterior() {
    if (_capituloActual > 0) _reproducir(_libroActual!, _capituloActual - 1);
  }

  void _siguiente() {
    if (_libroActual != null && _capituloActual < _libroActual!.capitulos - 1) {
      _reproducir(_libroActual!, _capituloActual + 1);
    }
  }

  void _toggleFavorito() {
    if (_libroActual == null) return;
    FavoritosBibliaService.toggleFavoritoSync(_libroActual!.nombre, _capituloActual);
    setState(() {});
  }

  bool _esFavorito(String libro, int cap) => FavoritosBibliaService.esFavoritoSync(libro, cap);

  List<AudioLibro> get _librosFiltrados => _query.isEmpty
      ? _libros
      : _libros.where((l) => l.nombre.toLowerCase().contains(_query.toLowerCase())).toList();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: _buscadorExpandido
              ? TextField(
                  autofocus: true,
                  style: const TextStyle(color: AppCSS.blanco),
                  decoration: const InputDecoration(
                    hintText: 'Buscar libro...',
                    hintStyle: TextStyle(color: AppCSS.blanco),
                    border: InputBorder.none,
                  ),
                  onChanged: (v) => setState(() => _query = v),
                )
              : const Text('📖 Biblia Audio'),
          backgroundColor: AppCSS.verdePrimario,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: _buscadorExpandido
              ? IconButton(
                  icon: const Icon(Icons.close, color: AppCSS.blanco),
                  onPressed: () => setState(() {
                    _buscadorExpandido = false;
                    _query = '';
                  }),
                )
              : null,
          actions: _buscadorExpandido
              ? null
              : [
                  IconButton(
                    icon: const Icon(Icons.search, color: AppCSS.blanco),
                    onPressed: () => setState(() => _buscadorExpandido = true),
                  ),
                ],
        ),
        backgroundColor: AppCSS.verdeClaro,
        body: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: Column(
              children: [
                _buildPlayer(constraints),
                if (!_buscadorExpandido) _buildFavoritos(),
                _buildListaLibros(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );

  Widget _buildPlayer(BoxConstraints constraints) {
    final maxHeight = (constraints.maxHeight * 1.0).clamp(1.0, 300.0);
    return Container(
      height: maxHeight,
      margin: const EdgeInsets.all(1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(1),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppCSS.verdePrimario.withOpacity(0.2),
                  AppCSS.verdeSuave.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppCSS.blanco.withOpacity(0.3), width: 1.5),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/jesus.webp',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppCSS.verdeSuave,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.music_note, size: 42, color: AppCSS.verdePrimario),
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  _libroActual?.nombre ?? 'San Mateo',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppCSS.verdeOscuro,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  'Capítulo ${_capituloActual + 1}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppCSS.verdeOscuro.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 1),
                _buildSlider(),
                const SizedBox(height: 1),
                _buildControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlider() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              activeTrackColor: AppCSS.verdePrimario,
              inactiveTrackColor: AppCSS.verdePrimario.withOpacity(0.2),
              thumbColor: AppCSS.verdePrimario,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),
              max: _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1,
              onChanged: (v) => _player.seek(Duration(seconds: v.toInt())),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_fmt(_position), style: const TextStyle(fontSize: 11, color: AppCSS.verdeOscuro)),
                Text(_fmt(_duration), style: const TextStyle(fontSize: 11, color: AppCSS.verdeOscuro)),
              ],
            ),
          ),
        ],
      );

  Widget _buildControls() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _btn(Icons.skip_previous, _anterior, enabled: _capituloActual > 0),
          const SizedBox(width: 16),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppCSS.verdePrimario,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppCSS.verdePrimario.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 32, color: AppCSS.blanco),
              onPressed: _togglePlay,
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 16),
          _btn(Icons.skip_next, _siguiente,
              enabled: _libroActual != null && _capituloActual < _libroActual!.capitulos - 1),
          const SizedBox(width: 12),
          _btn(
            _libroActual != null && _esFavorito(_libroActual!.nombre, _capituloActual)
                ? Icons.favorite
                : Icons.favorite_border,
            _toggleFavorito,
            color: Colors.red,
          ),
        ],
      );

  Widget _btn(IconData icon, VoidCallback? onPressed, {bool enabled = true, Color? color}) => Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: enabled ? (color ?? AppCSS.verdePrimario).withOpacity(0.15) : AppCSS.gris.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled ? (color ?? AppCSS.verdePrimario).withOpacity(0.3) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: IconButton(
          icon: Icon(icon, color: enabled ? (color ?? AppCSS.verdePrimario) : AppCSS.gris, size: 22),
          onPressed: enabled ? onPressed : null,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      );

  Widget _buildFavoritos() {
    final favs = FavoritosBibliaService.obtenerFavoritosSync();
    if (favs.isEmpty) return const SizedBox.shrink();

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
            itemBuilder: (_, i) => _buildCapItem(
              favs[i]['libro'],
              favs[i]['capitulo'],
              showFav: true,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildListaLibros() {
    final libros = _librosFiltrados;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_buscadorExpandido)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.library_books, color: AppCSS.verdePrimario, size: 18),
                const SizedBox(width: 8),
                const Text('Todos los Libros', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
            itemCount: libros.length,
            itemBuilder: (_, i) {
              final libro = libros[i];
              final isActual = _libroActual?.id == libro.id;

              return ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                childrenPadding: EdgeInsets.zero,
                leading: Icon(
                  isActual ? Icons.menu_book : Icons.menu_book_outlined,
                  color: isActual ? AppCSS.verdePrimario : AppCSS.gris,
                  size: 20,
                ),
                title: Text(libro.nombre,
                    style: TextStyle(fontSize: 14, fontWeight: isActual ? FontWeight.bold : FontWeight.normal)),
                subtitle: Text('${libro.capitulos} capítulos', style: const TextStyle(fontSize: 11)),
                children: List.generate(
                  libro.capitulos,
                  (cap) => _buildCapItem(libro.nombre, cap),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCapItem(String libroNombre, int cap, {bool showFav = false}) {
    final libro = _libros.firstWhere((l) => l.nombre == libroNombre);
    final isActual = _libroActual?.nombre == libroNombre && _capituloActual == cap;
    final esFav = _esFavorito(libroNombre, cap);

    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -4),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      leading: Icon(
        isActual ? Icons.graphic_eq : Icons.play_circle_outline,
        color: isActual ? AppCSS.verdePrimario : AppCSS.gris,
        size: 18,
      ),
      title: Text(
        showFav ? '$libroNombre ${cap + 1}' : 'Capítulo ${cap + 1}',
        style: TextStyle(fontSize: 13, fontWeight: isActual ? FontWeight.bold : FontWeight.normal),
      ),
      trailing: IconButton(
        icon: Icon(esFav ? Icons.favorite : Icons.favorite_border, color: esFav ? Colors.red : AppCSS.gris, size: 16),
        onPressed: () {
          FavoritosBibliaService.toggleFavoritoSync(libroNombre, cap);
          setState(() {});
        },
      ),
      tileColor: isActual ? AppCSS.verdeSuave.withOpacity(0.2) : null,
      onTap: () => _reproducir(libro, cap),
    );
  }

  String _fmt(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}