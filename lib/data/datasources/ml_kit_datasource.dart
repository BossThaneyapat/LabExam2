import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class MLKitDataSource {
  // ลบ (script: ...) ออก เพราะเวอร์ชันใหม่มันฉลาดอยู่แล้วครับ
  final _textRecognizer = TextRecognizer();

  Future<String> scanReceiptText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText = await _textRecognizer.processImage(
      inputImage,
    );
    return recognizedText.text;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
