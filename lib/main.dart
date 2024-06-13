import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ImageProcessor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  void _incrementCounter() {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Image(
              image: AssetImage("assets/images/origin.png"),
              width: 220, height: 200,
            ),
            const Image(
              image: AssetImage("assets/images/mask.jpeg"),
              width: 220, height: 200,
            ),
            CutoutImageWidget()
          ],
        ),
      ),
    );
  }
}

class CutoutImageWidget extends StatefulWidget {
  @override
  _CutoutImageWidgetState createState() => _CutoutImageWidgetState();
}

class _CutoutImageWidgetState extends State<CutoutImageWidget> {
  String? _cutoutPath;

  Future<void> _cutoutImage() async {
    try {
      final String originPath = await loadAsset('assets/images/origin.png');
      final String maskPath = await loadAsset('assets/images/mask.jpeg');
      final cutoutPath = await ImageProcessor().cutoutImage(
          originPath, maskPath);
      setState(() {
        _cutoutPath = cutoutPath;
      });
    } catch (e) {
      print('Error: $e');
    }

  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_cutoutPath != null)
            Container(
                width: 220, // 设置宽度
                height: 200, // 设置高度
                child: Image.file(File(_cutoutPath!))),
          ElevatedButton(
            onPressed: _cutoutImage,
            child: Text('Cutout Image'),
          ),
        ],
      ),
    );
  }

  //转换本地图片路径
  Future<String> loadAsset(String path) async {
    final byteData = await rootBundle.load(path);
    final buffer = byteData.buffer;
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${path.split('/').last}');
    await file.writeAsBytes(buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file.path;
  }
}
