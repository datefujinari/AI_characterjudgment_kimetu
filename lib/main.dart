import 'package:flutter/cupertino.dart';
// import 'package:tflite_flutter/tflite_flutter.dart'; // macOSで問題があるため一時的にコメントアウト
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;

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
  bool isModelLoaded = false; // デモ用：モデル状態管理
  List<String> labels = [];
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();
  String debugInfo = '';
  String predictionResult = '';

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      print('=== デモモード：モデル読み込み開始 ===');
      print('🔄 ラベルファイルを読み込み中...');

      // ラベルファイルの読み込み（assetsから）
      String labelData = await DefaultAssetBundle.of(
        context,
      ).loadString('assets/models/labels.txt');
      print('✅ labels.txt 読み込み成功: \${labelData.length} 文字');
      
      labels = labelData
          .split('\n')
          .where((label) => label.trim().isNotEmpty)
          .toList();

      // デモ用：モデル読み込み完了をシミュレート
      await Future.delayed(const Duration(seconds: 1));
      isModelLoaded = true;

      setState(() {
        debugInfo = '✅ デモモード: \${labels.length}クラス対応\nAI推論: 準備完了\n\n⚠️ 現在デモモード動作中\n（色調ベースの推定）';
      });
      print('✅ デモモード初期化成功');
      print('📋 ラベル数: \${labels.length}');
      for (int i = 0; i < labels.length; i++) {
        print('   \$i: \${labels[i]}');
      }
      print('🤖 デモAI推論: 準備完了');
    } catch (e) {
      setState(() {
        debugInfo = '❌ ラベル読み込みエラー: \$e';
      });
      print('❌ ラベル読み込みエラー: \$e');
    }
  }

  // テスト用画像の設定（改善版）
  Future<void> setTestImage() async {
    print('=== テスト画像設定を開始 ===');

    // サンドボックス対応：Documentsディレクトリを使用
    String? homeDir = Platform.environment['HOME'];
    print('ホームディレクトリ: \$homeDir');

    if (homeDir != null) {
      List<String> testPaths = [
        // サンドボックス内のDocumentsを優先
        '\$homeDir/Documents/test_image.jpg',
        '\$homeDir/Documents/test_image.png',
        '\$homeDir/Documents/test.jpg',
        '\$homeDir/Documents/test.png',
        '\$homeDir/Documents/tanjiro_04.png',
        // 従来のパスも残す
        '\$homeDir/Desktop/tanjiro_04.png',
        '\$homeDir/Desktop/test_image.jpg',
        '\$homeDir/Downloads/tanjiro_04.png',
        '\$homeDir/Pictures/test_image.jpg',
        '\$homeDir/Desktop/test.jpg',
        '\$homeDir/Downloads/test.jpg',
        '\$homeDir/Pictures/test.jpg',
        '\$homeDir/Desktop/test.png',
        '\$homeDir/Downloads/test.png',
        '\$homeDir/Pictures/test.png',
      ];

      for (String path in testPaths) {
        print('チェック中: \$path');
        File testFile = File(path);
        try {
          if (testFile.existsSync()) {
            print('ファイルサイズ: \${testFile.lengthSync()} bytes');

            // ファイルの読み込みテスト
            try {
              testFile.readAsBytesSync();
              setState(() {
                selectedImage = testFile;
                debugInfo = 'テスト画像設定成功: ${path.split('/').last}\n\nAI推論を実行中...';
              });
              print('✅ テスト画像を設定しました: \$path');

              // 画像選択後に自動で推論実行
              print('🔄 テスト画像でAI推論を開始します...');
              print('🧠 デモモード状態: \${isModelLoaded ? "準備完了" : "未初期化"}');
              if (isModelLoaded) {
                print('✅ predictImage()を呼び出します');
                await predictImage();
              } else {
                print('❌ モデルが未初期化のため推論をスキップ');
                setState(() {
                  debugInfo = '❌ AIモデルが準備できていません（テスト画像）';
                });
              }
              return;
            } catch (e) {
              print('⚠️ ファイル読み込みエラー: \$e');
              setState(() {
                debugInfo = 'ファイルアクセス権限エラー: ${path.split('/').last}';
              });
            }
          } else {
            print('❌ ファイルが存在しません: \$path');
          }
        } catch (e) {
          print('❌ ファイルアクセスエラー: \$path - \$e');
        }
      }
    }
    setState(() {
      debugInfo = '''テスト画像が見つかりません。
画像ファイルをアプリのDocumentsフォルダに配置してください:
\$homeDir/Documents/test.jpg または test.png''';
    });
    print('❌ テスト用画像が見つかりませんでした。');
    print('💡 以下の場所に画像ファイル（.jpg, .png）を配置してください:');
    print('   - \$homeDir/Documents/ (推奨)');
    print('   - デスクトップ、ダウンロード、画像フォルダ');
    print('=== テスト画像設定終了 ===');
  }

  Future<void> selectImage() async {
    setState(() {
      debugInfo = '画像選択を開始...';
    });

    try {
      print('画像選択を開始します...');

      // macOSでは image_picker は動作しないため、直接 file_picker を使用
      if (Platform.isMacOS) {
        setState(() {
          debugInfo = 'macOS: file_picker を使用します...';
        });
        print('macOSでfile_pickerを使用します');

        try {
          print('FilePicker.platform.pickFiles() を呼び出します...');
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.image,
            allowMultiple: false,
            allowedExtensions: null,
          );

          print('ファイルピッカー結果: \$result');
          if (result != null && result.files.isNotEmpty) {
            print('選択されたファイル数: \${result.files.length}');
            String? filePath = result.files.single.path;
            print('ファイルパス: \$filePath');
            if (filePath != null) {
              setState(() {
                selectedImage = File(filePath);
                debugInfo = 'file_picker で選択成功: ${filePath.split('/').last}\n\nAI推論を実行中...';
              });
              print('file_picker で画像が選択されました: \$filePath');

              // 画像選択後に自動で推論実行
              print('🔄 AI推論を開始します...');
              print('🧠 デモモード状態: \${isModelLoaded ? "準備完了" : "未初期化"}');
              if (isModelLoaded) {
                print('✅ predictImage()を呼び出します');
                await predictImage();
              } else {
                print('❌ モデルが未初期化のため推論をスキップ');
                setState(() {
                  debugInfo = '❌ AIモデルが準備できていません';
                });
              }
            } else {
              setState(() {
                debugInfo = 'file_picker: ファイルパスがnull';
              });
              print('ファイルパスがnullです');
            }
          } else {
            setState(() {
              debugInfo = 'file_picker: キャンセルまたは選択なし';
            });
            print('画像選択がキャンセルされました（resultがnullまたは空）');
          }
        } catch (e) {
          setState(() {
            debugInfo =
                'file_picker エラー: \$e\n\n代替案: テスト画像ボタンを使用するか、\nアプリのDocumentsフォルダに画像を配置してください。';
          });
          print('file_picker エラー: \$e');
          print('代替方法を使用してください（テスト画像ボタン）');
        }
      } else {
        // iOS/Android では image_picker を使用
        setState(() {
          debugInfo = 'iOS/Android: image_picker を使用...';
        });

        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1800,
          maxHeight: 1800,
          imageQuality: 80,
        );

        if (image != null) {
          setState(() {
            selectedImage = File(image.path);
            debugInfo = 'image_picker で選択成功: \${image.path}';
          });
          print('image_picker で画像が選択されました: \${image.path}');

          // 画像選択後に自動で推論実行
          if (isModelLoaded) {
            predictImage();
          }
        } else {
          setState(() {
            debugInfo = 'image_picker: キャンセルまたは選択なし';
          });
        }
      }
    } catch (e) {
      setState(() {
        debugInfo = '画像選択エラー: \$e';
      });
      print('画像選択エラー: \$e');
    }
  }

  // 画像推論機能（デモ版）
  Future<void> predictImage() async {
    print('🔍 === predictImage() 開始（デモ版）===');
    print('🖼️ selectedImage: \$selectedImage');
    print('🧠 isModelLoaded: \$isModelLoaded');
    print('🏷️ labels.length: \${labels.length}');
    
    if (selectedImage == null) {
      print('❌ selectedImage is null');
      setState(() {
        predictionResult = '❌ 画像が選択されていません';
        debugInfo = 'エラー: 画像が選択されていません';
      });
      return;
    }
    
    if (!isModelLoaded) {
      print('❌ モデル未初期化');
      setState(() {
        predictionResult = '❌ AIモデルが読み込まれていません';
        debugInfo = 'エラー: AIモデルが読み込まれていません';
      });
      return;
    }

    try {
      print('=== デモ画像推論開始 ===');
      setState(() {
        debugInfo = '🤖 デモAI推論中...\n\n画像を分析しています...';
        predictionResult = '';
      });

      // デモ用：画像分析をシミュレート
      await Future.delayed(const Duration(seconds: 2));

      // 画像を読み込んで基本的な分析
      Uint8List imageBytes = await selectedImage!.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        setState(() {
          predictionResult = '画像のデコードに失敗しました';
        });
        return;
      }

      // デモ用：画像の色調からキャラクターを推定
      String predictedLabel = await _demoImageAnalysis(image);
      double confidence = 75.0 + (math.Random().nextDouble() * 20); // 75-95%のランダム信頼度

      setState(() {
        predictionResult =
            '🎯 予測結果: $predictedLabel\n📊 信頼度: ${confidence.toStringAsFixed(1)}%\n\n💡 デモモード: 色調ベース推定\n（実際のAIモデルではありません）';
        debugInfo = '✅ デモ推論完了\n\n画像分析結果:\n- サイズ: ${image.width}x${image.height}\n- 形式: ${selectedImage!.path.split('.').last.toUpperCase()}';
      });

      print('✅ デモ推論完了: \$predictedLabel (\${confidence.toStringAsFixed(1)}%)');
    } catch (e) {
      setState(() {
        predictionResult = '推論エラー: \$e';
        debugInfo = '推論エラーが発生しました';
      });
      print('❌ 推論エラー: \$e');
    }
  }

  // デモ用：画像の色調分析
  Future<String> _demoImageAnalysis(img.Image image) async {
    // 画像の平均色を計算
    int totalR = 0, totalG = 0, totalB = 0;
    int pixelCount = 0;

    for (int y = 0; y < image.height; y += 10) {
      for (int x = 0; x < image.width; x += 10) {
        img.Pixel pixel = image.getPixel(x, y);
        totalR += pixel.r.toInt();
        totalG += pixel.g.toInt();
        totalB += pixel.b.toInt();
        pixelCount++;
      }
    }

    double avgR = totalR / pixelCount;
    double avgG = totalG / pixelCount;
    double avgB = totalB / pixelCount;

    print('📊 色調分析結果: R=\${avgR.toInt()}, G=\${avgG.toInt()}, B=\${avgB.toInt()}');

    // 色調からキャラクターを推定（デモロジック）
    if (labels.isNotEmpty) {
      if (avgR > avgG && avgR > avgB && avgR > 120) {
        // 赤系が多い → 炭治郎系
        return labels.firstWhere((label) => label.contains('炭治郎') || label.contains('Tanjiro'), 
                                orElse: () => labels[0]);
      } else if (avgB > avgR && avgB > avgG && avgB > 100) {
        // 青系が多い → 冷静なキャラ
        return labels.firstWhere((label) => label.contains('義勇') || label.contains('Giyuu'), 
                                orElse: () => labels.length > 1 ? labels[1] : labels[0]);
      } else if (avgG > avgR && avgG > avgB && avgG > 100) {
        // 緑系が多い → 自然系キャラ
        return labels.firstWhere((label) => label.contains('禰豆子') || label.contains('Nezuko'), 
                                orElse: () => labels.length > 2 ? labels[2] : labels[0]);
      } else if (avgR + avgG + avgB < 300) {
        // 暗い色調 → ダークなキャラ
        return labels.firstWhere((label) => label.contains('無惨') || label.contains('鬼'), 
                                orElse: () => labels.length > 3 ? labels[3] : labels[0]);
      }
    }

    return labels.isNotEmpty ? labels[math.Random().nextInt(labels.length)] : '不明';
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('キャラ判定(デモモード)'), // ナビゲーションバーのタイトル
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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

                // AI推論結果を表示
                if (predictionResult.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: CupertinoColors.systemBlue.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      predictionResult,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.systemBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 16),
                const Text(
                  '画像をアップロードしてください。\nデモAIでキャラを判定します。',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // デバッグ情報表示
                if (debugInfo.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'デバッグ情報:\n$debugInfo',
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                        fontFamily: 'Monaco', // 等幅フォント
                      ),
                    ),
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
                        setState(() {
                          debugInfo = 'テスト画像を検索中...';
                        });
                        setTestImage();
                      },
                      child: const Text('テスト画像'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // macOS用の追加説明
                if (Platform.isMacOS)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: CupertinoColors.systemOrange.withOpacity(0.3),
                      ),
                    ),
                    child: const Text(
                      '🚧 現在デモモード動作中\n'
                      '• 「テスト画像」ボタンでデモAI判定をテスト\n'
                      '• 画像選択後、色調ベースで推定を実行\n'
                      '• TensorFlow Liteは今後の実装予定\n'
                      '• 現在の推定は参考値です',
                      style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.label,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
