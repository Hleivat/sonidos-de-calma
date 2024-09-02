// lib/dashboard.dart
import 'package:flutter/material.dart';
import 'package:new_project_directory/manual_mode.dart';
import 'package:new_project_directory/automatic_mode.dart';
import 'package:new_project_directory/detection_service.dart';

class Dashboard extends StatelessWidget {
  final DetectionService detectionService = DetectionService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Elija una Opción'),
      ),
      body: Center( // Centrar el contenido en la pantalla
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row( // Usar Row para colocar los botones lado a lado
            mainAxisAlignment: MainAxisAlignment.center, // Centrar los botones
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ManualMode()),
                  );
                },
                child: Text('Modo Manual'),
              ),
              SizedBox(width: 20), // Espacio entre los botones
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AutomaticMode(detectionService: detectionService)),
                  );
                },
                child: Text('Modo Automático'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
