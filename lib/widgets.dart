import 'package:flutter/material.dart';
import 'widev.dart';

// 🎯 Botón principal que usamos mucho
class BotonPrincipal extends StatelessWidget {
  final String texto;
  final VoidCallback alPresionar;
  final IconData? icono;
  final bool estaCargando;
  final Color? colorFondo;

  const BotonPrincipal({
    super.key,
    required this.texto,
    required this.alPresionar,
    this.icono,
    this.estaCargando = false,
    this.colorFondo,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: estaCargando ? null : alPresionar,
      icon: estaCargando
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(icono ?? Icons.check),
      label: Text(texto),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorFondo ?? AppColores.verdePrimario,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstantes.espacioGrande,
          vertical: AppConstantes.espacioMedio,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstantes.radioMedio),
        ),
      ),
    );
  }
}

// 📝 Campo de texto guapo en español
class CampoTexto extends StatelessWidget {
  final String etiqueta;
  final String? pista;
  final IconData? icono;
  final bool esContrasena;
  final TextEditingController? controlador;
  final String? Function(String?)? validador;
  final TextInputType tipoTeclado;

  const CampoTexto({
    super.key,
    required this.etiqueta,
    this.pista,
    this.icono,
    this.esContrasena = false,
    this.controlador,
    this.validador,
    this.tipoTeclado = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlador,
      obscureText: esContrasena,
      validator: validador,
      keyboardType: tipoTeclado,
      style: AppEstilos.textoNormal,
      decoration: InputDecoration(
        labelText: etiqueta,
        hintText: pista,
        prefixIcon: icono != null
            ? Icon(icono, color: AppColores.verdePrimario)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstantes.radioMedio),
          borderSide: BorderSide(color: AppColores.verdeSecundario),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstantes.radioMedio),
          borderSide: BorderSide(color: AppColores.verdePrimario, width: 2),
        ),
        filled: true,
        fillColor: AppColores.blanco,
      ),
    );
  }
}

// 💳 Tarjeta bonita para mostrar información
class TarjetaInformacion extends StatelessWidget {
  final Widget contenido;
  final VoidCallback? alTocar;
  final Color? colorFondo;
  final double? elevacion;

  const TarjetaInformacion({
    super.key,
    required this.contenido,
    this.alTocar,
    this.colorFondo,
    this.elevacion = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevacion,
      color: colorFondo,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstantes.radioMedio),
      ),
      child: InkWell(
        onTap: alTocar,
        borderRadius: BorderRadius.circular(AppConstantes.radioMedio),
        child: Padding(
          padding: const EdgeInsets.all(AppConstantes.espacioMedio),
          child: contenido,
        ),
      ),
    );
  }
}

// 😢 Widget para cuando no hay datos disponibles
class SinDatos extends StatelessWidget {
  final String mensaje;
  final IconData icono;
  final String? textoBoton;
  final VoidCallback? accionBoton;

  const SinDatos({
    super.key,
    required this.mensaje,
    this.icono = Icons.inbox,
    this.textoBoton,
    this.accionBoton,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, size: 80, color: AppColores.verdeSecundario),
          const SizedBox(height: AppConstantes.espacioMedio),
          Text(
            mensaje,
            style: AppEstilos.subtitulo,
            textAlign: TextAlign.center,
          ),
          if (textoBoton != null && accionBoton != null) ...[
            const SizedBox(height: AppConstantes.espacioGrande),
            BotonPrincipal(
              texto: textoBoton!,
              alPresionar: accionBoton!,
              icono: Icons.refresh,
            ),
          ],
        ],
      ),
    );
  }
}

// 🍕 Helper para mostrar mensajes sabrosos
class MensajeHelper {
  static void mostrarExito(BuildContext contexto, String mensaje) {
    _mostrarMensaje(contexto, mensaje, esError: false);
  }

  static void mostrarError(BuildContext contexto, String mensaje) {
    _mostrarMensaje(contexto, mensaje, esError: true);
  }

  static void _mostrarMensaje(
    BuildContext contexto,
    String mensaje, {
    required bool esError,
  }) {
    ScaffoldMessenger.of(contexto).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              esError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: AppConstantes.espacioChico),
            Expanded(
              child: Text(
                mensaje,
                style: AppEstilos.textoNormal.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: esError
            ? Colors.red.shade600
            : AppColores.verdePrimario,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstantes.radioChico),
        ),
        duration: AppConstantes.animacionLenta,
      ),
    );
  }
}

// 🔄 Widget de carga bonito
class IndicadorCarga extends StatelessWidget {
  final String? mensaje;

  const IndicadorCarga({super.key, this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColores.verdePrimario),
          if (mensaje != null) ...[
            const SizedBox(height: AppConstantes.espacioMedio),
            Text(mensaje!, style: AppEstilos.textoNormal),
          ],
        ],
      ),
    );
  }
}
