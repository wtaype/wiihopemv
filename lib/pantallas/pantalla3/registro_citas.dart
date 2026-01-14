import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../wicss.dart';
import '../../wiauth/auth_fb.dart';

class CitaRegistro {
  final String id;
  final String cita;
  final String libro;
  final String nombreShow;
  final bool favorito;
  final bool publico;
  final String usuario;
  final String email;
  final String categoria;
  final Timestamp? creado;
  final Timestamp? actualizado;

  CitaRegistro({
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
      categoria: m['categoria'] ?? 'Otro',
      creado: m['creado'],
      actualizado: m['actualizado'],
    );
  }

  Map<String, dynamic> toFirestore() => {
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

class RegistroCitaSheet extends StatefulWidget {
  final CitaRegistro? citaEditar;
  const RegistroCitaSheet({super.key, this.citaEditar});
  @override
  State<RegistroCitaSheet> createState() => _RegistroCitaSheetState();
}

class _RegistroCitaSheetState extends State<RegistroCitaSheet> {
  final _formKey = GlobalKey<FormState>();
  final _citaCtrl = TextEditingController();
  final _libroCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _categoriaOtraCtrl = TextEditingController();
  bool _favorito = false;
  bool _publico = true;
  String _categoriaSeleccionada = 'Salud';
  bool _guardando = false;
  final _cats = const ['Salud', 'Paz', 'Gratitud'];

  @override
  void initState() {
    super.initState();
    final c = widget.citaEditar;
    final u = AuthServicio.usuarioActual;
    _citaCtrl.text = c?.cita ?? '';
    _libroCtrl.text = c?.libro ?? '';
    _nombreCtrl.text = c?.nombreShow ??
        (u?.displayName?.trim().isNotEmpty == true ? u!.displayName! : u?.email?.split('@').first ?? '');
    _favorito = c?.favorito ?? false;
    _publico = c?.publico ?? true;
    if (c != null && !_cats.contains(c.categoria)) {
      _categoriaSeleccionada = 'Otra';
      _categoriaOtraCtrl.text = c.categoria;
    } else {
      _categoriaSeleccionada = c?.categoria ?? 'Salud';
    }
  }

  @override
  void dispose() {
    _citaCtrl.dispose();
    _libroCtrl.dispose();
    _nombreCtrl.dispose();
    _categoriaOtraCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final u = AuthServicio.usuarioActual;
      final email = u?.email ?? '';
      final usuario = u?.displayName ?? (email.isNotEmpty ? email.split('@').first : 'anónimo');
      final categoriaFinal = _categoriaSeleccionada == 'Otra'
          ? _categoriaOtraCtrl.text.trim()
          : _categoriaSeleccionada;

      final cita = CitaRegistro(
        id: widget.citaEditar?.id ?? 'cita_${DateTime.now().millisecondsSinceEpoch}',
        cita: _citaCtrl.text.trim(),
        libro: _libroCtrl.text.trim(),
        nombreShow: _nombreCtrl.text.trim(),
        favorito: _favorito,
        publico: _publico,
        usuario: usuario,
        email: email,
        categoria: categoriaFinal,
        creado: widget.citaEditar?.creado,
      );

      await FirebaseFirestore.instance.collection('wicitas').doc(cita.id).set(cita.toFirestore());
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
      decoration: const BoxDecoration(
        color: AppCSS.blanco,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppCSS.verdePrimario,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: AppCSS.blanco),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 12),
                const Text('Cita', style: TextStyle(color: AppCSS.blanco, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Flexible(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  TextFormField(
                    controller: _citaCtrl,
                    maxLines: 4,
                    maxLength: 500,
                    autofocus: false,
                    decoration: const InputDecoration(
                      labelText: 'Cita Bíblica *',
                      hintText: 'Escribe el versículo...',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                    validator: (v) => v?.trim().isEmpty ?? true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _libroCtrl,
                          autofocus: false,
                          decoration: const InputDecoration(
                            labelText: 'Referencia *',
                            hintText: 'Salmos 23:1',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v?.trim().isEmpty ?? true ? 'Requerido' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _nombreCtrl,
                          autofocus: false,
                          decoration: const InputDecoration(
                            labelText: 'Tu Nombre *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v?.trim().isEmpty ?? true ? 'Requerido' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Categoría *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._cats.map((c) => ChoiceChip(
                            label: Text(c),
                            selected: _categoriaSeleccionada == c,
                            onSelected: (s) => s ? setState(() => _categoriaSeleccionada = c) : null,
                            selectedColor: AppCSS.verdePrimario,
                            labelStyle: TextStyle(
                              color: _categoriaSeleccionada == c ? AppCSS.blanco : AppCSS.textoOscuro,
                            ),
                          )),
                      ChoiceChip(
                        label: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 4),
                          Text('Otra'),
                        ]),
                        selected: _categoriaSeleccionada == 'Otra',
                        onSelected: (s) => s ? setState(() => _categoriaSeleccionada = 'Otra') : null,
                        selectedColor: AppCSS.verdePrimario,
                        labelStyle: TextStyle(
                          color: _categoriaSeleccionada == 'Otra' ? AppCSS.blanco : AppCSS.textoOscuro,
                        ),
                      ),
                    ],
                  ),
                  if (_categoriaSeleccionada == 'Otra') ...[
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _categoriaOtraCtrl,
                      autofocus: false,
                      decoration: const InputDecoration(
                        labelText: 'Escribe la categoría',
                        hintText: 'Fe, Amor, Esperanza...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v?.trim().isEmpty ?? true ? 'Escribe una categoría' : null,
                    ),
                  ],
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('⭐ Favorita'),
                    value: _favorito,
                    activeColor: AppCSS.verdePrimario,
                    onChanged: (v) => setState(() => _favorito = v),
                    dense: true,
                  ),
                  SwitchListTile(
                    title: const Text('🌍 Pública'),
                    subtitle: const Text('Visible para todos'),
                    value: _publico,
                    activeColor: AppCSS.verdePrimario,
                    onChanged: (v) => setState(() => _publico = v),
                    dense: true,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _guardando ? null : _guardar,
                      icon: _guardando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppCSS.blanco),
                            )
                          : const Icon(Icons.save),
                      label: Text(_guardando ? 'Guardando...' : 'Guardar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppCSS.verdePrimario,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}