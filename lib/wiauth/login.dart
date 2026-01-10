import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widev.dart';
import '../pantallas/principal.dart';
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
      // 🔥 SOLO quitar espacios, permitir todo lo demás
      final sanitizado = texto.replaceAll(RegExp(r'\s+'), '').toLowerCase();
      if (texto != sanitizado) {
        _controllers['emailOUsuario']!.value = TextEditingValue(
          text: sanitizado,
          selection: TextSelection.collapsed(offset: sanitizado.length),
        );
      }
    });

    // 🎯 Activar botón cuando ingrese email/usuario (no esperar password)
    _controllers['emailOUsuario']!.addListener(() => setState(() {}));
    _controllers['password']!.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.verdeClaro,
      appBar: AppBar(
        title: Text('Iniciar Sesión', style: AppEstilos.textoBoton),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: AppConstantes.miwp,
        child: Form(
          key: _form,
          child: Column(
            children: [
              AppConstantes.espacioMedioWidget,

              // 🎨 Tarjeta de bienvenida
              _construirTarjetaBienvenida(),
              AppConstantes.espacioGrandeWidget,

              // 📧 Email o Usuario
              _campoEmailUsuario(),
              AppConstantes.espacioMedioWidget,

              // 🔒 Contraseña
              _campoPassword(),
              AppConstantes.espacioMedioWidget,

              // ☑️ Recordar y Olvidé contraseña - EN UNA FILA
              _construirFilaRecordarOlvidar(),
              AppConstantes.espacioGrandeWidget,

              // 🎯 Botón Iniciar Sesión
              _botonIniciarSesion(),
              AppConstantes.espacioMedioWidget,

              // 📝 Botón Crear nueva cuenta
              _botonCrearCuenta(),
              AppConstantes.espacioGrandeWidget,

              // 📱 Versión de la app
              Text(
                'Versión ${AppConstantes.version}',
                style: AppEstilos.textoChico.copyWith(color: AppColores.gris),
              ),
              AppConstantes.espacioMedioWidget,
            ],
          ),
        ),
      ),
    );
  }

  // 🎨 Tarjeta de bienvenida - BONITA
  Widget _construirTarjetaBienvenida() => Container(
    width: double.infinity,
    padding: AppConstantes.miwpL,
    decoration: BoxDecoration(
      color: AppColores.verdeSuave,
      borderRadius: BorderRadius.circular(AppConstantes.radioMedio),
      boxShadow: [
        BoxShadow(
          color: AppColores.verdePrimario.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      children: [
        AppConstantes.miLogoCircular,
        AppConstantes.espacioChicoWidget,
        Text(AppConstantes.nombreApp, style: AppEstilos.tituloMedio),
        Text('¡Bienvenido de vuelta! 😊', style: AppEstilos.textoNormal),
      ],
    ),
  );

  // 📧 Campo Email o Usuario - COMPACTO
  Widget _campoEmailUsuario() => TextFormField(
    controller: _controllers['emailOUsuario']!,
    keyboardType: TextInputType.emailAddress,
    validator: (v) => AppValidadores.emailOUsuario(v),
    style: AppEstilos.textoNormal,
    inputFormatters: [
      // 🔥 SOLO denegar espacios, permitir -, ., @, etc.
      FilteringTextInputFormatter.deny(RegExp(r'\s')), // Solo sin espacios
    ],
    decoration: _decoracion(
      'Email o Usuario',
      'Ingresa email o usuario',
      Icons.person,
    ),
  );

  // 🔒 Campo Contraseña - COMPACTO
  Widget _campoPassword() => TextFormField(
    controller: _controllers['password']!,
    obscureText: !_verPassword,
    validator: (v) => AppValidadores.passwordLogin(v),
    style: AppEstilos.textoNormal,
    decoration: _decoracion(
      'Contraseña',
      '••••••••',
      Icons.lock,
      IconButton(
        icon: Icon(
          _verPassword ? Icons.visibility : Icons.visibility_off,
          color: AppColores.verdePrimario,
        ),
        onPressed: () => setState(() => _verPassword = !_verPassword),
      ),
    ),
  );

  // ☑️ Fila Recordar y Olvidé contraseña - COMO EN LA IMAGEN
  Widget _construirFilaRecordarOlvidar() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // ☑️ Recordar (izquierda)
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: _recordarme,
            onChanged: (v) => setState(() => _recordarme = v ?? false),
            activeColor: AppColores.verdePrimario,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Text('Recordar', style: AppEstilos.textoNormal),
        ],
      ),

      // 🔄 Olvidé contraseña (derecha)
      TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PantallaRecuperar()),
        ),
        child: Text(
          '¿Olvidaste contraseña?',
          style: AppEstilos.textoNormal.copyWith(
            color: AppColores.enlace, // 🔥 Usar color consistente
          ),
        ),
      ),
    ],
  );

  // 🎯 Botón Iniciar Sesión - SE ACTIVA CON EMAIL/USUARIO
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
            ? AppColores.verdePrimario
            : AppColores.verdeSuave,
        foregroundColor: _puedeLogin() ? Colors.white : AppColores.textoOscuro,
        disabledBackgroundColor: AppColores.verdeSuave,
        disabledForegroundColor: AppColores.textoOscuro,
        padding: EdgeInsets.symmetric(vertical: AppConstantes.espacioMedio),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstantes.radioMedio),
        ),
        elevation: _cargando ? 0 : 2,
      ),
    ),
  );

  // 📝 Botón Crear nueva cuenta - CON BORDES COMO EN LA IMAGEN
  Widget _botonCrearCuenta() => SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PantallaRegistro()),
      ),
      icon: Icon(Icons.person_add, color: AppColores.verdePrimario),
      label: Text(
        'Crear nueva cuenta',
        style: TextStyle(color: AppColores.verdePrimario),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColores.verdePrimario, width: 2),
        padding: EdgeInsets.symmetric(vertical: AppConstantes.espacioMedio),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstantes.radioMedio),
        ),
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

  // 🎯 Métodos de estado - OPTIMIZADOS
  String _textoBotonLogin() => _cargando ? 'Ingresando...' : 'Iniciar Sesión';

  // 🔥 BOTÓN SE ACTIVA SOLO CON EMAIL/USUARIO (no necesita password)
  bool _puedeLogin() =>
      !_cargando && _controllers['emailOUsuario']!.text.trim().length >= 3;

  // 🚀 Hacer login - OPTIMIZADO
  void _hacerLogin() async {
    // Validar que tenga email/usuario Y password
    if (_controllers['emailOUsuario']!.text.trim().isEmpty) {
      _mostrarMensaje('Ingresa tu email o usuario', AppColores.error);
      return;
    }

    if (_controllers['password']!.text.isEmpty) {
      _mostrarMensaje('Ingresa tu contraseña', AppColores.error);
      return;
    }

    setState(() => _cargando = true);

    try {
      // 🔑 Login usando el método original que SÍ funciona
      await AuthServicio.login(
        _controllers['emailOUsuario']!.text,
        _controllers['password']!.text,
      );

      // ✅ Éxito - Mensaje simple
      _mostrarMensaje('¡Bienvenido de vuelta! 😊', AppColores.exito);

      await Future.delayed(AppConstantes.animacionRapida);

      // 🏠 Navegar a gastos
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const PantallaPrincipal(),
          ), // 🔥 CAMBIAR
        );
      }
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
    super.dispose();
  }
}
