import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../wicss.dart';
import 'biblia.dart';

class PantallaAudio extends StatefulWidget {
  const PantallaAudio({super.key});

  @override
  State<PantallaAudio> createState() => _PantallaAudioState();
}

class _PantallaAudioState extends State<PantallaAudio> {
  // 🎵 AUDIO
  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioLibro? _libroActual;
  int _capituloActual = 0;
  bool _isPlaying = false;
  bool _isLoopEnabled = false;
  Duration _duracionTotal = const Duration(seconds: 1);
  Duration _posicionActual = Duration.zero;

  // 🔔 NOTIFICACIONES
  final FlutterLocalNotificationsPlugin _notificaciones =
      FlutterLocalNotificationsPlugin();

  // 🎨 UI
  final TextEditingController _searchController = TextEditingController();
  List<AudioLibro> _libros = [];
  List<Map<String, dynamic>> _itemsFiltrados = [];

  @override
  void initState() {
    super.initState();
    _initNotificaciones();
    _setupPlayerListeners();
    _cargarLibros();
    _cargarEstadoYReproducir();
  }

  // 🔔 INICIALIZAR NOTIFICACIONES
  Future<void> _initNotificaciones() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _notificaciones.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('🔔 Notificación tap: ${response.actionId}');
        if (response.actionId != null) {
          switch (response.actionId) {
            case 'prev':
              _anteriorCapitulo();
              break;
            case 'play_pause':
              _togglePlayPause();
              break;
            case 'next':
              _siguienteCapitulo();
              break;
          }
        }
      },
    );

    // 🔥 SOLICITAR PERMISO
    final granted = await _notificaciones
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    debugPrint('🔔 Permiso de notificaciones: ${granted ?? false}');
  }

  void _setupPlayerListeners() {
    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) setState(() => _posicionActual = position);
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) setState(() => _duracionTotal = duration);
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        final wasPlaying = _isPlaying;
        setState(() => _isPlaying = state == PlayerState.playing);

        // Actualizar notificación cuando cambia el estado
        if (wasPlaying != _isPlaying && _libroActual != null) {
          _mostrarNotificacion();
        }
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (_isLoopEnabled) {
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.resume();
      } else {
        _siguienteCapitulo();
      }
    });
  }

  void _cargarLibros() {
    _libros = BibliaData.cargarLibros();
    _aplanarLibros();
  }

  void _aplanarLibros() {
    _itemsFiltrados.clear();
    for (var libro in _libros) {
      for (int i = 0; i < libro.capitulos; i++) {
        _itemsFiltrados.add({
          'libro': libro,
          'capitulo': i,
          'texto': '${libro.nombre} - Capítulo ${i + 1}',
        });
      }
    }
  }

  Future<void> _cargarEstadoYReproducir() async {
    final prefs = await SharedPreferences.getInstance();
    final libroId = prefs.getInt('libro_actual');
    final capituloId = prefs.getInt('capitulo_actual');

    if (libroId != null && capituloId != null) {
      final libro = _libros.firstWhere(
        (l) => l.id == libroId,
        orElse: () => _libros[0],
      );
      await _reproducirCapitulo(libro, capituloId - 1, autoPlay: false);
    } else {
      await _reproducirCapitulo(_libros[0], 0, autoPlay: false);
    }
  }

  Future<void> _guardarEstado() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('libro_actual', _libroActual?.id ?? 1);
    await prefs.setInt('capitulo_actual', _capituloActual + 1);
  }

  // 🎵 REPRODUCIR CAPÍTULO
  Future<void> _reproducirCapitulo(
    AudioLibro libro,
    int capitulo, {
    bool autoPlay = true,
  }) async {
    setState(() {
      _libroActual = libro;
      _capituloActual = capitulo;
    });

    final url = libro.getUrl(capitulo);
    debugPrint('🎵 Reproduciendo: $url');

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
      if (!autoPlay) await _audioPlayer.pause();
      _guardarEstado();
      _mostrarNotificacion();
    } catch (e) {
      debugPrint('❌ Error reproduciendo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _togglePlayPause() async {
    if (_libroActual == null) {
      await _reproducirCapitulo(_libros[0], 0);
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

  void _toggleLoop() {
    setState(() => _isLoopEnabled = !_isLoopEnabled);
  }

  void _buscarLibros(String query) {
    setState(() {
      if (query.isEmpty) {
        _aplanarLibros();
      } else {
        _itemsFiltrados = _itemsFiltrados.where((item) {
          return item['texto'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  // 🔔 MOSTRAR NOTIFICACIÓN (SIN VARIABLES DINÁMICAS EN ACCIONES)
  Future<void> _mostrarNotificacion() async {
    if (_libroActual == null) return;

    debugPrint(
      '🔔 Mostrando notificación: ${_libroActual!.nombre} - Cap ${_capituloActual + 1}',
    );

    // 🔥 CREAR ACCIONES DINÁMICAMENTE FUERA DE LA CONSTANTE
    final actions = <AndroidNotificationAction>[
      const AndroidNotificationAction(
        'prev',
        '⏮️ Anterior',
        showsUserInterface: false,
        cancelNotification: false,
      ),
      AndroidNotificationAction(
        'play_pause',
        _isPlaying ? '⏸️ Pausar' : '▶️ Play', // 🔥 Ahora es dinámico
        showsUserInterface: false,
        cancelNotification: false,
      ),
      const AndroidNotificationAction(
        'next',
        '⏭️ Siguiente',
        showsUserInterface: false,
        cancelNotification: false,
      ),
    ];

    final androidDetails = AndroidNotificationDetails(
      'biblia_audio',
      'Reproducción de Audio',
      channelDescription: 'Controles de reproducción de la Biblia',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      showWhen: false,
      icon: '@mipmap/ic_launcher',
      playSound: false,
      enableVibration: false,
      actions: actions, // 🔥 Usar la lista dinámica
    );

    final details = NotificationDetails(android: androidDetails);

    try {
      await _notificaciones.show(
        0,
        '🎧 ${_libroActual!.nombre}',
        '📖 Capítulo ${_capituloActual + 1} ${_isPlaying ? "• Reproduciendo ▶️" : "• Pausado ⏸️"}',
        details,
      );
      debugPrint(
        '✅ Notificación mostrada: ${_isPlaying ? "Playing" : "Paused"}',
      );
    } catch (e) {
      debugPrint('❌ Error mostrando notificación: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '📖 Biblia Audio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppCSS.verdePrimario,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: AppCSS.verdeClaro,
      body: Column(
        children: [
          _buildCompactPlayer(),
          _buildSearchBar(),
          Expanded(child: _buildFlatList()),
        ],
      ),
    );
  }

  // 🎨 REPRODUCTOR COMPACTO (SIN OVERFLOW - AUMENTADO TAMAÑO)
  Widget _buildCompactPlayer() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.21,
      margin: AppCSS.miwp,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppCSS.verdePrimario, AppCSS.verdeSuave],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppCSS.radioMedio),
        boxShadow: [
          BoxShadow(
            color: AppCSS.verdePrimario.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // LÍNEA 1: Título
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _libroActual?.nombre ?? 'San Mateo',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 3),
                Text(
                  'Capítulo ${_capituloActual + 1}',
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            // LÍNEA 2: Controles
            _buildControls(),
            // LÍNEA 3: Progress bar
            _buildProgressBar(),
          ],
        ),
      ),
    );
  }

  // 🎛️ CONTROLES
  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlButton(
          Icons.skip_previous,
          _anteriorCapitulo,
          enabled: _capituloActual > 0,
        ),
        const SizedBox(width: 18),
        _buildPlayButton(),
        const SizedBox(width: 18),
        _buildControlButton(
          Icons.skip_next,
          _siguienteCapitulo,
          enabled:
              _libroActual != null &&
              _capituloActual < _libroActual!.capitulos - 1,
        ),
        const SizedBox(width: 18),
        _buildControlButton(
          _isLoopEnabled ? Icons.repeat_one : Icons.repeat,
          _toggleLoop,
        ),
      ],
    );
  }

  Widget _buildPlayButton() {
    return Container(
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          _isPlaying ? Icons.pause : Icons.play_arrow,
          size: 36,
          color: AppCSS.verdePrimario,
        ),
        onPressed: _togglePlayPause,
      ),
    );
  }

  Widget _buildControlButton(
    IconData icon,
    VoidCallback? onPressed, {
    bool enabled = true,
  }) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: enabled ? Colors.white.withOpacity(0.3) : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: enabled ? Colors.white : Colors.grey, size: 26),
        onPressed: enabled ? onPressed : null,
      ),
    );
  }

  // 📊 BARRA DE PROGRESO
  Widget _buildProgressBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3,
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white30,
            thumbColor: Colors.white,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayColor: Colors.white.withOpacity(0.2),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
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
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            // 🔥 SIN Padding
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_posicionActual),
                style: const TextStyle(color: Colors.white70, fontSize: 8.9),
              ), // 🔥 Fuente más pequeña
              Text(
                _formatDuration(_duracionTotal),
                style: const TextStyle(color: Colors.white70, fontSize: 8.9),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 🔍 BUSCADOR
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: _buscarLibros,
        style: AppEstilos.textoNormal.copyWith(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Buscar libros y capítulos...',
          hintStyle: AppEstilos.textoChico.copyWith(
            color: Colors.grey,
            fontSize: 13,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _buscarLibros('');
                  },
                )
              : null,
        ),
      ),
    );
  }

  // 📚 LISTA PLANA
  Widget _buildFlatList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppCSS.radioMedio),
      ),
      child: _itemsFiltrados.isEmpty
          ? Center(
              child: Text(
                'No se encontraron resultados',
                style: AppEstilos.textoChico,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _itemsFiltrados.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = _itemsFiltrados[index];
                final libro = item['libro'] as AudioLibro;
                final capitulo = item['capitulo'] as int;
                final isActual =
                    _libroActual?.id == libro.id && _capituloActual == capitulo;

                return ListTile(
                  dense: true,
                  leading: Icon(
                    isActual ? Icons.play_circle : Icons.play_circle_outline,
                    color: isActual ? AppCSS.verdePrimario : Colors.grey,
                    size: 28,
                  ),
                  title: Text(
                    item['texto'],
                    style: AppEstilos.textoNormal.copyWith(
                      fontSize: 14,
                      fontWeight: isActual
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  tileColor: isActual ? AppCSS.verdeSuave : null,
                  onTap: () => _reproducirCapitulo(libro, capitulo),
                );
              },
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
    _notificaciones.cancel(0);
    super.dispose();
  }
}
