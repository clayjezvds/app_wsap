import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:dio/dio.dart';


bool firstPress = true;
var dio = Dio();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
    debug: true, // optional: set false to disable printing logs to console
    ignoreSsl: true,
  );

  await Permission.storage.request();
  await Permission.manageExternalStorage.request();

  runApp(
    const MaterialApp(
      color: Colors.black,
      home: WebViewApp(),
    ),
  );
}

class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  final GlobalKey webViewKey = GlobalKey();
  late WebViewController controller;

  late WebViewController _webViewController;

  var encodedString;

  @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: null,
        body: PopScope(
          canPop: true,
          onPopInvoked: (bool onPop) async {
            if(onPop) {
              if (await _webViewController.canGoBack()) {
                _webViewController.goBack();
                return;
              }
            }
          },
          child: SafeArea(
            child: WebView(
              initialUrl: "https://www.wsap.africa/",
              javascriptMode: JavascriptMode.unrestricted,
              javascriptChannels: {
                JavascriptChannel(
                  name: 'getLink',
                  onMessageReceived: (JavascriptMessage message) {
                    encodedString = message.message;
                    //Map<String, dynamic> data = encodedString;
                  },
                )
              },
              onWebViewCreated: (WebViewController controller) {
                _webViewController = controller;
              },
              navigationDelegate: (NavigationRequest request) async {
                if (request.url
                    .startsWith('https://api.whatsapp.com/send?phone')) {
                  String phone = "27781892545";
                  String message = "Hi";

                  final url = "https://wa.me/$phone/?text=${Uri.parse(message)}";
                  await openBrowserUrl(url: url, inApp: false);
                  return NavigationDecision.navigate;
                }

                if (request.url.startsWith('https://www.instagram.com/')) {
                  final urlFinal = request.url.toString();
                  await openBrowserUrl(url: urlFinal, inApp: false);
                  return NavigationDecision.navigate;
                }

                if (request.url.startsWith('data:')) {
                  final urlFinal = request.url.toString();
                  const String yourExtension = 'image/png';

                  _createFileFromString(urlFinal, 'img.png', yourExtension);
                  return NavigationDecision.prevent;
                }

                  return NavigationDecision.navigate;
              },
            ),
          ),
        ),
      );
    }
}

_createFileFromString(String encodedString, String fileName, String yourExtension) async {
  var bytes = base64.decode(encodedString.replaceAll('\n', ''));
  final output = await getExternalStorageDirectory();
  final file = File("${output?.path}/$fileName.$yourExtension");
  await file.writeAsBytes(bytes.buffer.asUint8List());
  await OpenFile.open("${output?.path}/$fileName.$yourExtension");

  String? path = await FileSaver.instance.saveFile(
      name: 'file',
      bytes: bytes,
      ext: 'png',
      mimeType: MimeType.png);

  print(path);

  return file.path;
}


Future openDownloadUrl({
  required String url,
  bool inApp = false,
}) async {
  if (await canLaunchUrlString(url)) {
    await launchUrlString(
      url,
      mode: LaunchMode.externalApplication,
    );
  }
}

Future openBrowserUrl({
  required String url,
  bool inApp = false,
}) async {
  if (await canLaunchUrlString(url)) {
    await launchUrlString(
      url,
      mode: LaunchMode.externalNonBrowserApplication,
    );
  }
}

/*

void saveToFile(String content) async {
  content = _encodedString;
  Uint8List bytes = base64Decode(content);

  String? path = await FileSaver.instance.saveFile(
      name: 'file',
      bytes: bytes,
      ext: 'png',
      mimeType: MimeType.png);
}

Future <File> getFileFromBase64({
      required String base64string,
      required String name,
      required String extension
     }){


}

Future openfile({required String url, String? filename}) async {
  final file = await downloadfile(url, filename!);
  if (file == null) return;

  OpenFile.open(file.path);
}

Future<File?> downloadfile(String url, String name) async {
  final appStorage = await getApplicationDocumentsDirectory();
  final file = File('${appStorage.path}/$name');


    String bs4str = url;
    Uint8List decodedbytes = base64.decode(bs4str);
    File decodedimgfile = await File("img.png").writeAsBytes(decodedbytes);
    String decodedpath = decodedimgfile.path;

    final raf = file.openSync(mode: FileMode.write);
    raf.writeFromSync(decodedbytes);
    await raf.close();

    return file;
  }

await FileSaver.instance.saveFile({
      required String name,
      Uint8List? bytes,
      File? file,
      String? filePath,
      LinkDetails? link,
      String ext = "",
      MimeType mimeType = MimeType.other,
      String? customMimeType
    });

Future download2(Dio dio, String url, String savePath) async {
  try {
    Response response = await dio.get(
      url,
      onReceiveProgress: showDownloadProgress,
      //Received data with List<int>
      options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          }),
    );
    print(response.headers);
    File file = File(savePath);
    var raf = file.openSync(mode: FileMode.write);
    // response.data is List<int> type
    raf.writeFromSync(response.data);
    await raf.close();
  } catch (e) {
    print(e);
  }
}

void showDownloadProgress(received, total) {
  if (total != -1) {
    print((received / total * 100).toStringAsFixed(0) + "%");
  }
}*/
