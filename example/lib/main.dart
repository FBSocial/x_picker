import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:x_picker/x_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  XPicker xPicker = XPicker.instance;

  ValueNotifier<List<XFile>> images = ValueNotifier([]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ValueListenableBuilder<List<XFile>>(
                valueListenable: images,
                builder: (_, files, child) {
                  return ListView.builder(
                    itemBuilder: (c, i) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: XImage(files[i]),
                      );
                    },
                    itemCount: files.length,
                  );
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8.0,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      final res =
                          await xPicker.pickMedia(type: MediaType.IMAGE);
                      if (res == null) return;

                      images.value = [res];
                      printFile(res);
                    },
                    child: Text("Pick Image")),
                ElevatedButton(
                    onPressed: () async {
                      final res =
                          await xPicker.pickMedia(type: MediaType.VIDEO);
                      if (res == null) return;

                      printFile(res);
                    },
                    child: Text("Pick Video")),
                ElevatedButton(
                    onPressed: () async {
                      final res = await xPicker.pickMedia(type: MediaType.BOTH);
                      if (res == null) return;

                      printFile(res);
                    },
                    child: Text("Pick Media")),
                ElevatedButton(
                    onPressed: () async {
                      final res = await xPicker.pickMultiImages();

                      images.value = res;
                      res.forEach(printFile);
                    },
                    child: Text("Pick Images")),
                ElevatedButton(
                    onPressed: () async {
                      final res = await xPicker.pickFiles(
                          allowMultiple: true, withData: true);
                      res.forEach(printFile);
                    },
                    child: Text("Pick Files")),
              ],
            ),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> printFile(XFile res) async {
    if (!kIsWeb) print("path: ${res.path}");
    print("name: ${res.name}");
    print("mimeType: ${res.mimeType}");

    var bytes = await res.readAsBytes();
    print("size in bytes: ${bytes.lengthInBytes}");
  }
}
