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

  double _top = 0.0; //距顶部的偏移
  double _left = 0.0;//距左边的偏移

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
            // 包裹在 Container 中，以确保有明确的布局约束
            Container(
              width: double.infinity,
              height: 400, // 设定一个固定的高度
              child: Stack(
                children: [
                  Positioned(
                    top: _top,
                    left: _left,
                    child: GestureDetector(
                      child: const Image(
                        image: AssetImage("assets/images/origin.png"),
                        width: 220,
                        height: 200,
                      ),
                      //手指按下时会触发此回调
                      onPanDown: (DragDownDetails e) {
                        //打印手指按下的位置(相对于屏幕)
                        print("用户手指按下：${e.globalPosition}");
                      },
                      //手指滑动时会触发此回调
                      onPanUpdate: (DragUpdateDetails e) {
                        //用户手指滑动时，更新偏移，重新构建
                        setState(() {
                          _left += e.delta.dx;
                          _top += e.delta.dy;
                        });
                      },
                      onPanEnd: (DragEndDetails e) {
                        //打印滑动结束时在x、y轴上的速度
                        print(e.velocity);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Image(
              image: AssetImage("assets/images/mask.jpeg"),
              width: 220,
              height: 200,
            ),
            CutoutImageWidget(),
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
      final cutoutPath =
          await ImageProcessor().cutoutImage(originPath, maskPath);
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
            ShaderMask(
              blendMode: BlendMode.dstOut, // 设置混合模式，将目标像素设为透明
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: [Colors.transparent, Colors.black], // 设置透明渐变色
                  stops: [0.8, 1.0], // 控制透明度渐变
                ).createShader(bounds);
              },
              child: Image.file(File(_cutoutPath!), width: 220, // 设置宽度
                    height: 200), // 设置高度,
            )
          else ElevatedButton(
            onPressed: _cutoutImage,
            child: Text('Cutout Image'),
          )
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
    await file.writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file.path;
  }
}
