import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../wicss.dart';
import '../../widev.dart';
import '../../wiauth/auth_fb.dart';
import 'registro_citas.dart';

class PantallaCitas extends StatefulWidget {
  const PantallaCitas({super.key});
  @override
  State<PantallaCitas> createState() => _PantallaCitasState();
}

class _PantallaCitasState extends State<PantallaCitas> {
  bool _soloFavoritos = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📖 Frases Bíblicas'),
        backgroundColor: AppCSS.verdePrimario,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppCSS.blanco),
            tooltip: 'Nueva Cita',
            onPressed: _mostrarFormulario,
          ),
          IconButton(
            icon: Icon(
              _soloFavoritos ? Icons.favorite : Icons.favorite_border,
              color: _soloFavoritos ? Colors.red : AppCSS.blanco,
            ),
            tooltip: 'Favoritos',
            onPressed: () => setState(() => _soloFavoritos = !_soloFavoritos),
          ),
        ],
      ),
      backgroundColor: AppCSS.verdeClaro,
      body: StreamBuilder<List<CitaRegistro>>(
        stream: _obtenerCitasStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildSkeletons();
          }
          final citas = snapshot.data ?? [];
          if (citas.isEmpty) {
            return SinDatos(
              mensaje: 'No hay citas disponibles',
              icono: Icons.format_quote,
              textoBoton: 'Agregar Primera Cita',
              accionBoton: _mostrarFormulario,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: citas.length,
            itemBuilder: (_, i) => _buildCitaCard(citas[i]),
          );
        },
      ),
    );
  }

  Stream<List<CitaRegistro>> _obtenerCitasStream() {
    final userEmail = AuthServicio.usuarioActual?.email ?? '';
    Query q = FirebaseFirestore.instance
        .collection('wicitas')
        .orderBy('creado', descending: true);
    if (_soloFavoritos) q = q.where('favorito', isEqualTo: true);

    return q.snapshots().map((s) => s.docs
        .where((d) {
          final m = d.data() as Map<String, dynamic>;
          return m['publico'] == true || m['email'] == userEmail;
        })
        .map(CitaRegistro.fromFirestore)
        .toList());
  }

  Widget _buildSkeletons() => ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 6,
        itemBuilder: (_, __) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: AppCSS.blanco,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [_buildShimmer(100, 20), const Spacer(), _buildShimmer(24, 24)]),
                const SizedBox(height: 12),
                _buildShimmer(double.infinity, 16),
                const SizedBox(height: 8),
                _buildShimmer(double.infinity, 16),
                const SizedBox(height: 12),
                Row(children: [_buildShimmer(80, 14), const Spacer(), _buildShimmer(100, 14)]),
              ],
            ),
          ),
        ),
      );

  Widget _buildShimmer(double w, double h) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(color: AppCSS.grisClaro, borderRadius: BorderRadius.circular(8)),
      );

  Widget _buildCitaCard(CitaRegistro c) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppCSS.blanco,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _mostrarFormulario(citaEditar: c),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(_getCategoriaIcono(c.categoria), size: 16, color: _getCategoriaColor(c.categoria)),
                const SizedBox(width: 6),
                Text(c.categoria,
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, color: _getCategoriaColor(c.categoria))),
                const SizedBox(width: 8),
                const Text('•', style: TextStyle(color: AppCSS.gris)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatearFecha(c.creado),
                    style: const TextStyle(fontSize: 12, color: AppCSS.gris),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(c.favorito ? Icons.favorite : Icons.favorite_border,
                      color: c.favorito ? Colors.red : AppCSS.gris, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _toggleFavorito(c),
                ),
              ]),
              const SizedBox(height: 12),
              Text(c.cita, style: const TextStyle(height: 1.5, fontSize: 15)),
              const SizedBox(height: 12),
              Row(children: [
                Icon(c.publico ? Icons.public : Icons.lock, size: 14, color: AppCSS.gris),
                const SizedBox(width: 4),
                Text(c.publico ? 'Público' : 'Privado',
                    style: const TextStyle(fontSize: 11, color: AppCSS.gris, fontWeight: FontWeight.w500)),
                const SizedBox(width: 6),
                const Text('•', style: TextStyle(color: AppCSS.gris, fontSize: 11)),
                const SizedBox(width: 6),
                Text(_capitalizarNombre(c.nombreShow),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const Spacer(),
                const Icon(Icons.menu_book, size: 14, color: AppCSS.verdePrimario),
                const SizedBox(width: 6),
                Text(c.libro,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppCSS.verdePrimario)),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  String _formatearFecha(Timestamp? t) {
    if (t == null) return 'Sin fecha';
    try {
      final f = t.toDate();
      final d = DateFormat('EEEE', 'es').format(f);
      final dia = d.isNotEmpty ? d[0].toUpperCase() + d.substring(1) : '';
      final resto = DateFormat('d \'de\' MMMM yyyy', 'es').format(f);
      return '$dia, $resto';
    } catch (_) {
      return 'Fecha inválida';
    }
  }

  String _capitalizarNombre(String n) =>
      n.split(' ').map((p) => p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1).toLowerCase()).join(' ');

  IconData _getCategoriaIcono(String c) {
    switch (c.toLowerCase()) {
      case 'salud':
        return Icons.health_and_safety;
      case 'paz':
        return Icons.spa;
      case 'gratitud':
        return Icons.celebration;
      default:
        return Icons.auto_stories;
    }
  }

  Color _getCategoriaColor(String c) {
    switch (c.toLowerCase()) {
      case 'salud':
        return Colors.green;
      case 'paz':
        return Colors.blue;
      case 'gratitud':
        return Colors.amber;
      default:
        return AppCSS.verdePrimario;
    }
  }

  Future<void> _toggleFavorito(CitaRegistro c) async {
    await FirebaseFirestore.instance.collection('wicitas').doc(c.id).update({'favorito': !c.favorito});
  }

  Future<void> _mostrarFormulario({CitaRegistro? citaEditar}) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RegistroCitaSheet(citaEditar: citaEditar),
    );
    if (ok == true && mounted) {
      MensajeHelper.mostrarExito(context, citaEditar == null ? '✅ Cita guardada' : '✅ Cita actualizada');
    }
  }
}