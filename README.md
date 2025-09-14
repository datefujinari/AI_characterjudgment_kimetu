# AI Character Judgment – Kimetsu (Flutter + Teachable Machine)

「**鬼滅の刃**」の主要キャラクター（例：竈門炭治郎／竈門禰豆子／我妻善逸／嘴平伊之助）を、スマホやPCのカメラ画像から **TensorFlow Lite** モデルで分類するFlutterアプリです。  
**Teachable Machine** を使うことで、学習～モデル書き出しまでを GUI で数分で完了できます。

---

## 🚧 現在の実装状況

### ✅ 完了済み
- Flutter Cupertino デザインによるUI実装
- 画像選択・プレビュー機能（テスト画像対応）
- TensorFlow Lite モデル読み込み準備
- assets フォルダ構成とファイル配置
- macOS 対応の基本実装

### 🔄 開発中
- 画像選択機能の安定化（file_pickerプラグイン）
- TensorFlow Lite 推論機能の統合
- クロスプラットフォーム対応

### 📱 対応予定クラス
- 竈門炭治郎  
- 竈門禰豆子  
- 我妻善逸  
- 嘴平伊之助ment – Kimetsu (Flutter + Teachable Machine)

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

## 🏃 セットアップ手順

### 1. モデルを用意（Teachable Machine）
1. [Teachable Machine](https://teachablemachine.withgoogle.com/) → **Image Project** を作成  
2. 左側の **Class** を上記4キャラ名に変更  
3. 各クラスに画像（10〜20枚以上推奨）をドラッグ&ドロップ（※自分で権利を確認できる画像を使用）  
4. **Train** をクリック（数分で完了）  
5. **Export** → **TensorFlow → Download my model**（TFLite）  
   - 生成物：`model.tflite` と `labels.txt`

### 2. Flutter プロジェクトの準備

```bash
# リポジトリをクローン
git clone https://github.com/datefujinari/AI_characterjudgment_kimetu.git
cd AI_characterjudgment_kimetu

# 依存関係をインストール
flutter pub get
```

### 3. モデルファイルの配置
生成したモデルファイルを以下の場所に配置：

```
assets/
└── models/
    ├── model.tflite    # Teachable Machine から生成
    └── labels.txt      # Teachable Machine から生成
```

### 4. アプリの実行

```bash
# macOS で実行
flutter run -d macos

# iOS シミュレータで実行
flutter run -d ios

# Android エミュレータで実行
flutter run -d android
```

---

## 💻 現在の実装

### 主要な機能
- **Cupertino Design**: iOS風の美しいUI
- **画像選択**: file_picker による画像ファイル選択
- **画像プレビュー**: 選択した画像の表示機能
- **テスト画像**: デバッグ用のサンプル画像機能

### 技術スタック
- **Framework**: Flutter 3.32.8
- **UI**: Cupertino (iOS風デザイン)
- **ML**: tflite_flutter ^0.11.0
- **ファイル選択**: file_picker ^8.0.0+1
- **画像処理**: image_picker ^1.1.2

### アーキテクチャ
```
lib/
└── main.dart              # メインアプリケーション
assets/
└── models/
    ├── model.tflite       # TensorFlow Lite モデル
    └── labels.txt         # クラスラベル
```

---

## � 今後の開発計画

### Phase 1: 基本機能完成
- [x] Flutter プロジェクト作成
- [x] UI デザイン実装
- [x] 画像選択機能実装
- [ ] TensorFlow Lite 推論機能統合
- [ ] クロスプラットフォーム対応改善

### Phase 2: 機能拡張
- [ ] カメラプレビューからのリアルタイム推論
- [ ] Top-3 予測結果表示
- [ ] 推論結果の信頼度しきい値設定
- [ ] 履歴機能

### Phase 3: 最適化
- [ ] モデルの量子化（INT8）で速度向上
- [ ] バッチ処理対応
- [ ] メモリ使用量最適化

---

## 🔧 開発者向け情報

### 既知の問題
- macOS での file_picker プラグインの安定性
- TensorFlow Lite ネイティブライブラリの動的読み込み
- Web プラットフォームでの dart:ffi 非対応

### デバッグ方法
1. **テスト画像ボタン**を使用して基本的な画像表示をテスト
2. デバッグコンソールでプラグインの動作ログを確認
3. プラットフォーム固有の問題は `Platform.is*` で分岐対応  

---

## ⚖️ 注意事項

- **著作権**: キャラクター画像には著作権があります。学習は個人利用範囲にとどめ、公開時は自作素材などを使用してください。  
- **プライバシー**: 個人写真を使う場合はプライバシーに配慮してください。  
- **利用規約**: Teachable Machine の利用規約を遵守してください。

---

## 🤝 コントリビューション

Issues や Pull Requests を歓迎します！  
開発に参加される場合は、まず Issue でディスカッションしてください。

---

## 📄 ライセンス

MIT License

---

## 👨‍💻 開発者

[@datefujinari](https://github.com/datefujinari)

---

*最終更新: 2025年9月14日*
