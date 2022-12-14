import 'dart:async';
import 'dart:io';

import 'package:exif/exif.dart';
import 'package:args/args.dart';

import 'DebugLog.dart';

Map<String, String> lFocals = {};

printExifOf(String path) async {

  final fileBytes = File(path).readAsBytesSync();
  final data = await readExifFromBytes(fileBytes);

  if (data.isEmpty) {
    DebugLog.writeln(DebugLevel.DEBUG, "No EXIF information found");
    return;
  }

  if (data.containsKey('JPEGThumbnail')) {
    DebugLog.writeln(DebugLevel.DEBUG, 'File has JPEG thumbnail');
    data.remove('JPEGThumbnail');
  }
  if (data.containsKey('TIFFThumbnail')) {
    DebugLog.writeln(DebugLevel.DEBUG, 'File has TIFF thumbnail');
    data.remove('TIFFThumbnail');
  }

  for (final entry in data.entries) {
    DebugLog.writeln(DebugLevel.DEBUG, "${entry.key}: ${entry.value}");
  }

  var focal = data.entries.firstWhere((element) {
    if (element.key == 'EXIF FocalLength') {
      return true;
    }
    return false;
  });

  DebugLog.writeln(DebugLevel.INFO, "Picture ${path} focal = ${focal.value}");

  lFocals[path] = "${focal.value}";
}

createCSV(String directory) async {

  File myFile = File('${directory}/Focals.CSV');

  String title = 'Name;Focal length (mm)\n';
  await myFile.writeAsString(
    "",
    mode: FileMode.write,
  );
  await myFile.writeAsString(
    title,
    mode: FileMode.append,
  );

  for (var k in lFocals.keys) {

    String focal = lFocals[k]!;
    String line = k + ';' + focal + '\n';

    await myFile.writeAsString(
      line,
      mode: FileMode.append,
    );
  }

}

listPictures(String directory) async {

  var endDir = await Directory('${directory}').create(recursive: false);

  // execute an action on each entry
  await endDir.list(recursive: true).forEach((entity) {

    if (entity is File &&
        (entity.path.endsWith('.jpg') || entity.path.endsWith('.JPG'))) {

      DebugLog.writeln(DebugLevel.DEBUG, 'File ' + entity.path);

      printExifOf(entity.path);
    }
  });

  await createCSV(directory);
}

void main(List<String> arguments) {

  final parser = ArgParser()
    ..addOption('dir',
        help: 'The directory in which to look for picture files')
    ..addFlag('verbose',
        abbr: 'v',
        defaultsTo: false,
        help: 'The program verbosity');

  try {

    // var results = parser.parse(arguments); // TODO uncomment
    var results = parser.parse(
        [
          '--dir', 'C:/Users/vgol/Downloads',
          // '-v',
        ]);

    if (results['verbose']) {
      DEBUG_LEVEL = DebugLevel.DEBUG;
    }
    listPictures(results['dir']);

  } catch (e) {
    print('Error wrong program arguments:'); // debug
    print(parser.usage);
    exit(-1);
  }
}
