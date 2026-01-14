import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../wicss.dart';
import '../../widev.dart';
import 'biblia.dart';
import 'buscador.dart';
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

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _libros = BibliaData.cargarLibros();
    await FavoritosBibliaService.inicializar();
    await _cargarEstado();
  }

  Future<void> _cargarEstado() async {
    final prefs = await SharedPreferences.getInstance();
    final libroId = prefs.getInt('libro_actual') ?? 1;
    final capId = prefs.getInt('capitulo_actual') ?? 1;
    final libro = _libros.firstWhere((l) => l.id == libroId, orElse: () => _libros[0]);
    await _reproducir(libro, capId - 1, autoPlay: false);
  }

  Future<void> _guardarEstado() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('libro_actual', _libroActual?.id ?? 1);
    await prefs.setInt('capitulo_actual', _capituloActual + 1);
  }

  Future<void> _reproducir(AudioLibro libro, int cap, {bool autoPlay = true}) async {
    setState(() {
      _libroActual = libro;
      _capituloActual = cap;
    });

    try {
      await _player.setUrl(libro.getUrl(cap));
      autoPlay ? await _player.play() : await _player.pause();
      await _guardarEstado();
    } catch (e) {
      if (mounted) MensajeHelper.mostrarError(context, 'Error: $e');
    }
  }

  void _togglePlay() => _player.playing ? _player.pause() : _player.play();
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

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: _buscadorExpandido ? null : AppBar(
      title: const Text('📖 Biblia Audio'),
      backgroundColor: AppCSS.verdePrimario,
      centerTitle: true,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => setState(() => _buscadorExpandido = true),
        ),
      ],
    ),
    backgroundColor: AppCSS.verdeClaro,
    body: _buscadorExpandido
        ? BuscadorBiblia(
            libros: _libros,
            onSeleccionar: _reproducir,
            onCerrar: () => setState(() => _buscadorExpandido = false),
          )
        : LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: Column(
                children: [
                  _buildPlayer(constraints),
                  _buildFavoritos(),
                  _buildListaLibros(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
  );

Widget _buildPlayer(BoxConstraints constraints) {
  final maxHeight = (constraints.maxHeight * 0.4).clamp(260.0, 320.0);
  return Container(
    height: maxHeight,
    margin: const EdgeInsets.all(10),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: AppCSS.glassmorphism,
          padding: const EdgeInsets.all(5),          // ✅ Reducido (20→16)
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'assets/images/jesus.webp',
                  width: 100,                         // ✅ Reducido (120→100)
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppCSS.verdeSuave,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.music_note, size: 42, color: AppCSS.verdePrimario),
                  ),
                ),
              ),
              const SizedBox(height: 0),           // ✅ Reducido (12→10)
              Text(
                _libroActual?.nombre ?? 'San Mateo',
                style: AppEstilos.textoGlass.copyWith(fontSize: 15),  // ✅ Reducido (18→17)
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 0),            // ✅ Nuevo espacio explícito
              Text(
                'Capítulo ${_capituloActual + 1}',
                style: AppEstilos.textoGlassSubtitulo.copyWith(fontSize: 11),  // ✅ Reducido (13→12)
              ),
              const SizedBox(height: 0),            // ✅ Reducido (8→6)
              _buildSlider(),
              const SizedBox(height: 0),            // ✅ Reducido (8→6)
              _buildControls(),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildSlider() => StreamBuilder<Duration>(
    stream: _player.positionStream,
    builder: (_, snap) {
      final pos = snap.data ?? Duration.zero;
      final dur = _player.duration ?? const Duration(seconds: 1);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              activeTrackColor: AppCSS.verdePrimario,
              inactiveTrackColor: AppCSS.verdePrimario.withOpacity(0.3),
              thumbColor: AppCSS.verdePrimario,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: pos.inSeconds.toDouble().clamp(0, dur.inSeconds.toDouble()),
              max: dur.inSeconds.toDouble(),
              onChanged: (v) => _player.seek(Duration(seconds: v.toInt())),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_fmt(pos), style: const TextStyle(fontSize: 11, color: AppCSS.verdeOscuro)),
                Text(_fmt(dur), style: const TextStyle(fontSize: 11, color: AppCSS.verdeOscuro)),
              ],
            ),
          ),
        ],
      );
    },
  );

Widget _buildControls() => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 4), // ✅ Padding para no desbordar
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min, // ✅ Importante: no expandir
    children: [
      _btn(Icons.skip_previous, _anterior, enabled: _capituloActual > 0),
      const SizedBox(width: 12),
      StreamBuilder<bool>(
        stream: _player.playingStream,
        builder: (_, snap) {
          final playing = snap.data ?? false;
          return Container(
            width: 64,                              // ✅ Reducido (72→64)
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
              icon: Icon(
                playing ? Icons.pause : Icons.play_arrow,
                size: 32,                            // ✅ Reducido (36→32)
                color: AppCSS.blanco,
              ),
              onPressed: _togglePlay,
              padding: EdgeInsets.zero,
            ),
          );
        },
      ),
      const SizedBox(width: 12),
      _btn(Icons.skip_next, _siguiente, enabled: _libroActual != null && _capituloActual < _libroActual!.capitulos - 1),
      const SizedBox(width: 10),
      StreamBuilder<LoopMode>(
        stream: _player.loopModeStream,
        builder: (_, snap) {
          final loop = snap.data ?? LoopMode.off;
          return _btn(
            loop == LoopMode.one ? Icons.repeat_one : Icons.repeat,
            () => _player.setLoopMode(loop == LoopMode.one ? LoopMode.off : LoopMode.one),
          );
        },
      ),
      const SizedBox(width: 10),
      _btn(
        _libroActual != null && _esFavorito(_libroActual!.nombre, _capituloActual)
            ? Icons.favorite
            : Icons.favorite_border,
        _toggleFavorito,
        color: Colors.red,
      ),
    ],
  ),
);

Widget _btn(IconData icon, VoidCallback? onPressed, {bool enabled = true, Color? color}) => Container(
  width: 46,                                       // ✅ Reducido (52→46)
  height: 46,
  decoration: BoxDecoration(
    color: enabled
        ? (color ?? AppCSS.verdePrimario).withOpacity(0.15)
        : AppCSS.gris.withOpacity(0.1),
    shape: BoxShape.circle,
    border: Border.all(
      color: enabled
          ? (color ?? AppCSS.verdePrimario).withOpacity(0.3)
          : Colors.transparent,
      width: 1.5,
    ),
  ),
  child: IconButton(
    icon: Icon(
      icon,
      color: enabled ? (color ?? AppCSS.verdePrimario) : AppCSS.gris,
      size: 22,                                    // ✅ Reducido (26→22)
    ),
    onPressed: enabled ? onPressed : null,
    padding: EdgeInsets.zero,
    constraints: const BoxConstraints(),           // ✅ Sin constraints extra
  ),
);

  Widget _buildFavoritos() {
    final favs = FavoritosBibliaService.obtenerFavoritosSync();
    if (favs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.favorite, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              Text('Favoritos (${favs.length})', style: AppEstilos.subtitulo.copyWith(fontSize: 15)),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 6),
            itemCount: favs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final fav = favs[i];
              final libro = _libros.firstWhere((l) => l.nombre == fav['libro'], orElse: () => _libros[0]);
              final cap = fav['capitulo'] as int;
              final isActual = _libroActual?.nombre == fav['libro'] && _capituloActual == cap;

              return ListTile(
                dense: true,
                visualDensity: const VisualDensity(vertical: -4),
                leading: Icon(
                  isActual ? Icons.circle : Icons.play_circle_outline,
                  color: isActual ? AppCSS.verdePrimario : Colors.grey,
                  size: 18,
                ),
                title: Text(
                  '${fav['libro']} ${cap + 1}',
                  style: TextStyle(fontSize: 13, fontWeight: isActual ? FontWeight.bold : FontWeight.normal),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red, size: 18),
                  onPressed: () {
                    FavoritosBibliaService.toggleFavoritoSync(fav['libro'], cap);
                    setState(() {});
                  },
                ),
                tileColor: isActual ? AppCSS.verdeSuave.withOpacity(0.3) : null,
                onTap: () => _reproducir(libro, cap),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildListaLibros() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.library_books, color: AppCSS.verdePrimario, size: 18),
              const SizedBox(width: 8),
              Text('Todos los Libros', style: AppEstilos.subtitulo.copyWith(fontSize: 15)),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 6),
            itemCount: _libros.length,
            itemBuilder: (_, i) {
              final libro = _libros[i];
              final isActual = _libroActual?.id == libro.id;

              return ExpansionTile(
                dense: true,
                visualDensity: const VisualDensity(vertical: -4),
                leading: Icon(
                  isActual ? Icons.menu_book : Icons.menu_book_outlined,
                  color: isActual ? AppCSS.verdePrimario : AppCSS.gris,
                  size: 20,
                ),
                title: Text(
                  libro.nombre,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActual ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text('${libro.capitulos} capítulos', style: const TextStyle(fontSize: 11)),
                children: List.generate(libro.capitulos, (cap) {
                  final isCapActual = isActual && _capituloActual == cap;
                  final esFav = _esFavorito(libro.nombre, cap);

                  return ListTile(
                    dense: true,
                    visualDensity: const VisualDensity(vertical: -4),
                    leading: Icon(
                      isCapActual ? Icons.circle : Icons.play_circle_outline,
                      color: isCapActual ? AppCSS.verdePrimario : Colors.grey,
                      size: 16,
                    ),
                    title: Text('Cap. ${cap + 1}', style: const TextStyle(fontSize: 12)),
                    trailing: IconButton(
                      icon: Icon(
                        esFav ? Icons.favorite : Icons.favorite_border,
                        color: esFav ? Colors.red : Colors.grey,
                        size: 16,
                      ),
                      onPressed: () {
                        FavoritosBibliaService.toggleFavoritoSync(libro.nombre, cap);
                        setState(() {});
                      },
                    ),
                    tileColor: isCapActual ? AppCSS.verdeSuave.withOpacity(0.3) : null,
                    onTap: () => _reproducir(libro, cap),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  String _fmt(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}