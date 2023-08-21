import 'package:background_image_remover/api.dart';
import 'package:background_image_remover/widgets/Sizeconfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

class RemoveBackground extends StatefulWidget {
  @override
  _RemoveBackgroundState createState() => new _RemoveBackgroundState();
}

class _RemoveBackgroundState extends State<RemoveBackground> {
  Uint8List? imageFile;

  String? imagePath;

  ScreenshotController controller = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remove Bg'),
        actions: [
          IconButton(
              onPressed: () {
                getImage(ImageSource.gallery);
              },
              icon: const Icon(Icons.image)),
          IconButton(
              onPressed: () {
                getImage(ImageSource.camera);
              },
              icon: const Icon(Icons.camera_alt)),
          // IconButton(
          //     onPressed: () async {
          //       imageFile = await ApiClient().removeBgApi(imagePath!);
          //       setState(() {});
          //     },
          //     icon: const Icon(Icons.delete)),
          IconButton(
              onPressed: () async {
                saveImage();
              },
              icon: const Icon(Icons.save))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (imageFile != null)
                ? Screenshot(
                    controller: controller,
                    child: Image.memory(
                      imageFile!,
                    ),
                  )
                : Container(
                    width: 300,
                    height: 300,
                    color: Colors.grey[300]!,
                    child: const Icon(
                      Icons.image,
                      size: 100,
                    ),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: InkWell(
        onTap: () async {
          imageFile = await ApiClient().removeBgApi(imagePath!);
          setState(() {});
        },
        child: Container(
          height: SizeConfig.blockSizeVertical * 8,
          width: SizeConfig.screenWidth,
          decoration: BoxDecoration(
              color: Colors.amber,
              border: Border.all(
                color: Colors.black,
                width: 1,
              )),
          child: Center(
            child: Text('Remove BackGround'),
          ),
        ),
      ),
    );
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(
        source: source,
        imageQuality: 100,
      );
      if (pickedImage != null) {
        imagePath = pickedImage.path;
        imageFile = await pickedImage.readAsBytes();
        setState(() {});
      }
    } catch (e) {
      imageFile = null;
      setState(() {});
    }
  }

  void saveImage() async {
    bool isGranted = await Permission.storage.status.isGranted;
    if (!isGranted) {
      isGranted = await Permission.storage.request().isGranted;
    }

    if (isGranted) {
      String directory = (await getExternalStorageDirectory())!.path;
      String fileName =
          DateTime.now().microsecondsSinceEpoch.toString() + ".png";
      controller.captureAndSave(directory, fileName: fileName);
    }
  }
}
