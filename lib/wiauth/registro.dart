import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'wiauth.dart';
import '../pantallas/principal.dart';
import '../../wii.dart';
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
      () => _sanitizar('email', AuthFormatos.email),
    );
    _controllers['usuario']!.addListener(
      () => _sanitizar('usuario', AuthFormatos.usuario),
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
      backgroundColor: AuthColores.verdeClaro,
      appBar: AppBar(
        title: Text('Registro', style: AuthEstilos.textoBoton),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AuthConstantes.espacioMedio,
        ),
        child: Form(
          key: _form,
          child: Column(
            children: [
              _construirLogo(),
              AuthConstantes.espacioGrandeWidget,

              // 📧 Campos de validación - COMPACTOS
              _campoValidacion(
                'email',
                'Email',
                'tu@email.com',
                Icons.email,
                TextInputType.emailAddress,
              ),
              AuthConstantes.espacioMedioWidget,
              _campoValidacion(
                'usuario',
                'Usuario',
                'Ingresa usuario',
                Icons.person,
              ),
              AuthConstantes.espacioMedioWidget,

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
              AuthConstantes.espacioMedioWidget,

              _campoNormal(
                'grupo',
                'Grupo',
                'familia, amigos, trabajo',
                Icons.group,
              ),
              AuthConstantes.espacioMedioWidget,

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
              AuthConstantes.espacioMedioWidget,

              // 🔒 Contraseñas - COMPACTAS
              _campoPassword(
                'password',
                'Contraseña',
                _verPassword,
                () => setState(() => _verPassword = !_verPassword),
              ),
              AuthConstantes.espacioMedioWidget,
              _campoPassword(
                'confirmPassword',
                'Confirmar Contraseña',
                _verConfirm,
                () => setState(() => _verConfirm = !_verConfirm),
              ),
              AuthConstantes.espacioGrandeWidget,
              // 📝 Checkbox Términos y Condiciones
              _checkboxTerminos(),
              AuthConstantes.espacioGrandeWidget,
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
                    disabledBackgroundColor: AuthColores.verdeSuave,
                    disabledForegroundColor: AuthColores.textoOscuro,
                    padding: EdgeInsets.symmetric(
                      vertical: AuthConstantes.espacioMedio,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AuthConstantes.radioMedio,
                      ),
                    ),
                    elevation: _cargando ? 0 : 2,
                  ),
                ),
              ),
              AuthConstantes.espacioMedioWidget,

              // 🔗 ENLACE CORTITO Y CENTRADO
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const PantallaLogin()),
                ),
                child: Text(
                  '¿Ya tienes cuenta? Inicia sesión',
                  style: AuthEstilos.textoNormal.copyWith(
                    color: AuthColores.enlace,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              AuthConstantes.espacioGrandeWidget,
            ],
          ),
        ),
      ),
    );
  }

  // 📝 Checkbox términos - COMPACTO
  Widget _checkboxTerminos() => Row(
    children: [
      Checkbox(
        value: _aceptoTerminos,
        onChanged: (v) => setState(() => _aceptoTerminos = v ?? false),
        activeColor: AuthColores.verdePrimario,
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
              style: AuthEstilos.textoNormal,
              children: [
                TextSpan(
                  text: 'términos y condiciones',
                  style: AuthEstilos.textoNormal.copyWith(
                    color: AuthColores.enlace,
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
    padding: const EdgeInsets.all(AuthConstantes.espacioGrande),
    decoration: BoxDecoration(
      color: AuthColores.verdeSuave,
      borderRadius: BorderRadius.circular(AuthConstantes.radioMedio),
      boxShadow: [
        BoxShadow(
          color: AuthColores.verdePrimario.withOpacity(0.2),
          blurRadius: 10,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      children: [
        AuthConstantes.logoCircular,
        AuthConstantes.espacioChicoWidget,
        Text('${wii.app}', style: AuthEstilos.subtitulo),
        Text('Únete a la familia smile 😊', style: AuthEstilos.textoNormal),
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
      validator: key == 'email'
          ? AuthValidadores.email
          : AuthValidadores.usuario,
      style: AuthEstilos.textoNormal,
      inputFormatters: key == 'email'
          ? [FilteringTextInputFormatter.deny(RegExp(r'\s'))]
          : key == 'usuario'
          ? [
              FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9_]')),
              LowerCaseTextFormatter(),
            ]
          : null,
      decoration:
          _decoracion(
            label,
            hint,
            icon,
            validando
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.5,
                      color: tieneError
                          ? AuthColores.error
                          : esExito
                          ? AuthColores.verdePrimario
                          : AuthColores.gris,
                    ),
                  )
                : tieneError
                ? Icon(Icons.error, color: AuthColores.error)
                : esExito
                ? Icon(Icons.check_circle, color: AuthColores.verdePrimario)
                : null,
          ).copyWith(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AuthConstantes.radioMedio),
              borderSide: BorderSide(
                color: tieneError
                    ? AuthColores.error
                    : esExito
                    ? AuthColores.verdePrimario
                    : AuthColores.gris,
                width: tieneError || esExito ? 2 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AuthConstantes.radioMedio),
              borderSide: BorderSide(
                color: tieneError
                    ? AuthColores.error
                    : AuthColores.verdePrimario,
                width: 2,
              ),
            ),
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
    validator: (v) => v?.trim().isEmpty ?? true ? '$label requerido' : null,
    style: AuthEstilos.textoNormal,
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
        ? AuthValidadores.password
        : (v) => v?.trim().isEmpty ?? true ? '$label requerido' : null,
    style: AuthEstilos.textoNormal,
    decoration: _decoracion(
      label,
      '••••••••',
      Icons.lock,
      IconButton(
        icon: Icon(
          mostrar ? Icons.visibility : Icons.visibility_off,
          color: AuthColores.verdePrimario,
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
    prefixIcon: Icon(icon, color: AuthColores.verdePrimario),
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AuthConstantes.radioMedio),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AuthConstantes.radioMedio),
      borderSide: BorderSide(color: AuthColores.verdePrimario, width: 2),
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
      ? AuthColores.verdePrimario
      : _puedeRegistrar()
      ? AuthColores.verdePrimario
      : AuthColores.verdeSuave;
  Color _colorTextoBoton() => _puedeRegistrar() || _registroCompletado
      ? Colors.white
      : AuthColores.textoOscuro;

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
      _aceptoTerminos;

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
      _mostrarMensaje(
        '¡Cuenta creada exitosamente! 🎉',
        AuthColores.verdePrimario,
      );

      await Future.delayed(AuthConstantes.animacionLenta);
      if (mounted)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PantallaPrincipal()),
        );
    } catch (e) {
      _mostrarMensaje(
        e.toString().replaceAll('Exception: ', ''),
        AuthColores.error,
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
