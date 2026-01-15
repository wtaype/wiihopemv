import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final dynamic creado;
  final dynamic actualizado;

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
  final _citaFocus = FocusNode();
  final _libroFocus = FocusNode();
  final _nombreFocus = FocusNode();
  final _otraFocus = FocusNode();
  bool _favorito = false;
  bool _publico = true;
  String _categoriaSeleccionada = 'Salud';
  bool _guardando = false;
  final _cats = const ['Salud', 'Paz', 'Gratitud'];

  @override
  void initState() {
    super.initState();
    _inicializarDatos();
    
    // Optimización: Auto-focus en el primer campo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _citaFocus.requestFocus();
    });
  }

  void _inicializarDatos() {
    final c = widget.citaEditar;
    final u = AuthServicio.usuarioActual;
    
    _citaCtrl.text = c?.cita ?? '';
    _libroCtrl.text = c?.libro ?? '';
    _nombreCtrl.text = c?.nombreShow ??
        (u?.displayName?.trim().isNotEmpty == true
            ? u!.displayName!
            : u?.email?.split('@').first ?? '');
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
    _citaFocus.dispose();
    _libroFocus.dispose();
    _nombreFocus.dispose();
    _otraFocus.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    // Cerrar teclado inmediatamente
    FocusScope.of(context).unfocus();
    
    setState(() => _guardando = true);

    try {
      final u = AuthServicio.usuarioActual;
      final email = u?.email ?? '';
      final usuario = u?.displayName ??
          (email.isNotEmpty ? email.split('@').first : 'anónimo');
      final categoriaFinal = _categoriaSeleccionada == 'Otra'
          ? _categoriaOtraCtrl.text.trim()
          : _categoriaSeleccionada;

      final cita = CitaRegistro(
        id: widget.citaEditar?.id ??
            'cita_${DateTime.now().millisecondsSinceEpoch}',
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

      // Optimistic update: cerrar sheet antes de guardar
      if (mounted) Navigator.pop(context, true);

      // Guardar en background
      await FirebaseFirestore.instance
          .collection('wicitas')
          .doc(cita.id)
          .set(cita.toFirestore(), SetOptions(merge: true));
          
    } catch (e) {
      // Si falla, mostrar error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: _guardar,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _cambiarCategoria(String categoria) {
    setState(() => _categoriaSeleccionada = categoria);
    
    // Cerrar teclado al cambiar categoría
    FocusScope.of(context).unfocus();
    
    // Si selecciona "Otra", abrir teclado automáticamente
    if (categoria == 'Otra') {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) _otraFocus.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
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
                  Text(
                    widget.citaEditar == null ? 'Nueva Cita' : 'Editar Cita',
                    style: const TextStyle(
                      color: AppCSS.blanco,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                      focusNode: _citaFocus,
                      maxLines: 4,
                      maxLength: 500,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(500),
                      ],
                      onFieldSubmitted: (_) => _libroFocus.requestFocus(),
                      decoration: const InputDecoration(
                        labelText: 'Cita Bíblica *',
                        hintText: 'Escribe el versículo...',
                        border: OutlineInputBorder(),
                        counterText: '',
                        prefixIcon: Icon(Icons.format_quote),
                      ),
                      validator: (v) =>
                          v?.trim().isEmpty ?? true ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _libroCtrl,
                            focusNode: _libroFocus,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            onFieldSubmitted: (_) => _nombreFocus.requestFocus(),
                            decoration: const InputDecoration(
                              labelText: 'Referencia *',
                              hintText: 'Salmos 23:1',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.menu_book),
                            ),
                            validator: (v) =>
                                v?.trim().isEmpty ?? true ? 'Requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _nombreCtrl,
                            focusNode: _nombreFocus,
                            textInputAction: TextInputAction.done,
                            textCapitalization: TextCapitalization.words,
                            onFieldSubmitted: (_) {
                              _nombreFocus.unfocus();
                              _guardar();
                            },
                            decoration: const InputDecoration(
                              labelText: 'Tu Nombre *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (v) =>
                                v?.trim().isEmpty ?? true ? 'Requerido' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Categoría *',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ..._cats.map((c) => ChoiceChip(
                              label: Text(c),
                              selected: _categoriaSeleccionada == c,
                              onSelected: (s) => s ? _cambiarCategoria(c) : null,
                              selectedColor: AppCSS.verdePrimario,
                              labelStyle: TextStyle(
                                color: _categoriaSeleccionada == c
                                    ? AppCSS.blanco
                                    : AppCSS.textoOscuro,
                                fontWeight: _categoriaSeleccionada == c
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            )),
                        ChoiceChip(
                          label: const Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 4),
                            Text('Otra'),
                          ]),
                          selected: _categoriaSeleccionada == 'Otra',
                          onSelected: (s) => s ? _cambiarCategoria('Otra') : null,
                          selectedColor: AppCSS.verdePrimario,
                          labelStyle: TextStyle(
                            color: _categoriaSeleccionada == 'Otra'
                                ? AppCSS.blanco
                                : AppCSS.textoOscuro,
                            fontWeight: _categoriaSeleccionada == 'Otra'
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    if (_categoriaSeleccionada == 'Otra') ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _categoriaOtraCtrl,
                        focusNode: _otraFocus,
                        textInputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.words,
                        onFieldSubmitted: (_) {
                          _otraFocus.unfocus();
                          _guardar();
                        },
                        decoration: const InputDecoration(
                          labelText: 'Escribe la categoría',
                          hintText: 'Fe, Amor, Esperanza...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        validator: (v) => v?.trim().isEmpty ?? true
                            ? 'Escribe una categoría'
                            : null,
                      ),
                    ],
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('⭐ Favorita'),
                      value: _favorito,
                      activeColor: AppCSS.verdePrimario,
                      onChanged: (v) => setState(() => _favorito = v),
                      dense: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('🌍 Pública'),
                      subtitle: const Text('Visible para todos los usuarios'),
                      value: _publico,
                      activeColor: AppCSS.verdePrimario,
                      onChanged: (v) => setState(() => _publico = v),
                      dense: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _guardando ? null : _guardar,
                        icon: _guardando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppCSS.blanco,
                                ),
                              )
                            : const Icon(Icons.save, size: 22),
                        label: Text(
                          _guardando ? 'Guardando...' : 'Guardar Cita',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppCSS.verdePrimario,
                          foregroundColor: AppCSS.blanco,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}