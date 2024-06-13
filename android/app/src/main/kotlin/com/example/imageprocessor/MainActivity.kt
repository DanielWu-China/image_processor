package com.example.imageprocessor

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 注册自定义的 Flutter 插件 ImageProcessor
        flutterEngine.plugins.add(ImageProcessor())
    }

}
