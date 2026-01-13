import 'package:flutter/material.dart';
import 'wiauth.dart';
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
      backgroundColor: AuthColores.verdeClaro,
      appBar: AppBar(
        title: Text('Recuperar Contraseña', style: AuthEstilos.textoBoton),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => PantallaLogin()),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AuthConstantes.espacioMedio,
        ),
        child: Form(
          key: _form,
          child: Column(
            children: [
              AuthConstantes.espacioGrandeWidget,

              // 🎨 Logo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AuthConstantes.espacioGrande),
                decoration: BoxDecoration(
                  color: AuthColores.verdeSuave,
                  borderRadius: BorderRadius.circular(
                    AuthConstantes.radioMedio,
                  ),
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
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AuthColores.verdePrimario,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_reset,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    AuthConstantes.espacioChicoWidget,
                    Text('Recuperar Contraseña', style: AuthEstilos.subtitulo),
                    Text(
                      'Te ayudamos a recuperarla 🔑',
                      style: AuthEstilos.textoNormal,
                    ),
                  ],
                ),
              ),

              AuthConstantes.espacioGrandeWidget,

              // 📧 Campo email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: AuthValidadores.email,
                style: AuthEstilos.textoNormal,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'tu@email.com',
                  prefixIcon: Icon(
                    Icons.email,
                    color: AuthColores.verdePrimario,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AuthConstantes.radioMedio,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AuthConstantes.radioMedio,
                    ),
                    borderSide: BorderSide(
                      color: AuthColores.verdePrimario,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              AuthConstantes.espacioMedioWidget,

              // 💡 Información
              Container(
                padding: const EdgeInsets.all(AuthConstantes.espacioMedio),
                decoration: BoxDecoration(
                  color: AuthColores.verdeSuave.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(
                    AuthConstantes.radioChico,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AuthColores.verdePrimario),
                    const SizedBox(width: AuthConstantes.espacioChico),
                    Expanded(
                      child: Text(
                        'Te enviaremos un email con instrucciones para restablecer tu contraseña',
                        style: AuthEstilos.textoChico,
                      ),
                    ),
                  ],
                ),
              ),

              AuthConstantes.espacioGrandeWidget,

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
                        ? AuthColores.verdePrimario
                        : AuthColores.verdeSuave,
                    foregroundColor: _puedeEnviar()
                        ? Colors.white
                        : AuthColores.textoOscuro,
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
                  ),
                ),
              ),

              AuthConstantes.espacioGrandeWidget,

              // 🔗 Volver al login
              TextButton.icon(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => PantallaLogin()),
                ),
                icon: Icon(Icons.arrow_back, color: AuthColores.verdePrimario),
                label: Text(
                  'Volver al Login',
                  style: TextStyle(color: AuthColores.verdePrimario),
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
        AuthColores.verdePrimario,
      );

      await Future.delayed(AuthConstantes.animacionLenta);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PantallaLogin()),
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
    _emailController.dispose();
    super.dispose();
  }
}
