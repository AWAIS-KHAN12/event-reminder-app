import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  late final GenerativeModel model;

  AIService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
        'GEMINI_API_KEY not found in .env file. Make sure .env file exists and contains GEMINI_API_KEY=your_key',
      );
    }

    model = GenerativeModel(model: 'gemini-2.0-flash-exp', apiKey: apiKey);
  }

  Future<Map<String, dynamic>?> generateEventFromText(String inputText) async {
    final now = DateTime.now();

    final prompt =
        '''
Current Date-Time: $now

Act as an event scheduler. Analyze this text: "$inputText"

Extract and return ONLY a valid JSON object with these fields (no markdown, no code blocks, no extra text):
{
  "title": "Short event title",
  "description": "Event details or empty string",
  "category": "One of: Work, Personal, or Social",
  "date": "YYYY-MM-DD format",
  "time": "HH:MM in 24-hour format"
}

Example response:
{"title": "Team Meeting", "description": "Quarterly review", "category": "Work", "date": "2025-01-15", "time": "14:30"}

Return ONLY valid JSON.
''';

    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        print("❌ AI returned empty response");
        return null;
      }

      String rawResponse = response.text!;
      print("📝 Raw AI Response: $rawResponse");

      // Clean up the response - remove markdown wrappers
      String cleanJson = rawResponse
          .replaceAll('```json', '')
          .replaceAll('```dart', '')
          .replaceAll('```', '')
          .replaceAll('\\n', '')
          .trim();

      print("🧹 Cleaned JSON: $cleanJson");

      // Validate JSON starts with {
      if (!cleanJson.startsWith('{')) {
        print("❌ Invalid JSON format - doesn't start with {");
        return null;
      }

      final result = jsonDecode(cleanJson) as Map<String, dynamic>;

      print("✅ Successfully parsed: $result");
      return result;
    } on FormatException catch (e) {
      print("❌ JSON Parse Error: $e");
      return null;
    } catch (e) {
      print("❌ AI Service Error: $e");
      print("Stack trace: $e");
      return null;
    }
  }
}
