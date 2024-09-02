// lib/automatic_mode.dart
import 'package:flutter/material.dart';
import 'package:new_project_directory/auto_mode_config.dart';
import 'package:new_project_directory/detection_service.dart';

class AutomaticMode extends StatefulWidget {
  final DetectionService detectionService;

  AutomaticMode({required this.detectionService}); // Asegúrate de que el constructor acepte detectionService

  @override
  _AutomaticModeState createState() => _AutomaticModeState();
}

class _AutomaticModeState extends State<AutomaticMode> {
  String? selectedSound;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Modo Automático',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AutoModeConfig(
                      onSoundSelected: (sound) {
                        setState(() {
                          selectedSound = sound;
                        });
                      },
                    ),
                  ),
                );
              },
              child: Text('Seleccionar Sonido para Detección'),
            ),
            if (selectedSound != null)
              Text('Sonido seleccionado: $selectedSound'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.detectionService.startDetection(() {
                  if (selectedSound != null) {
                    widget.detectionService.playSelectedSound(selectedSound!);
                  }
                });
              },
              child: Text('Iniciar Detección Automática'),
            ),
          ],
        ),
      ),
    );
  }
}
