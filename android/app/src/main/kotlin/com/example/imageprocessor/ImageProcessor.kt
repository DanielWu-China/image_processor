package com.example.imageprocessor

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class ImageProcessor : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var applicationContext: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "image_processor")
        channel.setMethodCallHandler(this)
        applicationContext = binding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "cutoutImage") {
            val originPath = call.argument<String>("originPath")
            val maskPath = call.argument<String>("maskPath")
            if (originPath != null && maskPath != null) {
                cutoutImage(originPath, maskPath, result)
            } else {
                result.error("invalid_args", "Invalid arguments", null)
            }
        } else {
            result.notImplemented()
        }
    }

    //读取源图片和蒙版图片，调用抠图方法，输出结果图片
    private fun cutoutImage(originPath: String, maskPath: String, result: MethodChannel.Result) {
        val originBitmap = BitmapFactory.decodeFile(originPath)
        val maskBitmap = BitmapFactory.decodeFile(maskPath)
        if (originBitmap != null && maskBitmap != null) {
            val cutoutBitmap = processCutout(originBitmap, maskBitmap)
            val file = File(applicationContext.cacheDir, "cutout.png")
            val out = FileOutputStream(file)
            cutoutBitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
            out.flush()
            out.close()
            result.success(file.absolutePath)
        } else {
            result.error("image_error", "Cannot load images", null)
        }
    }

    //利⽤像素遍历实现抠图效果
    private fun processCutout(originBitmap: Bitmap, maskBitmap: Bitmap): Bitmap {
        val width = originBitmap.width
        val height = originBitmap.height
        val resultBitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)

        for (y in 0 until height) {
            for (x in 0 until width) {
                val maskPixel = maskBitmap.getPixel(x, y)
                val originPixel = originBitmap.getPixel(x, y)

                if (maskPixel == Color.WHITE) {//保留白色蒙版部分
                    resultBitmap.setPixel(x, y, originPixel)
                } else {
                    resultBitmap.setPixel(x, y, Color.TRANSPARENT)
                }
            }
        }

        return resultBitmap
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
