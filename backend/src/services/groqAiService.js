import { env } from '../config/env.js';
import { httpError } from '../utils/httpError.js';

const endpoint = 'https://api.groq.com/openai/v1/chat/completions';

export async function generateDailyPlan(input) {
  const apiKey = env.groqApiKey;
  if (!apiKey) {
    throw httpError(500, 'GROQ_API_KEY belum diatur di backend .env.');
  }

  const response = await fetch(endpoint, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: env.groqModel,
      temperature: 0.2,
      max_completion_tokens: 1800,
      response_format: { type: 'json_object' },
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: JSON.stringify(input) },
      ],
    }),
  });

  const body = await response.json().catch(() => ({}));
  if (!response.ok) {
    const message = body?.error?.message || body?.message || 'Gagal menghubungi Groq API.';
    throw httpError(response.status, message);
  }

  const content = body?.choices?.[0]?.message?.content;
  if (!content || typeof content !== 'string') {
    throw httpError(502, 'Response Groq kosong.');
  }

  try {
    return JSON.parse(content);
  } catch {
    const fallback = extractJsonObject(content);
    if (!fallback) {
      throw httpError(502, 'AI mengembalikan format JSON yang tidak valid.');
    }
    return JSON.parse(fallback);
  }
}

function extractJsonObject(raw) {
  const start = raw.indexOf('{');
  const end = raw.lastIndexOf('}');
  if (start === -1 || end === -1 || end <= start) return null;
  return raw.slice(start, end + 1);
}

const systemPrompt = `
Kamu adalah AI perencana harian untuk aplikasi belajar Ploopy.
Balas hanya dengan JSON valid. Jangan gunakan markdown atau teks tambahan.

Tugas:
- Susun jadwal harian realistis berdasarkan task belum selesai dan schedule yang sudah ada.
- Jangan pernah membuat jadwal yang bentrok dengan existing_schedules.
- Jangan jadwalkan task yang is_completed bernilai true.
- Prioritaskan task priority high dan deadline terdekat.
- Tambahkan jeda istirahat jika hari terlalu padat.
- Jika tidak ada task, boleh memberi saran blok produktif ringan.
- Patuhi revision_instruction jika tersedia.

Format JSON wajib:
{
  "summary": "ringkasan singkat dalam bahasa Indonesia",
  "plans": [
    {
      "title": "judul jadwal",
      "description": "deskripsi singkat",
      "start_time": "ISO-8601 local datetime",
      "end_time": "ISO-8601 local datetime",
      "type": "task|break|study|planning",
      "source": "ai",
      "related_task_id": "id task atau null"
    }
  ]
}
`;
