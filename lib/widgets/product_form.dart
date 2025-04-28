import 'package:flutter/material.dart';

class ProductForm extends StatefulWidget {
  final Function(String name, Map<String, dynamic> data) onSave;
  final dynamic product;

  const ProductForm({Key? key, required this.onSave, this.product}) : super(key: key);

  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dataController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _dataController = TextEditingController(text: widget.product?.data.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final dataString = _dataController.text;

      try {
        // Verifica si el dataString tiene un formato adecuado
        if (dataString.isNotEmpty) {
          // Intenta convertirlo a un Map
          final parsedData = evalStringToMap(dataString);

          // Verifica si el resultado es un Map válido
          if (parsedData is Map<String, dynamic>) {
            final data = Map<String, dynamic>.from(parsedData);
            widget.onSave(name, data);
          } else {
            throw FormatException('Los datos no tienen el formato correcto');
          }
        } else {
          widget.onSave(name, {});
        }
      } catch (e) {
        // Muestra un mensaje de error si ocurre algo al parsear los datos
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al parsear los datos: ${e.toString()}')),
        );
      }
    }
  }


  Map<String, dynamic> evalStringToMap(String input) {
    // Limpiar solo las llaves al principio y al final, no el resto de comillas
    final clean = input.replaceAll(RegExp(r"^[\{\}]*|[\{\}]*$"), '').trim();

    // Dividir la cadena por comas (asumiendo que los valores no contienen comas internas)
    final parts = clean.split(',');

    final map = <String, dynamic>{};

    for (var part in parts) {
      if (part.contains(':')) {
        final keyValue = part.split(':');

        // Limpiar posibles espacios extra y asegurar que las claves y valores sean adecuadamente asignados
        final key = keyValue[0].trim();
        final value = keyValue[1].trim();

        // Si el valor tiene comillas, quitarlas
        if (value.startsWith("'") && value.endsWith("'") || value.startsWith('"') && value.endsWith('"')) {
          map[key] = value.substring(1, value.length - 1);  // Eliminar comillas
        } else {
          map[key] = value;
        }
      }
    }

    return map;
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _dataController,
                decoration: InputDecoration(labelText: 'Datos (formato key:value separado por comas)'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Guardar'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
