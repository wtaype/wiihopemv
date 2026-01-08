import 'package:flutter/material.dart';
import '../recursos/colores.dart';
import '../recursos/constantes.dart';
import 'auth_fb.dart';
import 'login.dart';

class PantallaRecuperar extends StatefulWidget {
  const PantallaRecuperar({super.key});

  @override
  State<PantallaRecuperar> createState() => _PantallaRecuperarState();
}

class _PantallaRecuperarState extends State<PantallaRecuperar> {
  final _form = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _cargando = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.verdeClaro,
      appBar: AppBar(
        title: Text('Recuperar Contraseña', style: AppEstilos.textoBoton),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => PantallaLogin()),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppConstantes.miwp,
        child: Form(
          key: _form,
          child: Column(
            children: [
              AppConstantes.espacioGrandeWidget,

              // 🎨 Logo
              Container(
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
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColores.verdePrimario,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_reset,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    AppConstantes.espacioChicoWidget,
                    Text('Recuperar Contraseña', style: AppEstilos.tituloMedio),
                    Text(
                      'Te ayudamos a recuperarla 🔑',
                      style: AppEstilos.textoNormal,
                    ),
                  ],
                ),
              ),

              AppConstantes.espacioGrandeWidget,

              // 📧 Campo email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: AppValidadores.email,
                style: AppEstilos.textoNormal,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'tu@email.com',
                  prefixIcon: Icon(
                    Icons.email,
                    color: AppColores.verdePrimario,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstantes.radioMedio,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstantes.radioMedio,
                    ),
                    borderSide: BorderSide(
                      color: AppColores.verdePrimario,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              AppConstantes.espacioMedioWidget,

              // 💡 Información
              Container(
                padding: AppConstantes.miwp,
                decoration: BoxDecoration(
                  color: AppColores.verdeSuave.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(AppConstantes.radioChico),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColores.verdePrimario),
                    AppConstantes.espacioChicoWidget,
                    Expanded(
                      child: Text(
                        'Te enviaremos un email con instrucciones para restablecer tu contraseña',
                        style: AppEstilos.textoChico,
                      ),
                    ),
                  ],
                ),
              ),

              AppConstantes.espacioGrandeWidget,

              // 🎯 Botón enviar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _puedeEnviar() ? _enviarRecuperacion : null,
                  icon: _cargando
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(Icons.send),
                  label: Text(_cargando ? 'Enviando...' : 'Enviar Email'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _puedeEnviar()
                        ? AppColores.verdePrimario
                        : AppColores.verdeSuave,
                    foregroundColor: _puedeEnviar()
                        ? Colors.white
                        : AppColores.textoOscuro,
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
                  ),
                ),
              ),

              AppConstantes.espacioGrandeWidget,

              // 🔗 Volver al login
              TextButton.icon(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => PantallaLogin()),
                ),
                icon: Icon(Icons.arrow_back, color: AppColores.verdePrimario),
                label: Text(
                  'Volver al Login',
                  style: TextStyle(color: AppColores.verdePrimario),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _puedeEnviar() => !_cargando && _emailController.text.isNotEmpty;

  void _enviarRecuperacion() async {
    if (!_form.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      await AuthServicio.restablecerPassword(_emailController.text);

      _mostrarMensaje(
        'Email de recuperación enviado. Revisa tu bandeja de entrada 📧',
        AppColores.exito,
      );

      await Future.delayed(AppConstantes.animacionLenta);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PantallaLogin()),
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
    _emailController.dispose();
    super.dispose();
  }
}
