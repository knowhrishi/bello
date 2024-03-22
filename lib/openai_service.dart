import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String apiKey = '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';

  Future<String> getResponse(
    String prompt, {
    required String userPrompt,
    required String name,
    required String ageRange,
    required List<String> fitnessGoals,
    required String foodPreference,
    required Map<String, bool> healthIssues,
    required String employeeType,
  }) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    List<Map<String, String>> userMessages = [
      {"role": "user", "content": "My name is $name."},
      {"role": "user", "content": "My age range is $ageRange."},
      {
        "role": "user",
        "content": "My fitness goals are ${fitnessGoals.join(', ')}."
      },
      {"role": "user", "content": "My food preference is $foodPreference."},
      {
        "role": "user",
        "content":
            "I have the following health issues: ${healthIssues.entries.where((entry) => entry.value).map((entry) => entry.key).join(', ')}."
      },
      {"role": "user", "content": "My employee type is $employeeType."},
      {"role": "user", "content": userPrompt},
    ];

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4',
        'messages': [
          {
            "role": "system",
            "content":
                '''You are a helpful assistant. Who is trying to improves employee well-being both physical and mental, and 
          You are also trying to encourage employee communication. You are also responsible for providing employees with workout plans, nutrition plans, and mental health tips, suggestions, advice, and support. Based on a user's input, you should'''
          },
          ...userMessages,
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      print('Failed to fetch response: ${response.statusCode}');
      throw Exception('Failed to fetch response from OpenAI');
    }
  }
}
