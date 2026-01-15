import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../wicss.dart';
import '../../wiauth/auth_fb.dart';

// MODELO CitaRegistro
class CitaRegistro {
  final String id, cita, libro, nombreShow, usuario, email, categoria;
  final bool favorito, publico;
  final dynamic creado, actualizado;

  const CitaRegistro({
    required this.id,
    required this.cita,
    required this.libro,
    required this.nombreShow,
    this.favorito = false,
    this.publico = true,
    required this.usuario,
    required this.email,
    required this.categoria,
    this.creado,
    this.actualizado,
  });

  factory CitaRegistro.fromFirestore(DocumentSnapshot d) {
    final m = d.data() as Map<String, dynamic>;
    return CitaRegistro(
      id: d.id,
      cita: m['cita'] ?? '',
      libro: m['libro'] ?? '',
      nombreShow: m['nombreShow'] ?? '',
      favorito: m['favorito'] ?? false,
      publico: m['publico'] ?? true,
      usuario: m['usuario'] ?? '',
      email: m['email'] ?? '',
      categoria: m['categoria'] ?? '',
      creado: m['creado'],
      actualizado: m['actualizado'],
    );
  }

  Map<String, dynamic> toMap() => {
        'cita': cita,
        'libro': libro,
        'nombreShow': nombreShow,
        'favorito': favorito,
        'publico': publico,
        'usuario': usuario,
        'email': email,
        'categoria': categoria,
        'creado': creado ?? FieldValue.serverTimestamp(),
        'actualizado': FieldValue.serverTimestamp(),
      };
}

// MODAL RegistroCitaSheet
class RegistroCitaSheet extends StatefulWidget {
  final CitaRegistro? cita;
  const RegistroCitaSheet({super.key, this.cita});
  @override
  State<RegistroCitaSheet> createState() => _RegistroCitaSheetState();
}

class _RegistroCitaSheetState extends State<RegistroCitaSheet> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _citaCtrl, _libroCtrl, _catCtrl;
  bool _fav = false, _pub = true, _guardando = false;

  @override
  void initState() {
    super.initState();
    final c = widget.cita;
    _citaCtrl = TextEditingController(text: c?.cita ?? '');
    _libroCtrl = TextEditingController(text: c?.libro ?? '');
    _catCtrl = TextEditingController(text: c?.categoria ?? '');
    _fav = c?.favorito ?? false;
    _pub = c?.publico ?? true;
  }

  @override
  void dispose() {
    _citaCtrl.dispose();
    _libroCtrl.dispose();
    _catCtrl.dispose();
    super.dispose();
  }

  String get _nombre {
    final u = AuthServicio.usuarioActual;
    final n = u?.displayName ?? u?.email?.split('@').first ?? 'Anónimo';
    return n.split(' ').map((p) => p.isEmpty ? '' : '${p[0].toUpperCase()}${p.substring(1).toLowerCase()}').join(' ');
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _guardando = true);

    try {
      final u = AuthServicio.usuarioActual!;
      final email = u.email ?? '';
      final cita = CitaRegistro(
        id: widget.cita?.id ?? 'cita_${DateTime.now().millisecondsSinceEpoch}',
        cita: _citaCtrl.text.trim(),
        libro: _libroCtrl.text.trim(),
        nombreShow: _nombre,
        favorito: _fav,
        publico: _pub,
        usuario: u.displayName ?? email.split('@').first,
        email: email,
        categoria: _catCtrl.text.trim().isEmpty ? 'Fe' : _catCtrl.text.trim(),
        creado: widget.cita?.creado,
      );

      if (mounted) Navigator.pop(context, true);
      await FirebaseFirestore.instance.collection('wicitas').doc(cita.id).set(cita.toMap(), SetOptions(merge: true));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          decoration: const BoxDecoration(color: AppCSS.blanco, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: AppCSS.verdePrimario, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              child: Row(children: [
                IconButton(icon: const Icon(Icons.close, color: AppCSS.blanco), onPressed: () => Navigator.pop(context)),
                const SizedBox(width: 12),
                Text(widget.cita == null ? 'Nueva Cita' : 'Editar', style: const TextStyle(color: AppCSS.blanco, fontSize: 18, fontWeight: FontWeight.bold)),
              ]),
            ),
            Flexible(
              child: Form(
                key: _form,
                child: ListView(padding: const EdgeInsets.all(16), children: [
                  TextFormField(
                    controller: _citaCtrl,
                    autofocus: true,
                    maxLines: 4,
                    maxLength: 500,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Cita *', hintText: 'Versículo...', border: OutlineInputBorder(), counterText: ''),
                    validator: (v) => v?.trim().isEmpty ?? true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _libroCtrl,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Referencia *', hintText: 'Salmos 23:1', border: OutlineInputBorder(), prefixIcon: Icon(Icons.menu_book)),
                    validator: (v) => v?.trim().isEmpty ?? true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _catCtrl,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.words,
                    onFieldSubmitted: (_) => _guardar(),
                    decoration: const InputDecoration(labelText: 'Categoría', hintText: 'Salud, Gracias, Fe', border: OutlineInputBorder(), prefixIcon: Icon(Icons.category)),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: SwitchListTile(title: const Text('⭐ Favorita'), value: _fav, activeColor: AppCSS.verdePrimario, onChanged: (v) => setState(() => _fav = v), dense: true)),
                    Expanded(child: SwitchListTile(title: const Text('🌍 Pública'), value: _pub, activeColor: AppCSS.verdePrimario, onChanged: (v) => setState(() => _pub = v), dense: true)),
                  ]),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _guardando ? null : _guardar,
                      icon: _guardando ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppCSS.blanco)) : const Icon(Icons.save, size: 20),
                      label: Text(_guardando ? 'Guardando...' : 'Guardar', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppCSS.verdePrimario, foregroundColor: AppCSS.blanco, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      );
}