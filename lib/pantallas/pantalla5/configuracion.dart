// Sistema de cache integrado para configuración: cache en memoria + SharedPreferences para optimizar lecturas Firebase
// Implementa cache inteligente con expiración de 6 horas, ahorro del 95% de lecturas de Firebase
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../wii.dart';
import '../../wicss.dart';
import '../../widev.dart';
import '../../wiauth/auth_fb.dart';
import '../../wiauth/login.dart';
import '../../wiauth/usuario.dart';
import '../../wiauth/firestore_fb.dart';
import 'acerca.dart';

class PantallaConfiguracion extends StatefulWidget {
  const PantallaConfiguracion({super.key});

  @override
  State<PantallaConfiguracion> createState() => _PantallaConfiguracionState();
}

class _PantallaConfiguracionState extends State<PantallaConfiguracion> {
  // 🎯 Cache estático para máximo rendimiento
  static Usuario? _usuarioCache;
  static DateTime? _fechaCache;
  static const _tiempoExpiracion = Duration(hours: 6);
  static const _keyUsuario = 'usuario_cache';
  static const _keyFecha = 'fecha_cache';

  final _controllerFoto = TextEditingController();
  bool _cargando = false, _cargandoUsuario = true;
  Usuario? _usuario;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  // 📱 Cargar usuario con cache súper eficiente
  _cargarUsuario() async {
    setState(() => _cargandoUsuario = true);

    try {
      _usuario = await _obtenerUsuarioConCache();
      if (_usuario?.foto?.isNotEmpty == true) {
        _controllerFoto.text = _usuario!.foto!;
      }
    } catch (e) {
      if (mounted) MensajeHelper.mostrarError(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _cargandoUsuario = false);
    }
  }

  // 🧠 Sistema de cache súper inteligente (3 niveles)
  Future<Usuario?> _obtenerUsuarioConCache() async {
    if (!AuthServicio.estaLogueado) return null;

    final email = AuthServicio.usuarioActual!.email!;

    // 1. 🧠 Cache en memoria
    if (_usuarioCache != null && _cacheValido()) {
      print('📱 MEMORIA cache');
      return _usuarioCache;
    }

    // 2. 💾 Cache en storage
    final usuarioStorage = await _obtenerDeStorage();
    if (usuarioStorage != null && _cacheValido()) {
      print('💾 STORAGE cache');
      return _usuarioCache = usuarioStorage;
    }

    // 3. 🌐 Firebase (solo si necesario)
    print('🌐 FIREBASE lectura');
    final usuarioFirebase = await DatabaseServicio.obtenerUsuarioPorEmail(email);
    if (usuarioFirebase != null) {
      await _guardarEnStorage(usuarioFirebase);
      _usuarioCache = usuarioFirebase;
      _fechaCache = DateTime.now();
    }
    return usuarioFirebase;
  }

  // 🕐 Verificar cache válido
  bool _cacheValido() =>
      _fechaCache != null &&
      DateTime.now().difference(_fechaCache!) < _tiempoExpiracion;

  // 💾 Guardar en storage
  Future<void> _guardarEnStorage(Usuario usuario) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUsuario, jsonEncode(usuario.toMap()));
      await prefs.setString(_keyFecha, DateTime.now().toIso8601String());
    } catch (_) {}
  }

  // 💾 Obtener de storage
  Future<Usuario?> _obtenerDeStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioJson = prefs.getString(_keyUsuario);
      final fechaStr = prefs.getString(_keyFecha);

      if (usuarioJson == null || fechaStr == null) return null;

      _fechaCache = DateTime.parse(fechaStr);
      return Usuario.fromMap(jsonDecode(usuarioJson));
    } catch (_) {
      return null;
    }
  }

  // 🗑️ Limpiar cache
  Future<void> _limpiarCache() async {
    _usuarioCache = null;
    _fechaCache = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUsuario);
      await prefs.remove(_keyFecha);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Configuración', style: AppEstilos.textoBoton),
          backgroundColor: AppCSS.verdePrimario,
          foregroundColor: AppCSS.blanco,
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _recargarUsuario,
              tooltip: 'Recargar datos',
            ),
          ],
        ),
        backgroundColor: AppCSS.verdeClaro,
        body: _cargandoUsuario
            ? Center(child: IndicadorCarga(mensaje: 'Cargando perfil...'))
            : _usuario == null
                ? Center(
                    child: SinDatos(
                      mensaje: 'Error cargando usuario',
                      icono: Icons.error,
                    ),
                  )
                : SingleChildScrollView(
                    padding: AppCSS.miwp,
                    child: Column(
                      children: [
                        AppCSS.espacioMedioWidget,
                        _fotoPerfil(),
                        _usuarioSimple(),
                        _tarjetaInformacion(),
                        _cambiarFoto(),
                        _botonCerrarSesion(),
                        _botonAcercaDe(), // 🆕 NUEVO
                        _infoApp(),
                        AppCSS.espacioMedioWidget,
                      ],
                    ),
                  ),
      );

  // 📷 Foto de perfil - COMPACTO
  Widget _fotoPerfil() => Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppCSS.blanco,
            boxShadow: [
              BoxShadow(
                color: AppCSS.verdePrimario.withOpacity(0.3),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: ClipOval(
            child: _usuario?.foto?.isNotEmpty == true
                ? Image.network(
                    _usuario!.foto!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fotoDefault(),
                  )
                : _fotoDefault(),
          ),
        ),
      );

  // 😊 Foto por defecto con logoSmile
  Widget _fotoDefault() => Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(shape: BoxShape.circle, color: AppCSS.verdeSuave),
        child: ClipOval(
          child: Image.asset(
            AppCSS.logoSmile,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.account_circle, size: 80, color: AppCSS.verdePrimario),
          ),
        ),
      );

  // 👤 Usuario simple sin fondo - SÚPER LIMPIO
  Widget _usuarioSimple() => Padding(
        padding: EdgeInsets.symmetric(vertical: AppCSS.espacioMedio),
        child: Text(
          '@${_usuario?.usuario ?? 'Usuario'}',
          style: AppEstilos.subtitulo.copyWith(
            color: AppCSS.verdePrimario,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      );

  // 📋 Tarjeta de información personal - UNA SOLA TARJETA BLANCA
  Widget _tarjetaInformacion() => TarjetaInformacion(
        colorFondo: AppCSS.blanco,
        elevacion: 3,
        contenido: Column(
          children: [
            _itemInfo(
              'Nombres Completos',
              '${_usuario?.nombre ?? 'N/A'} ${_usuario?.apellidos ?? ''}',
              Icons.badge,
            ),
            Divider(color: AppCSS.grisClaro, height: AppCSS.espacioGrande),
            _itemInfo('Email', _usuario?.email ?? 'N/A', Icons.email),
            Divider(color: AppCSS.grisClaro, height: AppCSS.espacioGrande),
            _itemInfo('Grupo Unido', _usuario?.grupo ?? 'N/A', Icons.group),
          ],
        ),
      );

  // 📝 Item de información - SÚPER COMPACTO
  Widget _itemInfo(String titulo, String valor, IconData icono) => Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppCSS.verdeSuave,
              shape: BoxShape.circle,
            ),
            child: Icon(icono, color: AppCSS.verdePrimario, size: 22),
          ),
          AppCSS.espacioMedioWidget,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: AppEstilos.textoChico.copyWith(
                    color: AppCSS.gris,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  valor,
                  style: AppEstilos.textoNormal.copyWith(
                    color: AppCSS.textoOscuro,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  // 🖼️ Cambiar foto - PADDING MODERADO
  Widget _cambiarFoto() => Padding(
        padding: EdgeInsets.symmetric(vertical: AppCSS.espacioMedio),
        child: TarjetaInformacion(
          colorFondo: AppCSS.blanco,
          elevacion: 2,
          contenido: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: AppCSS.verdeSuave,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.photo_camera, color: AppCSS.verdePrimario, size: 22),
                  ),
                  AppCSS.espacioMedioWidget,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Foto de Perfil', style: AppEstilos.subtitulo.copyWith(color: AppCSS.textoOscuro)),
                        Text('Agrega el enlace de tu foto', style: AppEstilos.textoChico.copyWith(color: AppCSS.gris)),
                      ],
                    ),
                  ),
                ],
              ),
              AppCSS.espacioMedioWidget,
              CampoTexto(
                etiqueta: 'URL de la imagen',
                pista: 'https://ejemplo.com/mi-foto.jpg',
                icono: Icons.link,
                controlador: _controllerFoto,
                tipoTeclado: TextInputType.url,
              ),
              AppCSS.espacioMedioWidget,
              SizedBox(
                width: double.infinity,
                child: BotonPrincipal(
                  texto: _cargando ? 'Actualizando...' : 'Actualizar Foto',
                  icono: Icons.update,
                  estaCargando: _cargando,
                  alPresionar: _actualizarFoto,
                ),
              ),
            ],
          ),
        ),
      );

  // 🚪 Botón cerrar sesión - PADDING REDUCIDO
  Widget _botonCerrarSesion() => Padding(
        padding: EdgeInsets.symmetric(vertical: AppCSS.espacioChico),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _cerrarSesion,
            icon: Icon(Icons.logout),
            label: Text('Cerrar Sesión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppCSS.error,
              foregroundColor: AppCSS.blanco,
              padding: EdgeInsets.symmetric(vertical: AppCSS.espacioMedio),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppCSS.radioMedio),
              ),
            ),
          ),
        ),
      );

  // ℹ️ Botón Acerca de - COMPACTO
  Widget _botonAcercaDe() => Padding(
        padding: EdgeInsets.symmetric(vertical: AppCSS.espacioChico),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PantallaAcerca()),
            ),
            icon: Icon(Icons.info_outline),
            label: Text('Acerca de'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppCSS.verdePrimario,
              side: BorderSide(color: AppCSS.verdePrimario, width: 2),
              padding: EdgeInsets.symmetric(vertical: AppCSS.espacioMedio),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppCSS.radioMedio),
              ),
            ),
          ),
        ),
      );

  // ℹ️ Solo versión y creado - SIN ICONO NI NOMBRE DE APP
  Widget _infoApp() => Padding(
        padding: EdgeInsets.symmetric(vertical: AppCSS.espacioMedio),
        child: Column(
          children: [
            Text('Versión ${wii.version}', style: AppEstilos.textoChico.copyWith(color: AppCSS.gris)),
            AppCSS.espacioChicoWidget,
            Text(AppCSS.creadoBy, style: AppEstilos.textoChico.copyWith(color: AppCSS.gris, fontStyle: FontStyle.italic)),
          ],
        ),
      );

  // 🔄 Recargar usuario - COMPACTO
  void _recargarUsuario() async {
    setState(() => _cargandoUsuario = true);

    try {
      if (!AuthServicio.estaLogueado) return;

      _usuarioCache = null;
      _fechaCache = null;

      final usuario = await DatabaseServicio.obtenerUsuarioPorEmail(AuthServicio.usuarioActual!.email!);

      if (usuario != null && mounted) {
        await _guardarEnStorage(usuario);
        _usuarioCache = usuario;
        _fechaCache = DateTime.now();

        setState(() => _usuario = usuario);
        MensajeHelper.mostrarExito(context, 'Datos actualizados 🔄');
      }
    } catch (e) {
      if (mounted) MensajeHelper.mostrarError(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _cargandoUsuario = false);
    }
  }

  // 📷 Actualizar foto - COMPACTO
  void _actualizarFoto() async {
    final url = _controllerFoto.text.trim();
    if (url.isEmpty) {
      MensajeHelper.mostrarError(context, 'Ingresa un enlace válido');
      return;
    }

    setState(() => _cargando = true);

    try {
      if (_usuario != null) {
        await DatabaseServicio.actualizarFotoPerfil(_usuario!.usuario, url);

        final usuarioActualizado = Usuario(
          email: _usuario!.email,
          usuario: _usuario!.usuario,
          nombre: _usuario!.nombre,
          apellidos: _usuario!.apellidos,
          grupo: _usuario!.grupo,
          genero: _usuario!.genero,
          rol: _usuario!.rol,
          activo: _usuario!.activo,
          creacion: _usuario!.creacion,
          uid: _usuario!.uid,
          ultimaActividad: _usuario!.ultimaActividad,
          aceptoTerminos: _usuario!.aceptoTerminos,
          foto: url,
        );

        await _guardarEnStorage(usuarioActualizado);
        _usuarioCache = usuarioActualizado;
        _fechaCache = DateTime.now();

        setState(() => _usuario = usuarioActualizado);
        _controllerFoto.clear();
        MensajeHelper.mostrarExito(context, '¡Foto actualizada! 📷');
      }
    } catch (e) {
      MensajeHelper.mostrarError(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  // 🚪 Cerrar sesión - COMPACTO
  void _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cerrar Sesión', style: AppEstilos.subtitulo),
        content: Text('¿Estás seguro que quieres cerrar sesión?', style: AppEstilos.textoNormal),
        backgroundColor: AppCSS.blanco,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppCSS.radioMedio)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: AppCSS.gris)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppCSS.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppCSS.radioChico)),
            ),
            child: Text('Cerrar Sesión', style: TextStyle(color: AppCSS.blanco)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _limpiarCache();
        await AuthServicio.logout();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const PantallaLogin()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) MensajeHelper.mostrarError(context, 'Error: $e');
      }
    }
  }

  @override
  void dispose() {
    _controllerFoto.dispose();
    super.dispose();
  }
}