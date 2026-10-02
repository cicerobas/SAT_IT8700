import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

class TestFileDatasource {
  Future<String?> saveFile({
    required Map<String, dynamic> data,
    required String fileName,
  }) async {
    const encoder = JsonEncoder.withIndent("  ");
    final jsonString = encoder.convert(data);
    final Uint8List bytes = Uint8List.fromList(utf8.encode(jsonString));

    final Uri? uri = await FilePicker.saveFile(
      dialogTitle: 'Salvar arquivo de teste...',
      //initialDirectory: "", TODO: Pegar diretório padrão das configs
      fileName: '$fileName.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: bytes,
    );

    return uri?.toFilePath();
  }

  Future<String?> loadFile() async {
    final PlatformFile? file = await FilePicker.pickFile(
      dialogTitle: "Abrir arquivo de teste...",
      //initialDirectory: "", TODO: Pegar diretório padrão das configs
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (file == null || file.path == null) {
      return null;
    }

    return await File(file.path!).readAsString();
  }
}
