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
  bool _sincronizando = false;

  @override
  void initState() {
    super.initState();
    _configurarCacheFirestore();
  }

  void _configurarCacheFirestore() {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

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
            icon: _sincronizando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppCSS.blanco,
                    ),
                  )
                : const Icon(Icons.refresh, color: AppCSS.blanco),
            tooltip: 'Sincronizar',
            onPressed: _sincronizando ? null : _sincronizarManual,
          ),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _sincronizarManual,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return _buildSkeletons();
          }

          final citas = snapshot.data ?? [];
          
          if (citas.isEmpty) {
            return SinDatos(
              mensaje: _soloFavoritos ? 'No hay favoritos' : 'No hay citas disponibles',
              icono: Icons.format_quote,
              textoBoton: 'Agregar Primera Cita',
              accionBoton: _mostrarFormulario,
            );
          }

          return RefreshIndicator(
            onRefresh: _sincronizarManual,
            color: AppCSS.verdePrimario,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: citas.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (_, i) => _buildCitaCard(citas[i]),
            ),
          );
        },
      ),
    );
  }

  Stream<List<CitaRegistro>> _obtenerCitasStream() {
    final userEmail = AuthServicio.usuarioActual?.email ?? '';
    
    Query query = FirebaseFirestore.instance
        .collection('wicitas')
        .orderBy('creado', descending: true);

    if (_soloFavoritos) {
      query = query.where('favorito', isEqualTo: true);
    }

    return query.snapshots(includeMetadataChanges: true).map((snapshot) {
      return snapshot.docs
          .where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['publico'] == true || data['email'] == userEmail;
          })
          .map(CitaRegistro.fromFirestore)
          .toList();
    });
  }

  Future<void> _sincronizarManual() async {
    if (_sincronizando) return;
    
    setState(() => _sincronizando = true);

    try {
      await FirebaseFirestore.instance
          .collection('wicitas')
          .get(const GetOptions(source: Source.server));

      if (mounted) {
        MensajeHelper.mostrarExito(context, 'Sincronizado');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Sin conexión - Usando datos locales')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _sincronizando = false);
      }
    }
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
                Row(children: [
                  _buildShimmer(100, 20),
                  const Spacer(),
                  _buildShimmer(24, 24),
                ]),
                const SizedBox(height: 12),
                _buildShimmer(double.infinity, 16),
                const SizedBox(height: 8),
                _buildShimmer(double.infinity, 16),
                const SizedBox(height: 12),
                Row(children: [
                  _buildShimmer(80, 14),
                  const Spacer(),
                  _buildShimmer(100, 14),
                ]),
              ],
            ),
          ),
        ),
      );

  Widget _buildShimmer(double w, double h) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: AppCSS.grisClaro,
          borderRadius: BorderRadius.circular(8),
        ),
      );

  Widget _buildCitaCard(CitaRegistro c) {
    final userEmail = AuthServicio.usuarioActual?.email ?? '';
    final esPropia = c.email == userEmail;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppCSS.blanco,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: esPropia ? () => _mostrarFormulario(citaEditar: c) : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(_getCategoriaIcono(c.categoria),
                    size: 16, color: _getCategoriaColor(c.categoria)),
                const SizedBox(width: 6),
                Text(c.categoria,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _getCategoriaColor(c.categoria))),
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
                if (esPropia) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _confirmarEliminar(c),
                  ),
                ],
              ]),
              const SizedBox(height: 12),
              Text(c.cita, style: const TextStyle(height: 1.5, fontSize: 15)),
              const SizedBox(height: 12),
              Row(children: [
                Icon(c.publico ? Icons.public : Icons.lock, size: 14, color: AppCSS.gris),
                const SizedBox(width: 4),
                Text(c.publico ? 'Público' : 'Privado',
                    style: const TextStyle(
                        fontSize: 11, color: AppCSS.gris, fontWeight: FontWeight.w500)),
                const SizedBox(width: 6),
                const Text('•', style: TextStyle(color: AppCSS.gris, fontSize: 11)),
                const SizedBox(width: 6),
                Text(_capitalizarNombre(c.nombreShow),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const Spacer(),
                const Icon(Icons.menu_book, size: 14, color: AppCSS.verdePrimario),
                const SizedBox(width: 6),
                Text(c.libro,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppCSS.verdePrimario)),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  String _formatearFecha(dynamic fecha) {
    if (fecha == null) return 'Sin fecha';
    try {
      DateTime f;
      if (fecha is Timestamp) {
        f = fecha.toDate();
      } else if (fecha is DateTime) {
        f = fecha;
      } else if (fecha is String) {
        f = DateTime.parse(fecha);
      } else {
        return 'Fecha inválida';
      }
      return DateFormat('dd/MM/yyyy').format(f);
    } catch (_) {
      return 'Fecha inválida';
    }
  }

  String _capitalizarNombre(String n) => n
      .split(' ')
      .map((p) => p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1).toLowerCase())
      .join(' ');

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
    try {
      await FirebaseFirestore.instance
          .collection('wicitas')
          .doc(c.id)
          .update({'favorito': !c.favorito});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _confirmarEliminar(CitaRegistro c) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar Cita'),
        content: const Text('¿Estás seguro de eliminar esta cita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      try {
        await FirebaseFirestore.instance.collection('wicitas').doc(c.id).delete();
        if (mounted) {
          MensajeHelper.mostrarExito(context, '🗑️ Cita eliminada');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _mostrarFormulario({CitaRegistro? citaEditar}) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RegistroCitaSheet(citaEditar: citaEditar),
    );
    if (ok == true && mounted) {
      MensajeHelper.mostrarExito(
        context,
        citaEditar == null ? '✅ Cita guardada' : '✅ Cita actualizada',
      );
    }
  }
}