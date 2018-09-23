import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_api/intents/base.dart';
import 'package:path/path.dart' as Path;
import 'package:share_api/share_result.dart';

class SystemUI extends ShareIntent {
  SystemUI(MethodChannel channel) : super(channel);
  final String handlerModule = 'system';

  Future<ShareResult> shareText(String text, {String prompt}) async {
    final String result = await channel.invokeMethod('share', {
      'handler': {
        'module': handlerModule,
        'function': 'shareText',
      },
      'arguments': {
        'text': text,
        'prompt': prompt,
        'type': 'text/plain',
      }
    });
    return ShareResult.undefined;
  }

  Future<ShareResult> shareFile(File file,
      {String fileType = "file/*", String prompt}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      String filename = Path.basename(file.path);
      String filePath = '${tempDir.path}/$filename';

      file.copy(filePath);

      await channel.invokeMethod('share', {
        'handler': {
          'module': handlerModule,
          'function': 'shareFile',
        },
        'arguments': {
          'file_url': filename,
          'prompt': prompt,
          'type': fileType,
        }
      });
    } on Exception catch (e) {
//      throw e;
      print(e);
      return ShareResult.failed;
    }
    return ShareResult.undefined;
  }

//  Future<Null> _shareBytes(Uint8List content, String storagePath,
//      Map<String, dynamic> invokeConfig) async {
//    final file = await File(storagePath).create();
//    file.writeAsBytesSync(content);
//
//    await channel.invokeMethod('share', invokeConfig);
//  }

  Future<ShareResult> shareImage(Uint8List image,
      {String imageType = "image/*", String prompt}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      String imageName = 'share.png';
      String imagePath = '${tempDir.path}/$imageName';

      final file = await File(imagePath).create();
      file.writeAsBytesSync(image);

      await channel.invokeMethod('share', {
        'handler': {
          'module': handlerModule,
          'function': 'shareImage',
        },
        'arguments': {
          'image_url': imageName,
          'prompt': prompt,
          'type': imageType,
        }
      });
    } on Exception catch (e) {
//      throw e;
      print(e);
      return ShareResult.failed;
    }
    return ShareResult.undefined;
  }
}