import 'dart:async';

import 'package:calculation_exercise/controller.dart' as controller;
import 'package:flutter/material.dart';

import 'settings.dart' as settings;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await settings.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculation Exercise',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Calculation Exercise'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();

  StreamSubscription<void>? onNewAnswerSub;
  FocusNode? _focusNode;

  String? answer;
  String? error;

  void submitForm() {
    final state = _formKey.currentState;
    if (state == null) return;
    if (state.validate()) {
      state.save();
      state.reset();
    }
    _focusNode?.requestFocus();
  }

  void skipForm() {
    final state = _formKey.currentState;
    if (state == null) return;
    state.reset();
    controller.skip();
    _focusNode?.requestFocus();
  }

  void restartGame() {
    final state = _formKey.currentState;
    if (state == null) return;
    state.reset();
    controller.initGame();
    _focusNode?.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (settings.getHighestScore().isFinite)
                  Text(
                    "Lowest Score: ${settings.getHighestScore()}",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                if (controller.lastGameScore != null)
                  Text(
                    "Score: ${controller.lastGameScore}",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                Text(controller.displayStr, style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 20),
                TextFormField(
                  focusNode: _focusNode,
                  autofocus: true,
                  onFieldSubmitted: (v) => submitForm(),
                  validator: controller.submit,
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(onPressed: submitForm, child: const Text("Submit")),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(onPressed: skipForm, child: const Text("Skip")),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: restartGame,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text("Restart"),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    settings.setHighestScore(0);
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
                  child: const Text("Reset Score"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    controller.initGame();
    onNewAnswerSub = controller.onNewAnswer.listen((_) => setState(() {}));
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    onNewAnswerSub?.cancel();
    _focusNode?.dispose();
    super.dispose();
  }
}
