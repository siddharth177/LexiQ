import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/quiz_models.dart';
import '../models/word_meaning.dart';

List<QuizQuestion> generateQuestionsFromVocab(
    List<WordMeaning> vocabList, int count) {
  final usable = vocabList.where((w) => w.definition.isNotEmpty).toList();
  if (usable.length < 4) {
    throw Exception(
        'You need at least 4 words with definitions to generate a quiz from you vocab list.');
  }

  final rng = Random();
  final shuffled = List<WordMeaning>.from(usable)..shuffle(rng);
  final selected = shuffled.take(count.clamp(1, usable.length)).toList();

  return selected.map((word) {
    final wrongs = usable.where((w) => w.word != word.word).toList()
      ..shuffle(rng);
    final options = [
      word.definition,
      ...wrongs.take(3).map((w) => w.definition)
    ]..shuffle(rng);
    return QuizQuestion(
      word: word.word,
      correctAnswer: word.definition,
      options: options,
    );
  }).toList();
}

Future<List<QuizQuestion>> generateQuestionsFromAI(
    int count, int difficulty, String apiKey) async {
  final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
  final body = json.encode({
    "messages": [
      {
        "role": "system",
        "content":
            "Generate exactly $count English vocabulary MCQ questions at difficult $difficulty/5 (1=basic everyday words, 5=advanced academic and literary. Return ONLY JSON: {\"questions\":[{\"word\":\"word\",\"definition\":\"correct brief definition\",\"wrong1\":\"plausible wrong definition\",\"wrong2\":\"plausible wrong definition\",\"wrong3\":\"plausible wrong definition\"}]}}"
      },
      {"role": "user", "content": "Generate now."}
    ],
    "model": "llama-3.3-70b-versatile",
    "temperature": 0.2,
    "max_tokens": 1024,
    "top_p": 1,
    "stream": false,
    "response_format": {"type": "json_object"},
    "stop": null
  });

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    },
    body: body,
  );

  if (response.statusCode != 200) {
    throw Exception('Quiz generation via AI failed.');
  }

  final decoded = json.decode(response.body);
  final content =
      json.decode(decoded['choices'][0]['message']['content'] as String);
  final rng = Random();

  return (content['questions'] as List).map((q) {
    final options = [
      q['definition'] as String,
      q['wrong1'] as String,
      q['wrong2'] as String,
      q['wrong3'] as String
    ]..shuffle(rng);
    return QuizQuestion(
      word: q['word'] as String,
      correctAnswer: q['definition'] as String,
      options: options,
    );
  }).toList();
}
