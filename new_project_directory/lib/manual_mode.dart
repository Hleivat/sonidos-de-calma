import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

class ManualMode extends StatefulWidget {
  @override
  _ManualModeState createState() => _ManualModeState();
}

class _ManualModeState extends State<ManualMode> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final AudioPlayer audioPlayer = AudioPlayer();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  List<Reference> fileReferences = [];
  String? selectedFileURL;
  String? selectedFileName;
  double _volume = 1.0; // Control de volumen
  int _playDuration = 5; // Duración por defecto en segundos
  bool isRecording = false;
  TextEditingController _fileNameController = TextEditingController();

  
  @override
  void initState() {
    super.initState();
    _loadAudioFiles();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Micrófono no permitido';
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  Future<void> _loadAudioFiles() async {
    try {
      ListResult result = await storage.ref('sounds').listAll();
      setState(() {
        fileReferences = result.items;
        if (fileReferences.isNotEmpty) {
          _selectFile(fileReferences.first);
        }
      });
    } catch (e) {
      print('Error al cargar los archivos de audio: $e');
    }
  }

  void _selectFile(Reference fileReference) async {
    String url = await fileReference.getDownloadURL();
    String fileName = fileReference.name;

    setState(() {
      selectedFileURL = url;
      selectedFileName = fileName;
      _fileNameController.text = fileName;
    });
  }

  Future<void> _playAudio() async {
    if (selectedFileURL != null) {
      try {
        await audioPlayer.play(UrlSource(selectedFileURL!), volume: _volume);
        Future.delayed(Duration(seconds: _playDuration), () {
          audioPlayer.stop();
        });
      } catch (e) {
        print('Error al reproducir el sonido: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('El archivo de audio no está disponible')));
    }
  }

  Future<void> _stopAudio() async {
    try {
      await audioPlayer.stop();
    } catch (e) {
      print('Error al detener el sonido: $e');
    }
  }

  Future<void> _renameFile(Reference fileReference, String newName) async {
    try {
      Reference newFileRef = storage.ref('sounds/$newName');
      final data = await fileReference.getData();
      if (data != null) {
        await newFileRef.putData(data);
        await fileReference.delete();
        setState(() {
          _loadAudioFiles();
          selectedFileName = newName;
        });
      } else {
        print('No se pudo obtener los datos del archivo original.');
      }
    } catch (e) {
      print('Error al renombrar el archivo: $e');
    }
  }

  Future<void> _startRecording() async {
    if (!_recorder.isStopped) return;

    Directory tempDir = await getTemporaryDirectory();
    String path = '${tempDir.path}/sound.mp3';

    try {
      await _recorder.startRecorder(
        toFile: path,
        codec: Codec.aacADTS,
      );
      setState(() {
        isRecording = true;
      });
    } catch (e) {
      print('Error al iniciar la grabación: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (!_recorder.isRecording) return;

    String? path = await _recorder.stopRecorder();
    if (path != null) {
      File file = File(path);
      String fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.mp3';
      await storage.ref('sounds/$fileName').putFile(file);
      setState(() {
        _loadAudioFiles();
        isRecording = false;
      });
    }
  }

  Future<void> _uploadMP3() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      try {
        await storage.ref('sounds/$fileName').putFile(file);
        setState(() {
          _loadAudioFiles();
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Archivo subido con éxito')));
      } catch (e) {
        print('Error al subir el archivo: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al subir el archivo')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Modo Manual',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (selectedFileName != null)
  GestureDetector(
    onTap: () {
      _showFileSelectionDialog();
    },
    onLongPress: () {
      _showRenameDialog();
    },
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 2, 8, 88),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.music_note, color: const Color.fromARGB(255, 255, 255, 255)),
          SizedBox(width: 10),
          Text(
            'Sonido seleccionado: $selectedFileName',
            style: TextStyle(fontSize: 15, color: const Color.fromARGB(255, 255, 255, 255)),
          ),
        ],
      ),
    ),
  ),

            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _playAudio,
                  icon: Icon(Icons.play_arrow),
                  label: Text('Reproducir Sonido'),
                ),
                SizedBox(width: 10), // Espacio entre los botones
                ElevatedButton.icon(
                  onPressed: _stopAudio,
                  icon: Icon(Icons.stop),
                  label: Text('Detener Sonido'),
                ),
              ],
            ),
            SizedBox(height: 10),
            DropdownButton<int>(
              value: _playDuration,
              items: [5, 10, 15, 30].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value segundos'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  _playDuration = newValue ?? 5;
                });
              },
            ),
            SizedBox(height: 20),
            Text('Volumen: ${(_volume * 100).toInt()}%'),
            Slider(
              value: _volume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label: (_volume * 100).toStringAsFixed(0),
              onChanged: (double value) {
                setState(() {
                  _volume = value;
                });
                audioPlayer.setVolume(_volume);
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: isRecording ? _stopRecording : _startRecording,
                  icon: Icon(isRecording ? Icons.stop : Icons.mic),
                  label: Text(isRecording ? 'Detener Grabación' : 'Grabar Audio'),
                ),
                SizedBox(width: 10), // Espacio entre los botones
                ElevatedButton.icon(
                  onPressed: _uploadMP3,
                  icon: Icon(Icons.upload_file),
                  label: Text('Subir un Archivo MP3'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFileSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccionar sonido'),
          content: SingleChildScrollView(
            child: Column(
              children: fileReferences.map((Reference fileReference) {
                return ListTile(
                  title: Text(fileReference.name),
                  onTap: () {
                    _selectFile(fileReference);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showRenameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Renombrar sonido'),
          content: TextField(
            controller: _fileNameController,
            decoration: InputDecoration(hintText: "Nuevo nombre del sonido"),
          ),
          actions: [
                        ElevatedButton(
              onPressed: () {
                if (_fileNameController.text.isNotEmpty) {
                  Reference selectedRef = fileReferences.firstWhere((ref) => ref.name == selectedFileName);
                  _renameFile(selectedRef, _fileNameController.text).then((_) {
                    Navigator.pop(context); // Cierra el diálogo después de renombrar
                  });
                }
              },
              child: Text('Guardar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el diálogo sin hacer nada
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
}

