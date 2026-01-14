import 'dart:async';
import 'package:flutter/material.dart';
import '../../wicss.dart';
import 'biblia.dart';

class BuscadorBiblia extends StatefulWidget {
  final List<AudioLibro> libros;
  final Function(AudioLibro, int) onSeleccionar;
  final VoidCallback onCerrar;

  const BuscadorBiblia({
    super.key,
    required this.libros,
    required this.onSeleccionar,
    required this.onCerrar,
  });

  @override
  State<BuscadorBiblia> createState() => _BuscadorBibliaState();
}

class _BuscadorBibliaState extends State<BuscadorBiblia> {
  final _controller = TextEditingController();
  List<Map<String, dynamic>> _resultados = [];
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _buscar(String query) {
    _debounce?.cancel();
    if (query.isEmpty) {
      setState(() => _resultados = []);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () {
      final q = query.toLowerCase();
      final resultados = <Map<String, dynamic>>[];

      for (final libro in widget.libros) {
        if (libro.nombre.toLowerCase().contains(q)) {
          for (var i = 0; i < libro.capitulos; i++) {
            resultados.add({
              'libro': libro,
              'capitulo': i,
              'texto': '${libro.nombre} ${i + 1}',
            });
            if (resultados.length >= 20) break;
          }
        }
        if (resultados.length >= 20) break;
      }

      setState(() => _resultados = resultados);
    });
  }

  @override
  Widget build(BuildContext context) => Container(
    color: AppCSS.blanco,
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: AppCSS.verdePrimario,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppCSS.blanco),
                onPressed: widget.onCerrar,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  onChanged: _buscar,
                  style: const TextStyle(color: AppCSS.blanco),
                  decoration: InputDecoration(
                    hintText: 'Buscar...',
                    hintStyle: TextStyle(color: AppCSS.blanco.withOpacity(0.7)),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close, color: AppCSS.blanco),
                  onPressed: () {
                    _controller.clear();
                    _buscar('');
                  },
                ),
            ],
          ),
        ),
        Expanded(
          child: _controller.text.isEmpty
              ? const Center(child: Icon(Icons.search, size: 64, color: AppCSS.gris))
              : _resultados.isEmpty
                  ? const Center(child: Text('Sin resultados'))
                  : ListView.builder(
                      itemCount: _resultados.length,
                      itemBuilder: (_, i) {
                        final item = _resultados[i];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.play_circle_outline, color: AppCSS.verdePrimario, size: 20),
                          title: Text(item['texto'], style: AppEstilos.textoChico),
                          onTap: () {
                            widget.onSeleccionar(item['libro'], item['capitulo']);
                            widget.onCerrar();
                          },
                        );
                      },
                    ),
        ),
      ],
    ),
  );
}