import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class UploadSoundScreen extends StatefulWidget {
  @override
  _UploadSoundScreenState createState() => _UploadSoundScreenState();
}

class _UploadSoundScreenState extends State<UploadSoundScreen> {
  FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> uploadFile() async {
    // Abre el selector de archivos
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );

    if (result != null) {
      // Obtiene el archivo seleccionado
      String? filePath = result.files.single.path;

      if (filePath != null) {
        File file = File(filePath);

        // Sube el archivo a Firebase Storage
        try {
          await storage.ref('sounds/${result.files.single.name}').putFile(file);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Archivo subido exitosamente')));
        } catch (e) {
          print('Error al subir el archivo: $e');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al subir el archivo')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Subir Sonido')),
      body: Center(
        child: ElevatedButton(
          onPressed: uploadFile,
          child: Text('Subir MP3'),
        ),
      ),
    );
  }
}
