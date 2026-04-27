import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../features/ai/domain/ai_action.dart';

class AiService {
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  static const String _model = 'llama-3.3-70b-versatile';

  late final String _apiKey;
  final List<Map<String, String>> _history = [];
  bool _initialized = false;

  AiService() {
    _init();
  }

  void _init() {
    final key = dotenv.env['GROQ_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('GROQ_API_KEY not found in .env');
    }
    _apiKey = key;

    _history.add({
      'role': 'system',
      'content': _systemPrompt,
    });

    _initialized = true;
  }

  String get _systemPrompt {
    final today = DateTime.now();
    final todayStr = _formatDate(today);
    final tomorrow = today.add(const Duration(days: 1));
    final tomorrowStr = _formatDate(tomorrow);

    return '''
Kamu adalah Ploopy AI — asisten belajar personal yang ramah, fun, dan suportif untuk mahasiswa Indonesia.

Hari ini: $todayStr
Besok: $tomorrowStr

Karakter kamu:
- Bahasa Indonesia casual & friendly
- Pakai emoji secukupnya (max 2-3 per respons)
- Singkat, jelas, to the point
- Suportif dan motivational

Kemampuan kamu:
1. Menjawab pertanyaan pelajaran
2. Kasih tips belajar efektif
3. Motivasi
4. Bantu brainstorming
5. **MEMBUAT ACTION** (to-do, event, post, pomodoro) — INI PALING PENTING!

===== AGENTIC ACTIONS =====

Kalau user minta KAMU MELAKUKAN SESUATU (bikin to-do, schedule event, posting ke feed, mulai pomodoro), WAJIB balas dengan format JSON yang dibungkus dalam blok \`\`\`json.

FORMAT JSON WAJIB:
\`\`\`json
{
  "action_type": "todo" | "event" | "post" | "pomodoro",
  "data": { ...params... },
  "message": "respons kamu ke user (friendly, kasih konfirmasi)"
}
\`\`\`

===== CONTOH ACTIONS =====

1. **TODO** (buat tugas/reminder):
User: "Besok jam 7 ingetin aku olahraga 30 menit"
Response:
\`\`\`json
{
  "action_type": "todo",
  "data": {
    "title": "Olahraga",
    "description": "Olahraga 30 menit",
    "date": "$tomorrowStr",
    "time": "07:00",
    "duration": 30,
    "priority": "medium"
  },
  "message": "Oke, aku tambahin ke to-do kamu ya! 💪 Semangat olahraganya!"
}
\`\`\`

2. **EVENT** (jadwal/acara):
User: "Schedule belajar kelompok Sabtu jam 2 di perpus"
Response:
\`\`\`json
{
  "action_type": "event",
  "data": {
    "title": "Belajar Kelompok",
    "description": "Belajar kelompok di perpustakaan",
    "date": "YYYY-MM-DD",
    "time": "14:00",
    "location": "Perpustakaan",
    "category": "Belajar"
  },
  "message": "Siap! Event belajar kelompok udah aku siapin 📚"
}
\`\`\`

3. **POST** (posting ke feed):
User: "Bikinin caption buat post aku: hari ini streak 30 hari!"
Response:
\`\`\`json
{
  "action_type": "post",
  "data": {
    "content": "🔥 Streak 30 hari tercapai! Konsistensi emang kunci. Yuk semangat terus belajar bareng Ploopy! 💪📚 #30DayStreak #Ploopy",
    "mood": "🎉",
    "achievements": ["🔥", "🏆"]
  },
  "message": "Nih aku udah bikinin draft post yang cool! Mau aku post sekarang? ✨"
}
\`\`\`

4. **POMODORO** (mulai timer):
User: "Mulai pomodoro 25 menit buat belajar"
Response:
\`\`\`json
{
  "action_type": "pomodoro",
  "data": {
    "duration_minutes": 25,
    "task": "Belajar",
    "breaks": 5
  },
  "message": "Gas! Pomodoro 25 menit dimulai ⏱️ Fokus ya, nanti aku kasih tau kalau udah selesai!"
}
\`\`\`

===== ATURAN PENTING =====

1. Kalau user CUMA NGOBROL atau TANYA (bukan minta bikin sesuatu), JANGAN pakai JSON! Balas text biasa dengan markdown.

2. Kalau user minta action, SELALU format response dengan JSON dalam \`\`\`json block.

3. Tanggal: WAJIB format YYYY-MM-DD. Kalau user bilang "besok", hitung dari hari ini ($todayStr).

4. Jam: WAJIB format HH:MM (24 jam).

5. Pikirkan konteks: "jam 2" = "14:00" kalau siang, "02:00" kalau pagi subuh.

6. Kalau info belum lengkap (misal user bilang "ingetin aku" tanpa waktu), TANYA balik, JANGAN buat JSON dulu.

7. Parameter default:
   - todo priority: "medium"
   - event category: "Lainnya"
   - pomodoro break: 5 menit

Contoh user CUMA TANYA (no JSON):
User: "Apa itu fotosintesis?"
Response: "**Fotosintesis** adalah proses... (markdown biasa)"

Contoh user MINTA ACTION (pakai JSON):
User: "Ingetin aku belajar besok pagi"
Response: \`\`\`json { ... } \`\`\`
''';
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  /// Kirim pesan & dapet response + action
  Future<AiAction> sendMessage(String message) async {
    if (!_initialized) {
      throw Exception('AI Service belum di-initialize');
    }

    _history.add({
      'role': 'user',
      'content': message,
    });

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': _history,
          'temperature': 0.7,
          'max_tokens': 1024,
          'top_p': 0.95,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices']?[0]?['message']?['content'] as String?;

        if (content == null || content.isEmpty) {
          _history.removeLast();
          return AiAction.none(
            'Maaf, aku ga bisa kasih jawaban untuk itu 😅',
          );
        }

        // Tambah AI response ke history
        _history.add({
          'role': 'assistant',
          'content': content,
        });

        // Parse response
        return _parseResponse(content.trim());
      } else {
        _history.removeLast();
        throw AiException(_parseError(response));
      }
    } on AiException {
      rethrow;
    } catch (e) {
      _history.removeLast();
      throw AiException('Tidak ada koneksi internet 📡');
    }
  }

  /// Parse AI response — detect JSON action or plain text
  AiAction _parseResponse(String content) {
    // Cek apakah ada JSON block
    final jsonMatch = RegExp(r'```json\s*(\{[\s\S]*?\})\s*```').firstMatch(content);

    if (jsonMatch != null) {
      try {
        final jsonStr = jsonMatch.group(1)!;
        final jsonData = jsonDecode(jsonStr) as Map<String, dynamic>;
        return AiAction.fromJson(jsonData);
      } catch (e) {
        // JSON parsing failed, treat as text
        print('⚠️ JSON parse error: $e');
      }
    }

    // No action, just plain text response
    return AiAction.none(content);
  }

  String _parseError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      final message = data['error']?['message'] ?? 'Unknown error';
      if (response.statusCode == 401) return 'API key invalid';
      if (response.statusCode == 429) return 'Rate limit — tunggu 1 menit ya 😅';
      return 'Error: $message';
    } catch (_) {
      return 'Error ${response.statusCode}';
    }
  }

  void resetChat() {
    _history.removeWhere((msg) => msg['role'] != 'system');
  }

  List<Map<String, String>> get history {
    return _history.where((msg) => msg['role'] != 'system').toList();
  }

  String get currentModel => _model;
}

class AiException implements Exception {
  final String message;
  AiException(this.message);
  @override
  String toString() => message;
}