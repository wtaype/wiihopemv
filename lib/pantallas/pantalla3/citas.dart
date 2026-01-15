import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../wicss.dart';
import '../../widev.dart';
import '../../wiauth/auth_fb.dart';
import 'nuevo.dart';
import 'privado.dart';

class PantallaCitas extends StatelessWidget {
  const PantallaCitas({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('📖 Públicas'),
          backgroundColor: AppCSS.verdePrimario,
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.lock_outline, color: AppCSS.blanco),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaPrivado())),
            ),
            IconButton(icon: const Icon(Icons.add_circle_outline, color: AppCSS.blanco), onPressed: () => _mostrar(context)),
          ],
        ),
        backgroundColor: AppCSS.verdeClaro,
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('wicitas').orderBy('creado', descending: true).limit(100).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.error_outline, size: 60, color: Colors.red), const SizedBox(height: 16), Text('Error: ${snapshot.error}')]));
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppCSS.verdePrimario));

            final citas = snapshot.data!.docs.map((d) => CitaRegistro.fromFirestore(d)).where((c) => c.publico).toList();
            if (citas.isEmpty) return SinDatos(mensaje: 'No hay citas públicas', icono: Icons.public, textoBoton: 'Agregar', accionBoton: () => _mostrar(context));

            return RefreshIndicator(
              onRefresh: () async => await FirebaseFirestore.instance.collection('wicitas').get(const GetOptions(source: Source.server)),
              color: AppCSS.verdePrimario,
              child: ListView.builder(padding: const EdgeInsets.all(12), itemCount: citas.length, itemBuilder: (_, i) => _Card(citas[i], () => _mostrar(context, citas[i]))),
            );
          },
        ),
      );

  Future<void> _mostrar(BuildContext context, [CitaRegistro? c]) async {
    final ok = await showModalBottomSheet<bool>(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => RegistroCitaSheet(cita: c));
    if (ok == true && context.mounted) MensajeHelper.mostrarExito(context, c == null ? '✅ Guardada' : '✅ Actualizada');
  }
}

class _Card extends StatelessWidget {
  final CitaRegistro c;
  final VoidCallback onTap;
  const _Card(this.c, this.onTap);

  @override
  Widget build(BuildContext context) {
    final esMia = c.email == (AuthServicio.usuarioActual?.email ?? '');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: esMia ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(c.categoria, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppCSS.verdePrimario)),
              const Text(' • ', style: TextStyle(color: AppCSS.gris)),
              Expanded(child: Text(_f(c.creado), style: const TextStyle(fontSize: 12, color: AppCSS.gris))),
              IconButton(icon: Icon(c.favorito ? Icons.favorite : Icons.favorite_border, color: c.favorito ? Colors.red : AppCSS.gris, size: 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => _toggleFav(c)),
              if (esMia) IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => _eliminar(context, c)),
            ]),
            const SizedBox(height: 12),
            Text(c.cita, style: const TextStyle(height: 1.5, fontSize: 15)),
            const SizedBox(height: 12),
            Row(children: [
              Text(_cap(c.nombreShow), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const Spacer(),
              const Icon(Icons.menu_book, size: 14, color: AppCSS.verdePrimario),
              const SizedBox(width: 6),
              Text(c.libro, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppCSS.verdePrimario)),
            ]),
          ]),
        ),
      ),
    );
  }

  String _f(dynamic t) {
    if (t == null) return '';
    try {
      return DateFormat('dd/MM/yy').format(t is Timestamp ? t.toDate() : DateTime.parse(t.toString()));
    } catch (_) {
      return '';
    }
  }

  String _cap(String s) => s.split(' ').map((p) => p.isEmpty ? '' : '${p[0].toUpperCase()}${p.substring(1).toLowerCase()}').join(' ');

  Future<void> _toggleFav(CitaRegistro c) async => await FirebaseFirestore.instance.collection('wicitas').doc(c.id).update({'favorito': !c.favorito});

  Future<void> _eliminar(BuildContext context, CitaRegistro c) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: const Text('Eliminar'), content: const Text('¿Confirmas?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')), TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Sí'))]));
    if (ok == true) {
      await FirebaseFirestore.instance.collection('wicitas').doc(c.id).delete();
      if (context.mounted) MensajeHelper.mostrarExito(context, '🗑️ Eliminada');
    }
  }
}