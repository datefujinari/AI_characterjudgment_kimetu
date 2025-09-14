import 'package:flutter/cupertino.dart';
// import 'package:tflite_flutter/tflite_flutter.dart'; // 一時的に無効化
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

// アプリのエントリポイント（最初に実行される場所）
void main() {
  // runAppに最上位ウィジェットを渡してアプリを起動
  runApp(const kimetuApp());
}

// Cupertinoスタイルのアプリの最上位ウィジェット
class kimetuApp extends StatelessWidget {
  const kimetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    // CupertinoAppウィジェットを返す
    return const CupertinoApp(
      theme: CupertinoThemeData(
        brightness: Brightness.light, // 明るいテーマを指定
      ),
      home: HomePage(), // ホーム画面としてHomePageウィジェットを指定
    );
  }
}

// ホーム画面のウィジェット
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Interpreter? interpreter; // 一時的に無効化
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // loadModel(); // 一時的に無効化
  }

  // モデルの読み込み（一時的に無効化）
  /*
  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('assets/models/model.tflite');
      print('モデルの読み込み成功');
    } catch (e) {
      print('モデル読み込みエラー: $e');
    }
  }
  */

  // テスト用画像の設定
  void setTestImage() {
    // ユーザーのホームディレクトリからテスト画像を設定
    String? homeDir = Platform.environment['HOME'];
    if (homeDir != null) {
      List<String> testPaths = [
        '$homeDir/Desktop/tanjiro_04.png',
        '$homeDir/Desktop/test_image.jpg',
        '$homeDir/Downloads/tanjiro_04.png',
        '$homeDir/Pictures/test_image.jpg',
        '$homeDir/Desktop/test.jpg',
        '$homeDir/Downloads/test.jpg',
        '$homeDir/Pictures/test.jpg',
      ];

      for (String path in testPaths) {
        File testFile = File(path);
        if (testFile.existsSync()) {
          setState(() {
            selectedImage = testFile;
          });
          print('テスト画像を設定しました: $path');
          return;
        }
      }
    }
    print(
      'テスト用画像が見つかりませんでした。デスクトップ、ダウンロード、または画像フォルダにtest_image.jpgまたはtest.jpgを配置してください。',
    );
  }

  Future<void> selectImage() async {
    try {
      print('画像選択を開始します...');

      // macOSではfile_pickerを使用
      if (Platform.isMacOS) {
        print('macOSでfile_pickerを使用します');
        
        try {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.any, // まず any で試す
            allowMultiple: false,
          );

          print('ファイルピッカー結果: $result');
          if (result != null) {
            print('選択されたファイル数: ${result.files.length}');
            String? filePath = result.files.single.path;
            print('ファイルパス: $filePath');
            if (filePath != null) {
              // 画像ファイルかどうかチェック
              String lowerPath = filePath.toLowerCase();
              if (lowerPath.endsWith('.jpg') || 
                  lowerPath.endsWith('.jpeg') || 
                  lowerPath.endsWith('.png') || 
                  lowerPath.endsWith('.gif') || 
                  lowerPath.endsWith('.bmp')) {
                setState(() {
                  selectedImage = File(filePath);
                });
                print('画像が選択されました: $filePath');
              } else {
                print('選択されたファイルは画像形式ではありません: $filePath');
              }
            } else {
              print('ファイルパスがnullです');
            }
          } else {
            print('画像選択がキャンセルされました（resultがnull）');
          }
        } catch (e) {
          print('file_picker エラー: $e');
          print('代替方法を使用してください（テスト画像ボタン）');
        }
      } else {
        // iOS/Androidではimage_pickerを使用
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1800,
          maxHeight: 1800,
          imageQuality: 80,
        );

        if (image != null) {
          setState(() {
            selectedImage = File(image.path);
          });
          print('画像が選択されました: ${image.path}');

          // 画像を選択したら推論を実行
          // if (interpreter != null) {
          //   await predictImage();
          // }
        }
      }
    } catch (e) {
      print('画像選択エラー: $e');
    }
  }

  // 画像推論機能（一時的に無効化）
  /*
  Future<void> predictImage() async {
    if (selectedImage == null || interpreter == null) return;
    
    try {
      print('画像推論を開始します...');
      // TODO: 画像の前処理と推論処理を実装
      print('推論処理は後で実装します');
    } catch (e) {
      print('推論エラー: $e');
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('キャラ判定(試作)'), // ナビゲーションバーのタイトル
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 選択された画像を表示
              if (selectedImage != null)
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.systemGrey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.file(selectedImage!, fit: BoxFit.cover),
                )
              else
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.systemGrey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      '画像が選択されていません',
                      style: TextStyle(color: CupertinoColors.systemGrey),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              const Text(
                '画像アップロードまたは撮影してください。\nAIでキャラを判定します。',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CupertinoButton.filled(
                    onPressed: selectImage,
                    child: const Text('画像を選択'),
                  ),
                  CupertinoButton(
                    color: CupertinoColors.systemGrey,
                    onPressed: () {
                      print('テストボタンが押されました');
                      setTestImage();
                    },
                    child: const Text('テスト画像'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
