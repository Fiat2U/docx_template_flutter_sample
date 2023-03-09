import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:docx_template/docx_template.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImageProvider()),
        ChangeNotifierProvider(create: (_) => PhotoDocProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Docx Template Sample',
      home: const MyHomePage(),
      theme: ThemeData(
        useMaterial3: true,
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('docx_template Flutter Sample'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: FilledButton.tonal(
              onPressed: _generateDocument,
              child: const Text('Generate Document (Official Example)'),
            ),
          ),
          Center(
            child: FilledButton.tonal(
              onPressed: () => _generatePhotoDocument(context),
              child: const Text('Take a Photo and Generate a Document'),
            ),
          ),
          Consumer<PhotoDocProvider>(
            builder: (context, provider, _) {
              if (provider.filepath == null) {
                return const Center(child: Text('No document generated'));
              } else {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Text(provider.filepath!,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                );
              }
            },
          )
        ],
      ),
    );
  }

  Future<void> _generateDocument() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      print('Permission denied');
      return;
    }

    final data = await rootBundle.load('assets/template.docx');
    final bytes = data.buffer.asUint8List();
    final docx = await DocxTemplate.fromBytes(bytes);

    // Load test image for inserting in docx
    // final testFileContent = await File('assets/test.png').readAsBytes();
    final testFileData = await rootBundle.load('assets/test.png');
    final testFileContent = testFileData.buffer.asUint8List();

    final listNormal = ['Foo', 'Bar', 'Baz'];
    final listBold = ['ooF', 'raB', 'zaB'];

    final contentList = <Content>[];

    final b = listBold.iterator;
    for (var n in listNormal) {
      b.moveNext();

      final c = PlainContent("value")
        ..add(TextContent("normal", n))
        ..add(TextContent("bold", b.current));
      contentList.add(c);
    }

    Content c = Content();
    c
      ..add(TextContent("docname", "Simple docname"))
      ..add(TextContent("passport", "Passport NE0323 4456673"))
      ..add(TableContent("table", [
        RowContent()
          ..add(TextContent("key1", "Paul"))
          ..add(TextContent("key2", "Viberg"))
          ..add(TextContent("key3", "Engineer"))
          ..add(ImageContent('img', testFileContent)),
        RowContent()
          ..add(TextContent("key1", "Alex"))
          ..add(TextContent("key2", "Houser"))
          ..add(TextContent("key3", "CEO & Founder"))
          ..add(ListContent("tablelist", [
            TextContent("value", "Mercedes-Benz C-Class S205"),
            TextContent("value", "Lexus LX 570")
          ]))
          ..add(ImageContent('img', testFileContent))
      ]))
      ..add(ListContent("list", [
        TextContent("value", "Engine")
          ..add(ListContent("listnested", contentList)),
        TextContent("value", "Gearbox"),
        TextContent("value", "Chassis")
      ]))
      ..add(ListContent("plainlist", [
        PlainContent("plainview")
          ..add(TableContent("table", [
            RowContent()
              ..add(TextContent("key1", "Paul"))
              ..add(TextContent("key2", "Viberg"))
              ..add(TextContent("key3", "Engineer")),
            RowContent()
              ..add(TextContent("key1", "Alex"))
              ..add(TextContent("key2", "Houser"))
              ..add(TextContent("key3", "CEO & Founder"))
              ..add(ListContent("tablelist", [
                TextContent("value", "Mercedes-Benz C-Class S205"),
                TextContent("value", "Lexus LX 570")
              ]))
          ])),
        PlainContent("plainview")
          ..add(TableContent("table", [
            RowContent()
              ..add(TextContent("key1", "Nathan"))
              ..add(TextContent("key2", "Anceaux"))
              ..add(TextContent("key3", "Music artist"))
              ..add(ListContent(
                  "tablelist", [TextContent("value", "Peugeot 508")])),
            RowContent()
              ..add(TextContent("key1", "Louis"))
              ..add(TextContent("key2", "Houplain"))
              ..add(TextContent("key3", "Music artist"))
              ..add(ListContent("tablelist", [
                TextContent("value", "Range Rover Velar"),
                TextContent("value", "Lada Vesta SW Sport")
              ]))
          ])),
      ]))
      ..add(ListContent("multilineList", [
        PlainContent("multilinePlain")
          ..add(TextContent('multilineText', 'line 1')),
        PlainContent("multilinePlain")
          ..add(TextContent('multilineText', 'line 2')),
        PlainContent("multilinePlain")
          ..add(TextContent('multilineText', 'line 3'))
      ]))
      ..add(TextContent('multilineText2', 'line 1\nline 2\n line 3'))
      ..add(ImageContent('img', testFileContent));

    final d = await docx.generate(c);
    const filepath = '/storage/emulated/0/Download/generated_308.docx';
    final of = File(filepath);
    if (d != null) {
      await of.writeAsBytes(d);
      Fluttertoast.showToast(
          msg: 'Document $filepath generated!', toastLength: Toast.LENGTH_LONG);
    }
  }

  Future<void> _generateAnotherDocument() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      print('Permission denied');
      return;
    }

    final data = await rootBundle.load('assets/simple-tmpl.docx');
    final bytes = data.buffer.asUint8List();
    final docx = await DocxTemplate.fromBytes(bytes);

    // Load test image for inserting in docx
    // Exception has occurred.
    // PathNotFoundException (PathNotFoundException: Cannot open file, path = 'assets/test.png' (OS Error: No such file or directory, errno = 2))
    final image = await File('assets/test.png').readAsBytes();
    // final testFileData = await rootBundle.load('assets/test.png');
    // final testFileContent = testFileData.buffer.asUint8List();

    Content c = Content();
    c
      ..add(TextContent("docname", "Another Document"))
      ..add(ImageContent('img', image));

    final d = await docx.generate(c);
    const filepath = '/storage/emulated/0/Download/generated_308.docx';
    final of = File(filepath);
    if (d != null) {
      await of.writeAsBytes(d);
      Fluttertoast.showToast(
          msg: 'Document $filepath generated!', toastLength: Toast.LENGTH_LONG);
    }
  }

  Future<void> _generatePhotoDocument(context) async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      print('Permission denied');
      return;
    }

    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      Provider.of<ImageProvider>(context, listen: false).setImage(imageFile);
      print('Picture taken at: ${imageFile.path}');

      final data = await rootBundle.load('assets/simple-tmpl.docx');
      final bytes = data.buffer.asUint8List();
      final docx = await DocxTemplate.fromBytes(bytes);

      final image = await imageFile.readAsBytes();

      Content c = Content();
      c
        ..add(TextContent("docname", "Photo Document"))
        ..add(ImageContent('img', image));

      final d = await docx.generate(c);

      const filepath = '/storage/emulated/0/Download/generated_309.docx';
      final of = File(filepath);
      if (d != null) {
        await of.writeAsBytes(d);

        Provider.of<PhotoDocProvider>(context, listen: false).set(filepath);

        Fluttertoast.showToast(
            msg: 'Document $filepath generated!',
            toastLength: Toast.LENGTH_LONG);
      }
    }
  }
}

class ImageProvider with ChangeNotifier {
  File? _imageFile;

  File? get imageFile => _imageFile;

  void setImage(File file) {
    _imageFile = file;
    notifyListeners();
  }
}

class PhotoDocProvider with ChangeNotifier {
  String _filepath = '';

  String? get filepath => _filepath;

  void set(String filepath) {
    _filepath = filepath;
    notifyListeners();
  }
}
