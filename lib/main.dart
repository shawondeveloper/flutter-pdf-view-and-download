import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:view_pdf_donwload_any_file/pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Pdf View',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool loading = true;
  List pdfList;

  String progress = "0";
  final Dio dio = Dio();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  // permission status
  Future<bool> reguestPermission() async {
    final persmission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (persmission != PermissionStatus.granted) {
      await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    }
    return persmission == PermissionStatus.granted;
  }

  // download directory
  Future<Directory> getDonwloadDirectory() async {
    if (Platform.isAndroid) {
      return await DownloadsPathProvider.downloadsDirectory;
    }
    return getApplicationDocumentsDirectory();
  }

  Future startDownload(String savePath, String urlPath) async {
    Map<String, dynamic> result = {
      "isSuccess": false,
      "filePath": null,
      "error": null
    };
    try {
      var response = await dio.download(urlPath, savePath,
          onReceiveProgress: _onReceiveProgress);
      result['isSuccess'] = response.statusCode == 200;
      result['filePath'] = savePath;
    } catch (e) {
      result['error'] = e.toString();
    } finally {
      _showNotification(result);
    }
  }

  _onReceiveProgress(int receive, int total) {
    if (total != -1) {
      setState(() {
        progress = (receive / total * 100).toStringAsFixed(0) + "%";
      });
    }
  }

  Future _showNotification(Map<String, dynamic> downloadStatus) async {
    final andorid = AndroidNotificationDetails(
        "channelId", 'Shajedul islam shawon', 'channelDescription',
        priority: Priority.high, importance: Importance.max);
    final ios = IOSNotificationDetails();
    final notificationDetails = NotificationDetails(android: andorid, iOS: ios);
    final json = jsonEncode(downloadStatus);
    final isSuccess = downloadStatus['isSuccess'];
    await FlutterLocalNotificationsPlugin().show(
        0,
        isSuccess ? "Sucess" : "error",
        isSuccess ? "File Download Successful" : "File Download Faild",
        notificationDetails,
        payload: json);
  }

  Future _onselectedNotification(String json) async {
    final obj = jsonDecode(json);
    if (obj['isSuccess']) {
      OpenFile.open(obj['filePath']);
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Error'),
                content: Text(obj['error']),
              ));
    }
  }

  Future download(String fileUrl, String fileName) async {
    final dir = await getDonwloadDirectory();
    final permissionStatus = await reguestPermission();
    if (permissionStatus) {
      final savePath = path.join(dir.path, fileName);
      await startDownload(savePath, fileUrl);
      print(savePath);
    } else {
      print("Permission Deined!");
    }
  }

  Future fetchAllPdf() async {
    final response = await http
        .get("http://192.168.1.103/upload_video_tutorial/pdffile.php");
    if (response.statusCode == 200) {
      setState(() {
        pdfList = jsonDecode(response.body);
        loading = false;
      });
      //print(pdfList);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAllPdf();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final android = AndroidInitializationSettings('mipmap/ic_launcher');
    final ios = IOSInitializationSettings();
    final initSetting = InitializationSettings(android: android, iOS: ios);
    flutterLocalNotificationsPlugin.initialize(initSetting,
        onSelectNotification: _onselectedNotification);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pdf List"),
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      itemCount: pdfList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: IconButton(
                            icon: Icon(Icons.picture_as_pdf),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PdfViewPage(
                                    url:
                                        "http://192.168.1.103/upload_video_tutorial/pdf/" +
                                            pdfList[index]["pdffile"],
                                    name: pdfList[index]["name"],
                                  ),
                                ),
                              );
                            },
                          ),
                          title: Text(pdfList[index]["name"]),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.download_rounded,color: Colors.green,
                            ),
                            onPressed: () {
                              download("http://192.168.1.103/upload_video_tutorial/pdf/" +
                                            pdfList[index]["pdffile"],pdfList[index]["pdffile"]);
                            },
                          ),
                        );
                      }),
                ),
                progress=='0'?Container():Padding(
                  padding: const EdgeInsets.only(bottom:25.0),
                  child: Text("Download Progress : "+progress,style: TextStyle(color: Colors.blue),),
                ),
              ],
            ),
    );
  }
}
