# AI Character Judgment – Kimetsu (Flutter + Teachable Machine)

「**鬼滅の刃**」の主要キャラクター（例：竈門炭治郎／竈門禰豆子／我妻善逸／嘴平伊之助）を、スマホやPCのカメラ画像から **TensorFlow Lite** モデルで分類するデモアプリです。  
**Teachable Machine** を使うことで、学習～モデル書き出しまでを GUI で数分で完了できます。  
目標：**30分で“動くもの”を作る**（最小構成のMVP）

---

## ✅ できること（MVP）

- カメラ or ギャラリー画像を読み込み
- 事前学習した **TFLite** モデルで推論
- 予測ラベルと確信度（確率）を画面表示

> **想定クラス（例）**  
> - 竈門炭治郎  
> - 竈門禰豆子  
> - 我妻善逸  
> - 嘴平伊之助

---

## 🏃 30分クイックスタート

### 1) モデルを用意（Teachable Machine）
1. [Teachable Machine](https://teachablemachine.withgoogle.com/) → **Image Project** を作成  
2. 左側の **Class** を上記4キャラ名に変更  
3. 各クラスに画像（10〜20枚以上推奨）をドラッグ&ドロップ（※自分で権利を確認できる画像を使用）  
4. **Train** をクリック（数分で完了）  
5. **Export** → **TensorFlow → Download my model**（TFLite）  
   - 生成物例：`model.tflite` と `labels.txt`（または `metadata` 付き）

> 画像収集を短時間で済ませたい場合は、まずは **数枚** でテスト→動いたら後からデータを増やして精度改善しましょう。

### 2) Flutter プロジェクトに追加
- 本リポジトリをクローン後、以下を追加

```
pubspec.yaml
├─ flutter:
│  ├─ assets:
│  │  ├─ assets/tflite/model.tflite
│  │  └─ assets/tflite/labels.txt
```

- 依存関係を追加して取得

```bash
flutter pub add tflite_flutter image
flutter pub get
```

- モデル/ラベルを `assets/tflite/` に配置し、`pubspec.yaml` に assets を登録

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/tflite/model.tflite
    - assets/tflite/labels.txt
```

### 3) 最小の推論コード（例）

```dart
// lib/main.dart
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

void main() => runApp(const KimetsuApp());

class KimetsuApp extends StatelessWidget {
  const KimetsuApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ClassifyPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ClassifyPage extends StatefulWidget {
  const ClassifyPage({super.key});
  @override
  State<ClassifyPage> createState() => _ClassifyPageState();
}

class _ClassifyPageState extends State<ClassifyPage> {
  late Interpreter _interpreter;
  late List<String> _labels;
  bool _ready = false;
  String _result = 'No result';
  img.Image? _preview;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/tflite/model.tflite');
    _labels = await DefaultAssetBundle.of(context)
        .loadString('assets/tflite/labels.txt')
        .then((s) => s.split('\n').where((e) => e.trim().isNotEmpty).toList());
    setState(() => _ready = true);
  }

  // 画像を 224x224 にリサイズし、[0,1] 正規化して [1,224,224,3] float32 に変換
  Float32List _preprocess(img.Image image, {int size = 224}) {
    final resized = img.copyResize(image, width: size, height: size);
    final buffer = Float32List(size * size * 3);
    int i = 0;
    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        final pixel = resized.getPixel(x, y);
        buffer[i++] = img.getRed(pixel) / 255.0;
        buffer[i++] = img.getGreen(pixel) / 255.0;
        buffer[i++] = img.getBlue(pixel) / 255.0;
      }
    }
    return buffer;
  }

  Future<void> _runDemoFromAsset() async {
    // デモ用：assets の画像を1枚読み込み（実運用はカメラ/ギャラリーで取得）
    final bytes = await DefaultAssetBundle.of(context).load('assets/demo.jpg');
    final image = img.decodeImage(bytes.buffer.asUint8List());
    if (image == null) return;

    setState(() => _preview = image);

    final input = _preprocess(image);
    final inputShape = _interpreter.getInputTensor(0).shape; // [1,224,224,3] など
    final outputShape = _interpreter.getOutputTensor(0).shape; // [1,numClasses]

    final inputBuffer = input.reshape([1, 224, 224, 3]);
    final outputBuffer = List.filled(outputShape.reduce((a, b) => a * b), 0.0)
        .reshape([1, outputShape.last]);

    _interpreter.run(inputBuffer, outputBuffer);
    final scores = outputBuffer[0] as List<double>;

    int best = 0;
    double bestScore = -1;
    for (int i = 0; i < scores.length; i++) {
      if (scores[i] > bestScore) {
        bestScore = scores[i];
        best = i;
      }
    }
    final label = (best < _labels.length) ? _labels[best] : 'Unknown';
    setState(() => _result = '$label  ${(bestScore * 100).toStringAsFixed(1)}%');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kimetsu Classifier')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!_ready) const Text('Loading model...'),
            if (_preview != null)
              Expanded(child: Image.memory(Uint8List.fromList(img.encodeJpg(_preview!)))),
            const SizedBox(height: 8),
            Text(_result, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _ready ? _runDemoFromAsset : null,
              child: const Text('Run Demo Inference'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 📁 ディレクトリ構成（例）

```
AI_characterjudgment_kimetu/
├─ lib/
│  └─ main.dart
├─ assets/
│  ├─ tflite/
│  │  ├─ model.tflite
│  │  └─ labels.txt
│  └─ demo.jpg
├─ pubspec.yaml
└─ README.md
```

---

## 🛠 今後の拡張案

- カメラプレビューに推論結果をリアルタイム表示  
- Top-3のラベル表示やしきい値設定  
- モデルの量子化（INT8）で速度最適化  
- データ収集・学習をスクリプト化  

---

## ⚖️ 注意事項

- キャラクター画像には著作権があります。学習は個人利用範囲にとどめ、公開時は自作素材などを使用してください。  
- 個人写真を使う場合はプライバシーに配慮してください。  

---

## ライセンス

MIT（予定）
