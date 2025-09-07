import 'package:flutter/cupertino.dart';

// アプリのエントリポイント（最初に実行される場所）
void main() {
  // runAppに最上位ウィジェットを渡してアプリを起動
  runApp(const kimatuApp());
}

//cutarinoスタイルのアプリの最上位ウィジェット
class kimetuApp extends StatelessWidget {
  const kimatuApp({super.key});

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
class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
              const Text('画像アップロードまたは撮影してください。¥nAIでキャラを判定します。', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              CupertinoButton.filled(
                onPressed: () { //カメラ起動
                  // 画像アップロードまたは撮影の処理をここに追加※あとで実装
                },
                child: const Text('画像を選択'),
              ),
            ],)],

        ),
      ),
    );