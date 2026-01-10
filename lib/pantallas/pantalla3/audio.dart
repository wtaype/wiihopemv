import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widev.dart';
import 'dart:math' as math;

class PantallaAudio extends StatefulWidget {
  const PantallaAudio({super.key});

  @override
  State<PantallaAudio> createState() => _PantallaAudioState();
}

class _PantallaAudioState extends State<PantallaAudio>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _searchController = TextEditingController();

  List<AudioLibro> _libros = [];
  List<AudioLibro> _librosFiltrados = [];
  AudioLibro? _libroActual;
  int _capituloActual = 0;
  bool _isPlaying = false;
  Duration _duracionTotal = const Duration(seconds: 1);
  Duration _posicionActual = Duration.zero;

  late AnimationController _waveController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _cargarLibros();
    _setupPlayerListeners();
    _cargarEstado();
  }

  void _initAnimations() {
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  void _cargarLibros() {
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

    int trackId = 1;
    librosData.forEach((nombre, caps) {
      final nombreArchivo = nombre.replaceAll(' ', '_');
      _libros.add(
        AudioLibro(
          id: trackId,
          nombre: nombre,
          capitulos: caps,
          urlBase: baseUrl,
          nombreArchivo: nombreArchivo,
          trackInicio: trackId,
        ),
      );
      trackId += caps;
    });

    _librosFiltrados = _libros;
  }

  void _setupPlayerListeners() {
    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) setState(() => _posicionActual = position);
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) setState(() => _duracionTotal = duration);
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });

    _audioPlayer.onPlayerComplete.listen((_) => _siguienteCapitulo());
  }

  Future<void> _cargarEstado() async {
    final prefs = await SharedPreferences.getInstance();
    final libroId = prefs.getInt('libro_actual') ?? 1;
    final capituloId = prefs.getInt('capitulo_actual') ?? 1;

    if (mounted) {
      setState(() {
        _libroActual = _libros.firstWhere(
          (l) => l.id == libroId,
          orElse: () => _libros[0],
        );
        _capituloActual = capituloId - 1;
      });
    }
  }

  Future<void> _guardarEstado() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('libro_actual', _libroActual?.id ?? 1);
    await prefs.setInt('capitulo_actual', _capituloActual + 1);
  }

  void _reproducirCapitulo(AudioLibro libro, int capitulo) async {
    setState(() {
      _libroActual = libro;
      _capituloActual = capitulo;
    });

    final trackNum = libro.trackInicio + capitulo;
    final capStr = (capitulo + 1).toString().padLeft(2, '0');
    final url =
        '${libro.urlBase}/${trackNum}_${libro.nombreArchivo}_$capStr.mp3';

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
      _guardarEstado();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _togglePlayPause() async {
    if (_libroActual == null) {
      _reproducirCapitulo(_libros[0], 0);
    } else {
      _isPlaying ? await _audioPlayer.pause() : await _audioPlayer.resume();
    }
  }

  void _anteriorCapitulo() {
    if (_libroActual != null && _capituloActual > 0) {
      _reproducirCapitulo(_libroActual!, _capituloActual - 1);
    }
  }

  void _siguienteCapitulo() {
    if (_libroActual != null && _capituloActual < _libroActual!.capitulos - 1) {
      _reproducirCapitulo(_libroActual!, _capituloActual + 1);
    }
  }

  void _buscarLibros(String query) {
    setState(() {
      _librosFiltrados = query.isEmpty
          ? _libros
          : _libros
                .where(
                  (l) => l.nombre.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '📖 Biblia Audio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColores.verdePrimario,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: AppColores.verdeClaro,
      body: Column(
        children: [
          _buildPlayerSection(),
          _buildControls(),
          Expanded(child: _buildPlaylist()),
        ],
      ),
    );
  }

  Widget _buildPlayerSection() {
    return Container(
      margin: AppConstantes.miwp,
      padding: AppConstantes.miwpL,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColores.verdePrimario, AppColores.verdeSuave],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstantes.radioMedio),
        boxShadow: [
          BoxShadow(
            color: AppColores.verdePrimario.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _libroActual?.nombre ?? 'Toca para iniciar',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppConstantes.espacioChicoWidget,
          Text(
            _libroActual != null ? 'Capítulo ${_capituloActual + 1}' : '',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          AppConstantes.espacioMedioWidget,
          GestureDetector(onTap: _togglePlayPause, child: _buildWaves()),
          AppConstantes.espacioMedioWidget,
          _buildProgressBar(),
        ],
      ),
    );
  }

  Widget _buildWaves() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        return SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final delay = index * 0.2;
              final height = _isPlaying
                  ? (math.sin((_waveController.value * 2 * math.pi) + delay) *
                            20) +
                        30
                  : 10.0;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: 6,
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white30,
            thumbColor: Colors.white,
            overlayColor: Colors.white.withOpacity(0.2),
          ),
          child: Slider(
            value: _posicionActual.inSeconds.toDouble().clamp(
              0.0,
              _duracionTotal.inSeconds.toDouble(),
            ),
            max: _duracionTotal.inSeconds.toDouble(),
            onChanged: (value) =>
                _audioPlayer.seek(Duration(seconds: value.toInt())),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_posicionActual),
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                _formatDuration(_duracionTotal),
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: AppConstantes.miwpL,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildControlButton(
            Icons.skip_previous,
            _anteriorCapitulo,
            enabled: _capituloActual > 0,
          ),
          const SizedBox(width: 20),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              final scale = _isPlaying
                  ? 1.0 + (_pulseController.value * 0.1)
                  : 1.0;
              return Transform.scale(scale: scale, child: _buildPlayButton());
            },
          ),
          const SizedBox(width: 20),
          _buildControlButton(
            Icons.skip_next,
            _siguienteCapitulo,
            enabled:
                _libroActual != null &&
                _capituloActual < _libroActual!.capitulos - 1,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: AppColores.verdePrimario,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColores.verdePrimario.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          _isPlaying ? Icons.pause : Icons.play_arrow,
          size: 35,
          color: Colors.white,
        ),
        onPressed: _togglePlayPause,
      ),
    );
  }

  Widget _buildControlButton(
    IconData icon,
    VoidCallback onPressed, {
    bool enabled = true,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: enabled ? AppColores.verdeSuave : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: enabled ? AppColores.verdePrimario : Colors.grey,
        ),
        onPressed: enabled ? onPressed : null,
      ),
    );
  }

  Widget _buildPlaylist() {
    return Container(
      margin: AppConstantes.miwp,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstantes.radioMedio),
      ),
      child: Column(
        children: [
          Padding(
            padding: AppConstantes.miwpL,
            child: TextField(
              controller: _searchController,
              onChanged: _buscarLibros,
              decoration: InputDecoration(
                hintText: '🔍 Buscar libro...',
                filled: true,
                fillColor: AppColores.verdeClaro,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstantes.radioChico),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _librosFiltrados.length,
              itemBuilder: (context, index) {
                final libro = _librosFiltrados[index];
                return ExpansionTile(
                  title: Text(
                    libro.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${libro.capitulos} capítulos'),
                  children: List.generate(libro.capitulos, (capIndex) {
                    final isActual =
                        _libroActual?.id == libro.id &&
                        _capituloActual == capIndex;
                    return ListTile(
                      leading: Icon(
                        isActual
                            ? Icons.play_circle
                            : Icons.play_circle_outline,
                        color: isActual
                            ? AppColores.verdePrimario
                            : Colors.grey,
                      ),
                      title: Text('Capítulo ${capIndex + 1}'),
                      tileColor: isActual ? AppColores.verdeSuave : null,
                      onTap: () => _reproducirCapitulo(libro, capIndex),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(d.inMinutes.remainder(60))}:${pad(d.inSeconds.remainder(60))}';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _searchController.dispose();
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}

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
}
