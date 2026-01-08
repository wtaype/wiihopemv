import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../recursos/colores.dart';
import '../recursos/constantes.dart';
import '../pantallas/principal.dart';
import 'auth_fb.dart';
import 'firestore_fb.dart';
import 'usuario.dart';
import 'login.dart';
import 'terminos.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final _form = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{
    for (var key in [
      'email',
      'usuario',
      'nombre',
      'apellidos',
      'grupo',
      'password',
      'confirmPassword',
    ])
      key: TextEditingController(),
  };
  final _focusNodes = <String, FocusNode>{
    'email': FocusNode(),
    'usuario': FocusNode(),
  };

  String _genero = 'masculino';
  bool _cargando = false, _registroCompletado = false;
  bool _verPassword = false, _verConfirm = false;
  bool _aceptoTerminos = false;

  final _validacion = <String, bool>{
    'emailExiste': false,
    'usuarioExiste': false,
    'validandoEmail': false,
    'validandoUsuario': false,
    'emailValidado': false,
    'usuarioValidado': false,
  };

  @override
  void initState() {
    super.initState();
    _configurarListeners();
  }

  void _configurarListeners() {
    // 🧹 Sanitización automática - COMPACTO
    _controllers['email']!.addListener(
      () => _sanitizar('email', AppFormatos.email),
    );
    _controllers['usuario']!.addListener(
      () => _sanitizar('usuario', AppFormatos.usuario),
    );

    // 🎯 Validación en blur - COMPACTO
    _focusNodes['email']!.addListener(
      () => !_focusNodes['email']!.hasFocus ? _validarEnBlur('email') : null,
    );
    _focusNodes['usuario']!.addListener(
      () =>
          !_focusNodes['usuario']!.hasFocus ? _validarEnBlur('usuario') : null,
    );
  }

  // 🧹 Método sanitización universal - REUTILIZABLE
  void _sanitizar(String key, String Function(String) formatear) {
    final controller = _controllers[key]!;
    final sanitized = formatear(controller.text);
    if (controller.text != sanitized) {
      controller.value = TextEditingValue(
        text: sanitized,
        selection: TextSelection.collapsed(offset: sanitized.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.verdeClaro,
      appBar: AppBar(
        title: Text('Registro', style: AppEstilos.textoBoton),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: AppConstantes.miwp,
        child: Form(
          key: _form,
          child: Column(
            children: [
              _construirLogo(),
              AppConstantes.espacioGrandeWidget,

              // 📧 Campos de validación - COMPACTOS
              _campoValidacion(
                'email',
                'Email',
                'tu@email.com',
                Icons.email,
                TextInputType.emailAddress,
              ),
              AppConstantes.espacioMedioWidget,
              _campoValidacion(
                'usuario',
                'Usuario',
                'Ingresa usuario',
                Icons.person,
              ),
              AppConstantes.espacioMedioWidget,

              // 📝 Campos normales - COMPACTOS
              Row(
                children: [
                  Expanded(
                    child: _campoNormal(
                      'nombre',
                      'Nombre',
                      'Tu nombre',
                      Icons.badge,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: _campoNormal(
                      'apellidos',
                      'Apellidos',
                      'Tus apellidos',
                    ),
                  ),
                ],
              ),
              AppConstantes.espacioMedioWidget,

              _campoNormal(
                'grupo',
                'Grupo',
                'familia, amigos, trabajo',
                Icons.group,
              ),
              AppConstantes.espacioMedioWidget,

              // 🚻 Género - COMPACTO
              DropdownButtonFormField<String>(
                value: _genero,
                decoration: _decoracion(
                  'Género',
                  'Selecciona tu género',
                  Icons.wc,
                ),
                items: ['masculino', 'femenino']
                    .map(
                      (g) => DropdownMenuItem(
                        value: g,
                        child: Text(g.capitalize()),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _genero = v!),
              ),
              AppConstantes.espacioMedioWidget,

              // 🔒 Contraseñas - COMPACTAS
              _campoPassword(
                'password',
                'Contraseña',
                _verPassword,
                () => setState(() => _verPassword = !_verPassword),
              ),
              AppConstantes.espacioMedioWidget,
              _campoPassword(
                'confirmPassword',
                'Confirmar Contraseña',
                _verConfirm,
                () => setState(() => _verConfirm = !_verConfirm),
              ),
              AppConstantes.espacioGrandeWidget,
              // 📝 AGREGAR: Checkbox Términos y Condiciones
              _checkboxTerminos(),
              AppConstantes.espacioGrandeWidget,
              // 🎯 Botón - COMPACTO
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _puedeRegistrar() ? _registrarUsuario : null,
                  icon: _cargando
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(Icons.person_add),
                  label: Text(_textoBoton()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _colorBoton(),
                    foregroundColor: _colorTextoBoton(),
                    disabledBackgroundColor: AppColores.verdeSuave,
                    disabledForegroundColor: AppColores.textoOscuro,
                    padding: EdgeInsets.symmetric(
                      vertical: AppConstantes.espacioMedio,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstantes.radioMedio,
                      ),
                    ),
                    elevation: _cargando ? 0 : 2,
                  ),
                ),
              ),
              AppConstantes.espacioMedioWidget,

              // 🔗 ENLACE CORTITO Y CENTRADO
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const PantallaLogin()),
                ),
                child: Text(
                  '¿Ya tienes cuenta? Inicia sesión',
                  style: AppEstilos.textoNormal.copyWith(
                    color: AppColores.enlace, // 🔥 Nuevo color
                  ),
                  textAlign: TextAlign.center, // 🔥 Centrado
                ),
              ),

              AppConstantes.espacioGrandeWidget,
            ],
          ),
        ),
      ),
    );
  }

  // 📝 AGREGAR: Checkbox términos - COMPACTO
  Widget _checkboxTerminos() => Row(
    children: [
      Checkbox(
        value: _aceptoTerminos,
        onChanged: (v) => setState(() => _aceptoTerminos = v ?? false),
        activeColor: AppColores.verdePrimario,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      Expanded(
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PantallaTerminos()),
          ),
          child: Text.rich(
            TextSpan(
              text: 'Acepto ',
              style: AppEstilos.textoNormal,
              children: [
                TextSpan(
                  text: 'términos y condiciones',
                  style: AppEstilos.textoNormal.copyWith(
                    color: AppColores.enlace,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  // 🎨 Logo - USANDO CONSTANTE
  Widget _construirLogo() => Container(
    width: double.infinity,
    padding: AppConstantes.miwpL,
    decoration: BoxDecoration(
      color: AppColores.verdeSuave,
      borderRadius: BorderRadius.circular(AppConstantes.radioMedio),
      boxShadow: [
        BoxShadow(
          color: AppColores.verdePrimario.withOpacity(0.2),
          blurRadius: 10,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      children: [
        AppConstantes.miLogoCircular,
        AppConstantes.espacioChicoWidget,
        Text(AppConstantes.nombreApp, style: AppEstilos.tituloMedio),
        Text('Únete a la familia smile 😊', style: AppEstilos.textoNormal),
      ],
    ),
  );

  // 📝 Campo validación - COMPACTO
  Widget _campoValidacion(
    String key,
    String label,
    String hint,
    IconData icon, [
    TextInputType? keyboard,
  ]) {
    final validando = _validacion['validando${key.capitalize()}'] ?? false;
    final tieneError = _validacion['${key}Existe'] ?? false;
    final esExito = (_validacion['${key}Validado'] ?? false) && !tieneError;

    return TextFormField(
      controller: _controllers[key]!,
      focusNode: _focusNodes[key],
      keyboardType: keyboard,
      validator: key == 'email' ? AppValidadores.email : AppValidadores.usuario,
      style: AppEstilos.textoNormal,
      inputFormatters: key == 'email'
          ? [FilteringTextInputFormatter.deny(RegExp(r'\s'))]
          : key == 'usuario'
          ? [
              FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9_]')),
              LowerCaseTextFormatter(),
            ]
          : null,
      decoration: tieneError
          ? VdError.decoration(
              label: label,
              hint: hint,
              icon: icon,
              suffixIcon: validando ? AppWidgets.cargando(size: 12) : null,
            )
          : esExito
          ? VdGreen.decoration(
              label: label,
              hint: hint,
              icon: icon,
              suffixIcon: validando ? AppWidgets.cargando(size: 12) : null,
            )
          : _decoracion(
              label,
              hint,
              icon,
              validando
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 3.5,
                        color: AppColores.verdePrimario,
                      ),
                    )
                  : null,
            ),
    );
  }

  // 📝 Campo normal - UNA LÍNEA
  Widget _campoNormal(
    String key,
    String label,
    String hint, [
    IconData? icon,
  ]) => TextFormField(
    controller: _controllers[key]!,
    validator: (v) => AppValidadores.requerido(v, label),
    style: AppEstilos.textoNormal,
    decoration: _decoracion(label, hint, icon ?? Icons.edit),
  );

  // 🔒 Campo password - COMPACTO
  Widget _campoPassword(
    String key,
    String label,
    bool mostrar,
    VoidCallback onToggle,
  ) => TextFormField(
    controller: _controllers[key]!,
    obscureText: !mostrar,
    validator: key == 'password'
        ? AppValidadores.password
        : (v) => AppValidadores.requerido(v, label),
    style: AppEstilos.textoNormal,
    decoration: _decoracion(
      label,
      '••••••••',
      Icons.lock,
      IconButton(
        icon: Icon(
          mostrar ? Icons.visibility : Icons.visibility_off,
          color: AppColores.verdePrimario,
        ),
        onPressed: onToggle,
      ),
    ),
  );

  // 🎨 Decoración universal - REUTILIZABLE
  InputDecoration _decoracion(
    String label,
    String hint,
    IconData icon, [
    Widget? suffixIcon,
  ]) => InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon, color: AppColores.verdePrimario),
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstantes.radioMedio),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstantes.radioMedio),
      borderSide: BorderSide(color: AppColores.verdePrimario, width: 2),
    ),
    filled: true,
    fillColor: Colors.white,
  );

  // 🎯 Métodos de estado del botón - COMPACTOS
  String _textoBoton() => _registroCompletado
      ? '¡Cuenta Creada! ✅'
      : _cargando
      ? 'Registrando...'
      : 'Crear Cuenta';
  Color _colorBoton() => _registroCompletado
      ? AppColores.exito
      : _puedeRegistrar()
      ? AppColores.verdePrimario
      : AppColores.verdeSuave;
  Color _colorTextoBoton() => _puedeRegistrar() || _registroCompletado
      ? Colors.white
      : AppColores.textoOscuro;

  // 🎯 Validación en blur - UNIVERSAL
  void _validarEnBlur(String tipo) async {
    final valor = _controllers[tipo]!.text.trim();
    final tipoCapitalizado = tipo.capitalize();

    setState(() {
      _validacion['${tipo}Validado'] = false;
      _validacion['${tipo}Existe'] = false;
      _validacion['validando$tipoCapitalizado'] = true;
    });

    if (valor.isEmpty || valor.length < 3) {
      setState(() => _validacion['validando$tipoCapitalizado'] = false);
      return;
    }

    final existe = tipo == 'email'
        ? await DatabaseServicio.emailExiste(valor)
        : await DatabaseServicio.usuarioExiste(valor);

    if (mounted) {
      setState(() {
        _validacion['${tipo}Existe'] = existe;
        _validacion['${tipo}Validado'] = true;
        _validacion['validando$tipoCapitalizado'] = false;
      });
    }
  }

  // 🛡️ Verificar si puede registrar - COMPACTO
  bool _puedeRegistrar() =>
      !_cargando &&
      !_registroCompletado &&
      !(_validacion['emailExiste'] ?? true) &&
      !(_validacion['usuarioExiste'] ?? true) &&
      (_validacion['emailValidado'] ?? false) &&
      (_validacion['usuarioValidado'] ?? false) &&
      _controllers.values.every((c) => c.text.isNotEmpty) &&
      _controllers['password']!.text.length >= 6 &&
      _controllers['confirmPassword']!.text == _controllers['password']!.text &&
      _aceptoTerminos; // 🔥 AGREGAR ESTA LÍNEA

  // 🚀 Registrar usuario - COMPACTO
  void _registrarUsuario() async {
    if (!_form.currentState!.validate() || !_puedeRegistrar()) return;

    setState(() => _cargando = true);

    try {
      // 1. 🐰 Auth
      final user = await AuthServicio.crearCuenta(
        _controllers['email']!.text,
        _controllers['password']!.text,
      );

      // 2. 📝 Usuario
      final usuario = Usuario.nuevo(
        email: _controllers['email']!.text,
        usuario: _controllers['usuario']!.text,
        nombre: _controllers['nombre']!.text,
        apellidos: _controllers['apellidos']!.text,
        grupo: _controllers['grupo']!.text,
        genero: _genero,
        uid: user.uid,
      );

      // 3. 🐢 Firestore
      await DatabaseServicio.guardarUsuario(usuario);

      // 4. ✅ Éxito
      setState(() => _registroCompletado = true);
      _mostrarMensaje('¡Cuenta creada exitosamente! 🎉', AppColores.exito);

      await Future.delayed(AppConstantes.tiempoCarga);
      if (mounted)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const PantallaPrincipal(),
          ), // 🔥 CAMBIAR
        );
    } catch (e) {
      _mostrarMensaje(
        e.toString().replaceAll('Exception: ', ''),
        AppColores.error,
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  // 🎯 Mostrar mensaje - UNIVERSAL
  void _mostrarMensaje(String mensaje, Color color) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );

  @override
  void dispose() {
    _controllers.values.forEach((c) => c.dispose());
    _focusNodes.values.forEach((n) => n.dispose());
    super.dispose();
  }
}

// 🎯 Extensions
extension StringExtension on String {
  String capitalize() =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
}

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => TextEditingValue(
    text: newValue.text.toLowerCase(),
    selection: newValue.selection,
  );
}
