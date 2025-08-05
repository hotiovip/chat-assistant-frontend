import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isWindows) {
        directory = await getDownloadsDirectory();
      }
      else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }
      else if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists()) directory = await getExternalStorageDirectory();
      }
    } catch (err) {
      log("Cannot get download folder path");
    }
    return directory?.path;
  }

Future<FilePickerResult?> pickFile() async {
  FilePickerWindows filePicker = FilePickerWindows();
    
  return await filePicker.pickFiles(
    dialogTitle: "Choose a file to upload",
    initialDirectory: await getDownloadPath(),
    withReadStream: true
  );
}

