// questionnaire.dart
import 'package:flutter/material.dart';
import 'openai_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  String? _ageRange;
  List<String> _fitnessGoals = [];
  String? _foodPreference;
  Map<String, bool> _healthIssues = {
    'Burnout': false,
    'Stress': false,
    'Sleep Issues': false,
    'Posture issues': false,
    'Other': false,
  };
  String? _employeeType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Questionnaire'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('Name', style: Theme.of(context).textTheme.headline6),
            ),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'What should we call you?',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('Age Range',
                  style: Theme.of(context).textTheme.headline6),
            ),
            DropdownButtonFormField<String>(
              value: _ageRange,
              decoration: const InputDecoration(
                labelText: 'Select your age range',
                border: OutlineInputBorder(),
              ),
              items: ['20-30', '30-40', '40-50', '50+'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _ageRange = newValue;
                });
              },
              validator: (value) =>
                  value == null ? 'Please select your age range' : null,
            ),
            SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('Fitness Goals',
                  style: Theme.of(context).textTheme.headline6),
            ),
            // Fitness Goals (Multiple selection using FilterChip)
            Wrap(
              spacing: 8.0,
              children: [
                'Lose weight',
                'Build muscle',
                'Increase stamina',
                'Improve flexibility'
              ]
                  .map((goal) => FilterChip(
                        label: Text(goal),
                        selected: _fitnessGoals.contains(goal),
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              _fitnessGoals.add(goal);
                            } else {
                              _fitnessGoals.removeWhere((String name) {
                                return name == goal;
                              });
                            }
                          });
                        },
                      ))
                  .toList(),
            ),
            SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('Food Preference',
                  style: Theme.of(context).textTheme.headline6),
            ),
            // Food Preference (Single selection using DropdownButtonFormField)
            DropdownButtonFormField<String>(
              value: _foodPreference,
              decoration: InputDecoration(
                labelText: 'Select your food preference',
                border: OutlineInputBorder(),
              ),
              items: ['Vegetarian', 'Vegan', 'Non-Vegetarian', 'Other']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _foodPreference = newValue;
                });
              },
              validator: (value) =>
                  value == null ? 'Please select your food preference' : null,
            ),
            SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('Health Issues',
                  style: Theme.of(context).textTheme.headline6),
            ),
            // Health Issues (Multiple selection using CheckboxListTile)
            ..._healthIssues.keys.map((String key) {
              return CheckboxListTile(
                title: Text(key),
                value: _healthIssues[key],
                onChanged: (bool? value) {
                  setState(() {
                    _healthIssues[key] = value!;
                  });
                },
              );
            }).toList(),
            SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('Employee Type',
                  style: Theme.of(context).textTheme.headline6),
            ),
            // Employee Type (Single selection using RadioListTile)
            ...['Full-time', 'Part-time', 'Contractor', 'Intern']
                .map((String type) {
              return RadioListTile<String>(
                title: Text(type),
                value: type,
                groupValue: _employeeType,
                onChanged: (String? value) {
                  setState(() {
                    _employeeType = value;
                  });
                },
              );
            }).toList(),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Collect the data from the form fields
      String name = _nameController.text;
      String ageRange = _ageRange ?? '';
      List<String> fitnessGoals = _fitnessGoals;
      String foodPreference = _foodPreference ?? '';
      Map<String, bool> healthIssues = _healthIssues;
      String employeeType = _employeeType ?? '';

      // Save the questionnaire data to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', name);
      await prefs.setString('ageRange', ageRange);
      await prefs.setStringList('fitnessGoals', fitnessGoals);
      await prefs.setString('foodPreference', foodPreference);
      await prefs.setString('healthIssues', jsonEncode(healthIssues));
      await prefs.setString('employeeType', employeeType);
      await prefs.setBool('isQuestionnaireCompleted', true);

      // Create an instance of OpenAIService
      OpenAIService openAIService = OpenAIService();

      // Call the getResponse method with the collected data
      try {
        // Use the response from the OpenAI API as needed
        Navigator.pop(context); // Go back to the previous screen
      } catch (e) {
        // Handle any errors here
        print('Error submitting form: $e');
      }
    }
  }
}
