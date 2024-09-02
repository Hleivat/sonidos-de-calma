// lib/auto_mode_config.dart
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AutoModeConfig extends StatefulWidget {
  final Function(String) onSoundSelected;

  AutoModeConfig({required this.onSoundSelected});

  @override
  _AutoModeConfigState createState() => _AutoModeConfigState();
}

class _AutoModeConfigState extends State<AutoModeConfig> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  List<Reference> fileReferences = [];
  String? selectedFileName;

  @override
  void initState() {
    super.initState();
    _loadAudioFiles();
  }

    Future<void> _loadAudioFiles() async {
    try {
      ListResult result = await storage.ref('sounds').listAll();
      setState(() {
        fileReferences = result.items;
      });
    } catch (e) {
      print('Error al cargar los archivos de audio: $e');
    }
  }

  void _selectSound(String fileName) {
    setState(() {
      selectedFileName = fileName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurar Sonido Automático'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (fileReferences.isEmpty)
              Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView.builder(
                  itemCount: fileReferences.length,
                  itemBuilder: (context, index) {
                    String fileName = fileReferences[index].name;
                    return ListTile(
                      title: Text(fileName),
                      leading: Radio<String>(
                        value: fileName,
                        groupValue: selectedFileName,
                        onChanged: (value) {
                          _selectSound(value!);
                        },
                      ),
                      onTap: () => _selectSound(fileName),
                    );
                  },
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedFileName != null
                  ? () {
                      widget.onSoundSelected(selectedFileName!);
                      Navigator.pop(context);
                    }
                  : null,
              child: Text('Guardar Configuración'),
            ),
          ],
        ),
      ),
    );
  }
}
