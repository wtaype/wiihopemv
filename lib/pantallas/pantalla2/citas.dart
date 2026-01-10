import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widev.dart';
import 'registro_citas.dart';
import '../../wiauth/auth_fb.dart';

class PantallaCitas extends StatefulWidget {
  const PantallaCitas({super.key});

  @override
  State<PantallaCitas> createState() => _PantallaCitasState();
}

class _PantallaCitasState extends State<PantallaCitas> {
  static const _cacheKey = 'wiFrases';
  static const _cacheFecha = 'wiFrases_fecha';
  static const _ttl = Duration(minutes: 10);

  final _db = FirebaseFirestore.instance;
  bool _cargando = true;
  List<CitaRegistro> _citas = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos({bool forzar = false}) async {
    setState(() => _cargando = true);
    try {
      if (!forzar && await _cargarCache()) {
        setState(() => _cargando = false);
        _refrescarEnFondo();
        return;
      }
      await _fetchFirestore();
    } catch (_) {
      await _cargarCache();
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<bool> _cargarCache() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_cacheKey);
    final fechaStr = prefs.getString(_cacheFecha);
    if (data == null || fechaStr == null) return false;

    final fecha = DateTime.tryParse(fechaStr);
    if (fecha == null || DateTime.now().difference(fecha) >= _ttl) return false;

    final List<dynamic> json = jsonDecode(data);
    _citas = json.map((e) => CitaRegistro.fromMap(e)).toList();
    return true;
  }

  Future<void> _guardarCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cacheKey,
      jsonEncode(_citas.map((e) => e.toMap()).toList()),
    );
    await prefs.setString(_cacheFecha, DateTime.now().toIso8601String());
  }

  Future<void> _borrarCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheFecha);
  }

  void _refrescarEnFondo() async {
    final prefs = await SharedPreferences.getInstance();
    final fechaStr = prefs.getString(_cacheFecha);
    if (fechaStr == null) return;
    final fecha = DateTime.tryParse(fechaStr);
    if (fecha != null && DateTime.now().difference(fecha) >= _ttl) {
      _fetchFirestore();
    }
  }

  Future<void> _fetchFirestore() async {
    final user = AuthServicio.usuarioActual;
    final email = user?.email;

    // 1) Públicas
    final pubSnap = await _db
        .collection('wicitas')
        .where('publico', isEqualTo: true)
        .get();

    final publicas = pubSnap.docs
        .map((d) => CitaRegistro.fromFirestore(d))
        .where((c) => c.email != email) // excluir mis públicas
        .toList();

    // 2) Todas las mías (públicas + privadas)
    List<CitaRegistro> mias = [];
    if (email != null && email.isNotEmpty) {
      final miasSnap = await _db
          .collection('wicitas')
          .where('email', isEqualTo: email)
          .get();
      mias = miasSnap.docs.map((d) => CitaRegistro.fromFirestore(d)).toList();
    }

    // 3) Combinar y ordenar
    _citas = [...publicas, ...mias]
      ..sort((a, b) {
        final favA = a.favorito == true ? 1 : 0;
        final favB = b.favorito == true ? 1 : 0;
        if (favA != favB) return favB.compareTo(favA);
        return (a.orden ?? 0).compareTo(b.orden ?? 0);
      });

    await _guardarCache();
    if (mounted) setState(() {});
  }

  Future<void> _onRefresh() async {
    await _borrarCache();
    await _cargarDatos(forzar: true);
  }

  Future<void> _abrirNuevo() async {
    final maxOrden = _citas.isEmpty
        ? 1
        : (_citas.map((e) => e.orden ?? 0).reduce((a, b) => a > b ? a : b) + 1);
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstantes.radioGrande),
        ),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: RegistroCitaSheet(ordenSugerido: maxOrden),
      ),
    );
    if (ok == true) await _onRefresh();
  }

  Future<void> _toggleFavorito(CitaRegistro cita) async {
    final user = AuthServicio.usuarioActual;
    if (user?.email != cita.email) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sin permisos')));
      return;
    }

    final nuevo = !(cita.favorito ?? false);
    setState(() {
      _citas = _citas
          .map((e) => e.id == cita.id ? e.copyWith(favorito: nuevo) : e)
          .toList();
    });

    try {
      await _db.collection('wicitas').doc(cita.id).update({
        'favorito': nuevo,
        'actualizado': FieldValue.serverTimestamp(),
      });
      await _guardarCache();
    } catch (_) {
      setState(() {
        _citas = _citas
            .map((e) => e.id == cita.id ? e.copyWith(favorito: !nuevo) : e)
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColores.verdeClaro,
    appBar: AppBar(
      title: Text('Citas', style: AppEstilos.textoBoton),
      backgroundColor: AppColores.verdePrimario,
      foregroundColor: Colors.white,
      centerTitle: true,
      automaticallyImplyLeading: false,
      elevation: 0,
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _onRefresh),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 26),
          onPressed: _abrirNuevo,
        ),
      ],
    ),
    body: _cargando
        ? const _SkeletonList(count: 4)
        : _citas.isEmpty
        ? Center(
            child: Text('Sin citas todavía', style: AppEstilos.textoNormal),
          )
        : ListView.separated(
            padding: AppConstantes.miwpL,
            itemCount: _citas.length,
            separatorBuilder: (_, __) => AppConstantes.espacioMedioWidget,
            itemBuilder: (_, i) => _CitaCard(
              cita: _citas[i],
              onFav: () => _toggleFavorito(_citas[i]),
            ),
          ),
  );
}

class _SkeletonList extends StatelessWidget {
  final int count;
  const _SkeletonList({required this.count});

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: AppConstantes.miwpL,
    itemCount: count,
    separatorBuilder: (_, __) => AppConstantes.espacioMedioWidget,
    itemBuilder: (_, __) => Container(
      padding: AppConstantes.miwp,
      decoration: BoxDecoration(
        color: AppColores.blanco,
        borderRadius: BorderRadius.circular(AppConstantes.radioMedio),
        boxShadow: [
          BoxShadow(
            color: AppColores.verdePrimario.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _skBox(160, 14),
          const SizedBox(height: 10),
          _skBox(double.infinity, 14),
          const SizedBox(height: 6),
          _skBox(double.infinity, 14),
          const SizedBox(height: 6),
          _skBox(140, 12),
        ],
      ),
    ),
  );

  Widget _skBox(double w, double h) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: AppColores.grisClaro,
      borderRadius: BorderRadius.circular(8),
    ),
  );
}

class _CitaCard extends StatelessWidget {
  final CitaRegistro cita;
  final VoidCallback onFav;
  const _CitaCard({required this.cita, required this.onFav});

  @override
  Widget build(BuildContext context) {
    final user = AuthServicio.usuarioActual;
    final esCreador = user?.email == cita.email;

    return Container(
      padding: AppConstantes.miwp,
      decoration: BoxDecoration(
        color: AppColores.blanco,
        borderRadius: BorderRadius.circular(AppConstantes.radioMedio),
        boxShadow: [
          BoxShadow(
            color: AppColores.verdePrimario.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  cita.libro ?? '—',
                  style: AppEstilos.subtitulo.copyWith(
                    color: AppColores.verdePrimario,
                  ),
                ),
              ),
              if (esCreador)
                IconButton(
                  icon: Icon(
                    cita.favorito == true
                        ? Icons.star
                        : Icons.star_border_outlined,
                    color: cita.favorito == true
                        ? Colors.amber
                        : AppColores.grisOscuro,
                  ),
                  onPressed: onFav,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '"${cita.cita ?? ''}"',
            style: AppEstilos.textoNormal.copyWith(height: 1.5),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.person, size: 16, color: AppColores.gris),
              const SizedBox(width: 6),
              Text(
                cita.nombreShow ?? cita.usuario ?? '—',
                style: AppEstilos.textoChico.copyWith(
                  color: AppColores.grisOscuro,
                ),
              ),
              const Spacer(),
              Text(
                cita.publico == true ? 'Pública' : 'Privada',
                style: AppEstilos.textoChico.copyWith(
                  color: cita.publico == true
                      ? AppColores.verdePrimario
                      : AppColores.gris,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
