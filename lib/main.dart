import 'package:flutter/cupertino.dart';

// アプリのエントリポイント（最初に実行される関数）
void main() {
  // runAppに最上位ウィジェット（CupertinoApp）を渡す
  runApp(const KimetsuApp());
}

// Cupertinoスタイルの最上位ウィジェット
class KimetsuApp extends StatelessWidget {
  const KimetsuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      // ダーク/ライトは後で好みで
      theme: CupertinoThemeData(brightness: Brightness.light),
      home: HomePage(),
    );
  }
}

// ホーム画面
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('キャラ判定（試作版）')),
      child: SafeArea(
        child: Center(
          // まずは動く骨組み。後でカメラ/ギャラリー、AI判定を追加
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '画像を選ぶか撮影して、\nAIでキャラ候補を表示します。',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              CupertinoButton.filled(
                // TODO: ここでカメラ起動を実装
                onPressed: () {
                  // 後で実装：カメラプレビュー→撮影→判定
                },
                child: const Text('カメラで撮影（準備中）'),
              ),
              const SizedBox(height: 8),
              CupertinoButton(
                // TODO: ここでギャラリー選択を実装
                onPressed: () {
                  // 後で実装：ギャラリー→画像選択→判定
                },
                child: const Text('ギャラリーから選択（準備中）'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
