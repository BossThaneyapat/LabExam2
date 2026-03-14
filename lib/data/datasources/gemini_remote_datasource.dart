import 'dart:convert'; // เพิ่มตัวนี้
import 'dart:typed_data'; // เพิ่มตัวนี้
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiRemoteDataSource {
  final Dio _dio;
  GeminiRemoteDataSource(this._dio);

  // เปลี่ยนชื่อฟังก์ชันเป็น analyzeReceiptImage และรับรูปภาพแทน
  Future<Map<String, dynamic>> analyzeReceiptImage(Uint8List imageBytes) async {
    final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    const url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent';

    // แปลงรูปเป็น Base64
    String base64Image = base64Encode(imageBytes);

    try {
      final response = await _dio.post(
        url,
        options: Options(headers: {'x-goog-api-key': apiKey}),
        data: {
          "contents": [
            {
              "parts": [
                {
                  // ในไฟล์ gemini_remote_datasource.dart ตรง Prompt ของ analyzeReceiptImage
                  "text":
                      "Analyze this receipt image and return ONLY JSON in Thai language. "
                      "Fields: 'title' (Store Name), "
                      "'amount' (Final Net Total as double), "
                      "'date' (ISO format YYYY-MM-DD, extract from receipt), " // เพิ่มส่วนนี้
                      "'items' (List of {name: String, price: double}). "
                      "Focus on accurate Thai names. No markdown.",
                },
                {
                  "inline_data": {
                    "mime_type": "image/jpeg",
                    "data": base64Image,
                  },
                },
              ],
            },
          ],
        },
      );

      if (response.statusCode == 200) {
        String result =
            response.data['candidates'][0]['content']['parts'][0]['text'];
        result = result.replaceAll('```json', '').replaceAll('```', '').trim();
        return {"raw": result};
      } else {
        return {"raw": "Error: ${response.statusCode}"};
      }
    } on DioException catch (e) {
      print("❌ AI Error: ${e.response?.data}");
      return {"raw": "AI Error: ${e.response?.statusCode}"};
    }
  }
}
