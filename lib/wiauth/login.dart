import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'wiauth.dart';
import '../pantallas/principal.dart';
import '../../wii.dart';
import 'auth_fb.dart';
import 'registro.dart';
import 'recuperar.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _form = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{
    'emailOUsuario': TextEditingController(),
    'password': TextEditingController(),
  };

  bool _cargando = false;
  bool _verPassword = false;
  bool _recordarme = false;

  @override
  void initState() {
    super.initState();
    _configurarListeners();
  }

  void _configurarListeners() {
    // 🧹 Sanitización MÁS FLEXIBLE para email/usuario en login
    _controllers['emailOUsuario']!.addListener(() {
      final texto = _controllers['emailOUsuario']!.text;
      final sanitizado = texto.replaceAll(RegExp(r'\s+'), '').toLowerCase();
      if (texto != sanitizado) {
        _controllers['emailOUsuario']!.value = TextEditingValue(
          text: sanitizado,
          selection: TextSelection.collapsed(offset: sanitizado.length),
        );
      }
    });

    _controllers['emailOUsuario']!.addListener(() => setState(() {}));
    _controllers['password']!.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthColores.verdeClaro,
      appBar: AppBar(
        title: Text('Iniciar Sesión', style: AuthEstilos.textoBoton),
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
              AuthConstantes.espacioMedioWidget,
              _construirTarjetaBienvenida(),
              AuthConstantes.espacioGrandeWidget,
              _campoEmailUsuario(),
              AuthConstantes.espacioMedioWidget,
              _campoPassword(),
              AuthConstantes.espacioMedioWidget,
              _construirFilaRecordarOlvidar(),
              AuthConstantes.espacioGrandeWidget,
              _botonIniciarSesion(),
              AuthConstantes.espacioMedioWidget,
              _botonCrearCuenta(),
              AuthConstantes.espacioGrandeWidget,
              Text(
                '${wii.app} ${wii.version}',
                style: AuthEstilos.textoChico.copyWith(color: AuthColores.gris),
              ),
              AuthConstantes.espacioMedioWidget,
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirTarjetaBienvenida() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AuthConstantes.espacioGrande),
    decoration: BoxDecoration(
      color: AuthColores.verdeSuave,
      borderRadius: BorderRadius.circular(AuthConstantes.radioMedio),
      boxShadow: [
        BoxShadow(
          color: AuthColores.verdePrimario.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      children: [
        AuthConstantes.logoCircular,
        AuthConstantes.espacioChicoWidget,
        Text('${wii.app}', style: AuthEstilos.subtitulo),
        Text('¡Bienvenido de vuelta! 😊', style: AuthEstilos.textoNormal),
      ],
    ),
  );

  Widget _campoEmailUsuario() => TextFormField(
    controller: _controllers['emailOUsuario']!,
    keyboardType: TextInputType.emailAddress,
    validator: AuthValidadores.emailOUsuario,
    style: AuthEstilos.textoNormal,
    inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
    decoration: _decoracion(
      'Email o Usuario',
      'Ingresa email o usuario',
      Icons.person,
    ),
  );

  Widget _campoPassword() => TextFormField(
    controller: _controllers['password']!,
    obscureText: !_verPassword,
    validator: AuthValidadores.passwordLogin,
    style: AuthEstilos.textoNormal,
    decoration: _decoracion(
      'Contraseña',
      '••••••••',
      Icons.lock,
      IconButton(
        icon: Icon(
          _verPassword ? Icons.visibility : Icons.visibility_off,
          color: AuthColores.verdePrimario,
        ),
        onPressed: () => setState(() => _verPassword = !_verPassword),
      ),
    ),
  );

  Widget _construirFilaRecordarOlvidar() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: _recordarme,
            onChanged: (v) => setState(() => _recordarme = v ?? false),
            activeColor: AuthColores.verdePrimario,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Text('Recordar', style: AuthEstilos.textoNormal),
        ],
      ),
      TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PantallaRecuperar()),
        ),
        child: Text(
          '¿Olvidaste contraseña?',
          style: AuthEstilos.textoNormal.copyWith(color: AuthColores.enlace),
        ),
      ),
    ],
  );

  Widget _botonIniciarSesion() => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: _puedeLogin() ? _hacerLogin : null,
      icon: _cargando
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(Icons.login),
      label: Text(_textoBotonLogin()),
      style: ElevatedButton.styleFrom(
        backgroundColor: _puedeLogin()
            ? AuthColores.verdePrimario
            : AuthColores.verdeSuave,
        foregroundColor: _puedeLogin() ? Colors.white : AuthColores.textoOscuro,
        disabledBackgroundColor: AuthColores.verdeSuave,
        disabledForegroundColor: AuthColores.textoOscuro,
        padding: EdgeInsets.symmetric(vertical: AuthConstantes.espacioMedio),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AuthConstantes.radioMedio),
        ),
        elevation: _cargando ? 0 : 2,
      ),
    ),
  );

  Widget _botonCrearCuenta() => SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PantallaRegistro()),
      ),
      icon: Icon(Icons.person_add, color: AuthColores.verdePrimario),
      label: Text(
        'Crear nueva cuenta',
        style: TextStyle(color: AuthColores.verdePrimario),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AuthColores.verdePrimario, width: 2),
        padding: EdgeInsets.symmetric(vertical: AuthConstantes.espacioMedio),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AuthConstantes.radioMedio),
        ),
      ),
    ),
  );

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

  String _textoBotonLogin() => _cargando ? 'Ingresando...' : 'Iniciar Sesión';

  bool _puedeLogin() =>
      !_cargando && _controllers['emailOUsuario']!.text.trim().length >= 3;

  void _hacerLogin() async {
    if (_controllers['emailOUsuario']!.text.trim().isEmpty) {
      _mostrarMensaje('Ingresa tu email o usuario', AuthColores.error);
      return;
    }

    if (_controllers['password']!.text.isEmpty) {
      _mostrarMensaje('Ingresa tu contraseña', AuthColores.error);
      return;
    }

    setState(() => _cargando = true);

    try {
      await AuthServicio.login(
        _controllers['emailOUsuario']!.text,
        _controllers['password']!.text,
      );

      _mostrarMensaje('¡Bienvenido de vuelta! 😊', AuthColores.verdePrimario);

      await Future.delayed(AuthConstantes.animacionRapida);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PantallaPrincipal()),
        );
      }
    } catch (e) {
      _mostrarMensaje(
        e.toString().replaceAll('Exception: ', ''),
        AuthColores.error,
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

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
    super.dispose();
  }
}
