import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../widev.dart';
import '../../wiauth/auth_fb.dart';

class CitaRegistro {
  final String id;
  final String? cita;
  final String? libro;
  final String? nombreShow;
  final int? orden;
  final bool? favorito;
  final bool? publico;
  final String? usuario;
  final String? email;
  final Timestamp? creado;
  final Timestamp? actualizado;

  CitaRegistro({
    required this.id,
    this.cita,
    this.libro,
    this.nombreShow,
    this.orden,
    this.favorito,
    this.publico,
    this.usuario,
    this.email,
    this.creado,
    this.actualizado,
  });

  CitaRegistro copyWith({
    String? id,
    String? cita,
    String? libro,
    String? nombreShow,
    int? orden,
    bool? favorito,
    bool? publico,
    String? usuario,
    String? email,
    Timestamp? creado,
    Timestamp? actualizado,
  }) => CitaRegistro(
    id: id ?? this.id,
    cita: cita ?? this.cita,
    libro: libro ?? this.libro,
    nombreShow: nombreShow ?? this.nombreShow,
    orden: orden ?? this.orden,
    favorito: favorito ?? this.favorito,
    publico: publico ?? this.publico,
    usuario: usuario ?? this.usuario,
    email: email ?? this.email,
    creado: creado ?? this.creado,
    actualizado: actualizado ?? this.actualizado,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'cita': cita,
    'libro': libro,
    'nombreShow': nombreShow,
    'orden': orden,
    'favorito': favorito,
    'publico': publico,
    'usuario': usuario,
    'email': email,
    'creado': creado?.toDate().toIso8601String(),
    'actualizado': actualizado?.toDate().toIso8601String(),
  };

  factory CitaRegistro.fromMap(Map<String, dynamic> m) => CitaRegistro(
    id: m['id'] ?? '',
    cita: m['cita'],
    libro: m['libro'],
    nombreShow: m['nombreShow'],
    orden: m['orden'],
    favorito: m['favorito'],
    publico: m['publico'],
    usuario: m['usuario'],
    email: m['email'],
    creado: m['creado'] != null
        ? Timestamp.fromDate(DateTime.parse(m['creado']))
        : null,
    actualizado: m['actualizado'] != null
        ? Timestamp.fromDate(DateTime.parse(m['actualizado']))
        : null,
  );

  factory CitaRegistro.fromFirestore(DocumentSnapshot d) {
    final m = d.data() as Map<String, dynamic>;
    return CitaRegistro(
      id: d.id,
      cita: m['cita'],
      libro: m['libro'],
      nombreShow: m['nombreShow'],
      orden: m['orden'],
      favorito: m['favorito'],
      publico: m['publico'],
      usuario: m['usuario'],
      email: m['email'],
      creado: m['creado'],
      actualizado: m['actualizado'],
    );
  }
}

class RegistroCitaSheet extends StatefulWidget {
  final int ordenSugerido;
  const RegistroCitaSheet({super.key, required this.ordenSugerido});

  @override
  State<RegistroCitaSheet> createState() => _RegistroCitaSheetState();
}

class _RegistroCitaSheetState extends State<RegistroCitaSheet> {
  final _formKey = GlobalKey<FormState>();
  final _citaCtrl = TextEditingController();
  final _libroCtrl = TextEditingController();
  final _ordenCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  bool _favorito = false;
  bool _publico = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _ordenCtrl.text = widget.ordenSugerido.toString();
    final user = AuthServicio.usuarioActual;
    _nombreCtrl.text = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!
        : (user?.email?.split('@').first ?? '');
  }

  @override
  void dispose() {
    _citaCtrl.dispose();
    _libroCtrl.dispose();
    _ordenCtrl.dispose();
    _nombreCtrl.dispose();
    super.dispose();
  }

  String? _req(String? v, String c, {int? max}) {
    if (v == null || v.trim().isEmpty) return '$c requerido';
    if (max != null && v.trim().length > max) return 'Máx. $max caracteres';
    return null;
  }

  String? _valOrden(String? v) {
    if (v == null || v.trim().isEmpty) return 'Requerido';
    final n = int.tryParse(v);
    if (n == null || n < 0) return 'Número válido';
    return null;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final user = AuthServicio.usuarioActual;
      final email = user?.email ?? '';
      final usuario =
          user?.displayName ??
          (email.isNotEmpty ? email.split('@').first : 'anónimo');

      await FirebaseFirestore.instance
          .collection('wicitas')
          .doc('cita_${DateTime.now().millisecondsSinceEpoch}')
          .set({
            'cita': _citaCtrl.text.trim(),
            'libro': _libroCtrl.text.trim(),
            'nombreShow': _nombreCtrl.text.trim(),
            'orden': int.parse(_ordenCtrl.text.trim()),
            'favorito': _favorito,
            'publico': _publico,
            'usuario': usuario,
            'email': email,
            'creado': FieldValue.serverTimestamp(),
            'actualizado': FieldValue.serverTimestamp(),
          });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: SingleChildScrollView(
        padding: AppConstantes.miwpL,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppConstantes.espacioMedioWidget,
              Text(
                'Nueva Frase Bíblica',
                style: AppEstilos.tituloMedio.copyWith(
                  color: AppColores.verdePrimario,
                ),
              ),
              AppConstantes.espacioMedioWidget,
              TextFormField(
                controller: _citaCtrl,
                maxLines: 4,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Cita Bíblica *',
                  hintText: 'Escribe la cita...',
                ),
                validator: (v) => _req(v, 'Cita', max: 500),
              ),
              AppConstantes.espacioMedioWidget,
              TextFormField(
                controller: _libroCtrl,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Referencia *',
                  hintText: 'Ej: Salmo 23:1',
                ),
                validator: (v) => _req(v, 'Referencia', max: 100),
              ),
              AppConstantes.espacioMedioWidget,
              TextFormField(
                controller: _ordenCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Orden *'),
                validator: _valOrden,
              ),
              AppConstantes.espacioMedioWidget,
              TextFormField(
                controller: _nombreCtrl,
                maxLength: 50,
                decoration: const InputDecoration(
                  labelText: 'Nombre Público *',
                ),
                validator: (v) => _req(v, 'Nombre', max: 50),
              ),
              AppConstantes.espacioMedioWidget,
              SwitchListTile(
                title: const Text('Favorita?'),
                value: _favorito,
                activeColor: AppColores.verdePrimario,
                onChanged: (v) => setState(() => _favorito = v),
              ),
              SwitchListTile(
                title: const Text('Hacer pública'),
                value: _publico,
                activeColor: AppColores.verdePrimario,
                onChanged: (v) => setState(() => _publico = v),
              ),
              AppConstantes.espacioMedioWidget,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _guardando ? null : _guardar,
                  icon: const Icon(Icons.save),
                  label: Text(_guardando ? 'Guardando...' : 'Guardar'),
                ),
              ),
              AppConstantes.espacioMedioWidget,
            ],
          ),
        ),
      ),
    );
  }
}
