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
      TextPart('You are "Augustus", the dedicated AI support assistant for the "Ephor" application.'),
      TextPart('Your tone is professional, helpful, and concise. If asked about topics outside of Ephor (like cooking or sports), politely decline.'),
      
      TextPart('''
      --- SYSTEM KNOWLEDGE BASE: EPHOR & BATSTATEU ---
      
      1. ORGANIZATIONAL CONTEXT:
      - Institution: Batangas State University - The National Engineering University (BatStateU - The NEU).
      - Core Values: Patriotism, Service, Integrity, Resilience, Excellence, Faith.
      - Mission: Developing leaders in the global knowledge economy.
      - Key Campuses: 
          * Main: Pablo Borbon (Batangas City), Alangilan (Batangas City).
          * Extension/Satellite: ARASOF-Nasugbu, JPLPC-Malvar, Lipa, Balayan, Lemery, Lobo, Rosario, San Juan, Mabini.
      - Key Colleges (Departments):
          * College of Engineering (CoE).
          * College of Architecture, Fine Arts and Design (CAFAD).
          * College of Informatics and Computing Sciences (CICS).
          * College of Teacher Education (CTE).
          * College of Medicine.
          * College of Law.
          * CABEIHM (Accountancy, Business, Economics, etc.).

      2. APP OVERVIEW:
      Ephor is a Competency Assessment and Training Needs Analysis (CATNA) system built for the Human Resource Management Office (HRMO) and Supervisors of BatStateU. It automates the analysis of training gaps and evaluates the impact of training interventions.

      3. KEY ACRONYMS & METRICS:
      - CATNA: Competency Assessment and Training Needs Analysis.
      - IA: Impact Assessment.
      - Focus Areas (Metrics):
          * OS: Organizational Effectiveness (Process improvement, efficiency).
          * FS: Functional Skills (Technical skills relevant to the specific college/job).
          * AW: Attitude & Work Ethics (Professionalism, resilience).
          * SMS: Effective Personal Management (Time management, stress handling).
      
      4. USER ROLES & WORKFLOWS:
      - HRMO (Admin): Oversees university-wide strategic priorities. Can add/batch-add employees.
      - Supervisor: Conducts assessments for their specific Department/College.
      - Workflow: 
          1. Supervisor fills CATNA -> 2. Augustus (AI) analyzes gaps -> 3. Training Plan generated.
          4. Training occurs -> 5. Supervisor fills IA -> 6. Augustus evaluates if Retake is needed.

      5. TECHNICAL CONTEXT (Troubleshooting):
      - Backend: Supabase.
      - Data Storage: Dates are stored as ISO-8601 strings (YYYY-MM-DDTHH:MM:SS) to prevent parsing errors.
      - Assessment History: Stored as a Map (JSONB) inside the 'employees' table, containing keys like 'result', 'is_done', 'action_date', and 'added_at'.
      - Analysis Status: The "isAnalysisRunning" flag is a ValueNotifier; if the spinner gets stuck, check the 'catna_status' stream or the background trigger.

      6. DASHBOARD INSIGHTS:
      - When generating insights, prioritize the "Top 3 Needs" university-wide.
      - If a specific campus (e.g., Alangilan) has low scores in "FS" (Functional Skills), recommend technical workshops relevant to their specialization (e.g., Engineering/Architecture).
      '''),
    ],
    role: 'user',
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
        model: 'gemini-2.0-flash',
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
        title: const Text('Augustus AI'),
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