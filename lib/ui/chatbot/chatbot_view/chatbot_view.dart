import 'package:ephor/ui/chatbot/chatbot_viewmodel/chatbot_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:googleai_dart/googleai_dart.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

class ChatbotView extends StatefulWidget {
  final ChatbotViewModel viewModel;
  const ChatbotView({super.key, required this.viewModel});

  @override
  State<ChatbotView> createState() => _ChatbotViewState();
}

class _ChatbotViewState extends State<ChatbotView> {
  GoogleAIClient? _client;
  final List<Content> _history = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;

  final systemInstruction = Content(
    parts: [
      TextPart('You are a helpful support assistant for an app called "Ephor". '),
      TextPart('You call yourself Augusta.'),
      TextPart('If a user asks about cooking, politely decline.'),
    ],
    role: 'user'
  );

  Future<void> _sendChat() async {
    _client ??= GoogleAIClient(
      config: GoogleAIConfig(
        authProvider: ApiKeyProvider(widget.viewModel.geminiApiKey!),
      ),
    );

    final message = _textController.text;
    if (message.isEmpty) return;

    // Create the user content part
    final userContent = Content(
      role: 'user',
      parts: [TextPart(message)],
    );

    setState(() {
      _loading = true;
      _history.add(userContent);
      _textController.clear();
    });
    
    _scrollDown();

    try {
      final response = await _client?.models.generateContent(
        model: 'gemini-2.5-pro',
        request: GenerateContentRequest(
          contents: _history,
          systemInstruction: systemInstruction
        ),
      );

      final text = (response?.candidates?.first.content?.parts.first as TextPart).text;

      final modelContent = Content(
        role: 'model',
        parts: [TextPart(text)],
      );

      setState(() {
        _history.add(modelContent);
      });
    } catch (e) {
      // Add an error message purely for UI (not adding to API history)
      setState(() {
        _history.add(Content(
          role: 'model', 
          parts: [TextPart('Error: $e')]
        ));
      });
    } finally {
      setState(() => _loading = false);
      _scrollDown();
    }
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeOutCirc,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Augusta AI'),
        leading: const Icon(Icons.auto_awesome),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final msg = _history[index];
                final text = (msg.parts.first as TextPart).text;
                return ListTile(
                  title: Align(
                    alignment: msg.role == 'user' 
                        ? Alignment.centerRight 
                        : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: msg.role == 'user' 
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectionArea(
                        child: GptMarkdown(
                          text,
                          style: TextStyle(
                            color: msg.role == 'user' 
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Ask Gemini something...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) { if (value != "") {_sendChat();}},
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _loading ? null : _sendChat,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}