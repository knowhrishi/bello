import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_starthack24/questions.dart'; // Ensure this file exists and is correctly implemented
import 'package:flutter_tts/flutter_tts.dart';
import 'openai_service.dart'; // Ensure this file exists and is correctly implemented
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bello',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
      routes: {
        '/questionnaire': (context) => const QuestionnaireScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FlutterTts flutterTts = FlutterTts();
  final OpenAIService openAIService = OpenAIService();
  final TextEditingController _textController = TextEditingController();
  final List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _checkQuestionnaireCompletion();
  }

  void _checkQuestionnaireCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    bool isQuestionnaireCompleted =
        prefs.getBool('isQuestionnaireCompleted') ?? false;
    if (!isQuestionnaireCompleted) {
      Future.microtask(() => Navigator.pushNamed(context, '/questionnaire'));
    }
  }

  void _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _sendPrompt() async {
    final prompt = _textController.text;
    if (prompt.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      // Check if the questionnaire data is saved in SharedPreferences
      bool isQuestionnaireCompleted =
          prefs.getBool('isQuestionnaireCompleted') ?? false;
      if (isQuestionnaireCompleted) {
        // Retrieve the saved data
        String name = prefs.getString('name') ?? '';
        String ageRange = prefs.getString('ageRange') ?? '';
        List<String> fitnessGoals = prefs.getStringList('fitnessGoals') ?? [];
        String foodPreference = prefs.getString('foodPreference') ?? '';
        String healthIssuesJson = prefs.getString('healthIssues') ?? '{}';
        Map<String, bool> healthIssues =
            Map<String, bool>.from(jsonDecode(healthIssuesJson));
        String employeeType = prefs.getString('employeeType') ?? '';
        final response = await openAIService.getResponse(
          prompt,
          userPrompt: "", // Pass the user prompt correctly
          name: name,
          ageRange: ageRange,
          fitnessGoals: fitnessGoals,
          foodPreference: foodPreference,
          healthIssues: healthIssues,
          employeeType: employeeType,
        );
        setState(() {
          _messages.add(Message(content: prompt, sender: 'User'));
          _messages.add(Message(content: response, sender: 'Bot'));
        });
        _speak(response);
        _textController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bello'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Navigation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Questions'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/questionnaire');
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) {
                var message = _messages[index];
                bool isUserMessage = message.sender == 'User';
                return ChatBubble(
                  message: message.content,
                  isUserMessage: isUserMessage,
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'Ask a question...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => _sendPrompt(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendPrompt,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  String content;
  String sender;

  Message({required this.content, required this.sender});
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUserMessage;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isUserMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment:
            isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (isUserMessage) ...[
                const Text("User", style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                const Icon(Icons.person, size: 24),
              ] else ...[
                const Icon(Icons.android, size: 24),
                const SizedBox(width: 8),
                const Text("Bot", style: TextStyle(fontSize: 16)),
              ],
            ],
          ),
          BubbleSpecialThree(
            text: message,
            color: isUserMessage ? Colors.grey[300]! : const Color(0xFF1B97F3),
            tail: true,
            isSender: isUserMessage,
            textStyle: TextStyle(
              color: isUserMessage ? Colors.black : Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
