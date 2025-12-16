import 'dart:math';

import 'package:ephor/data/repositories/form/form_repository.dart';
import 'package:ephor/domain/models/overview/activity_model.dart';
import 'package:ephor/utils/command.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/format_time_stamp.dart';
import 'package:ephor/utils/overview_args.dart';
import 'package:ephor/utils/results.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';

class OverviewViewModel extends ChangeNotifier {
  final FormRepository _formRepository;
  
  // 1. Data Source for Counts
  int _trainingNeedsCount = 0;
  int get trainingNeedsCount => _trainingNeedsCount;
  
  // 2. Data Source for Lists (Activity)
  List<ActivityModel> _recentActivity = [];
  List<ActivityModel> get recentActivity => _recentActivity;

  // 3. Data Source for Detailed Analysis (The JSON Report)
  Map<String, dynamic>? _fullReport;
  Map<String, dynamic>? get fullReport => _fullReport;

  String _lastUpdate = "";
  String get lastUpdate => _lastUpdate;

  String _geminiInsights = "";
  String get geminiInsights => _geminiInsights;

  final ScreenshotController screenshotController = ScreenshotController();
  late CommandWithArgs screenshot;

  OverviewViewModel({required FormRepository formRepository}) 
      : _formRepository = formRepository {
    _subscribeToUpdates();

    _loadData();

    screenshot = CommandWithArgs<void, OverviewArgs>(_screenshotPage);
  }

  void _subscribeToUpdates() {
    // Use a Supabase Stream to listen for changes in real-time
    _formRepository.getOverviewStatsStream().listen((stats) {
      if (stats.isEmpty) return;

      // Update basic integer counts
      _trainingNeedsCount = stats['training_needs_count'] ?? 0;

      // Update the full report JSON (used for Strategic Priorities UI)
      _fullReport = stats['full_report'];

      // Update Activity List
      // Note: Supabase returns a List<dynamic> of Maps. We must convert them to Models.
      _recentActivity = stats['recent_activity'] as List<ActivityModel>? ?? [];
      _lastUpdate = formatTimestamp(stats['updated_at']);
      _geminiInsights = stats['gemini_insights'];

      notifyListeners();
    });
  }

  void _loadData() async {
    final result = await _formRepository.getOverviewStats();

    if (result case Ok(value: Map<String, dynamic> stats)) {
      _loadStats(stats);
    }
  }

  void _loadStats(Map<String, dynamic> stats) {
    if (stats.isEmpty) return;

      // Update basic integer counts
      _trainingNeedsCount = stats['training_needs_count'] ?? 0;

      // Update the full report JSON (used for Strategic Priorities UI)
      _fullReport = stats['full_report'];

      // Update Activity List
      // Note: Supabase returns a List<dynamic> of Maps. We must convert them to Models.
      _recentActivity = stats['recent_activity'] as List<ActivityModel>? ?? [];
      _lastUpdate = 'Last Update: ${formatTimestamp(stats['updated_at'])}';
      _geminiInsights = stats['gemini_insights'];

      notifyListeners();
  }

  Future<Result<String>> _screenshotPage(OverviewArgs args) async {
    try {
      final mediaQueryData = MediaQuery.of(args.context);
      final themeData = Theme.of(args.context);

      final Uint8List imageBytes = await screenshotController.captureFromLongWidget(
        MediaQuery(
          data: mediaQueryData,
          child: Theme(
            data: themeData,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Material(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: args.widget,
                ),
              ),
            ),
          ),
        ),
        context: args.context, 
        delay: const Duration(milliseconds: 150),
        constraints: const BoxConstraints(maxWidth: 800),
        pixelRatio: 2.0,
      );

      final img.Image? decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) return Result.error(CustomMessageException("Failed to decode image"));

      final pdf = pw.Document();
      final int pageHeight = (decodedImage.width * 1.414).toInt();
      int currentY = 0;

      while (currentY < decodedImage.height) {
        final int sliceHeight = min(pageHeight, decodedImage.height - currentY);

        final img.Image slice = img.copyCrop(
          decodedImage, 
          x: 0, 
          y: currentY, 
          width: decodedImage.width, 
          height: sliceHeight
        );

        final Uint8List sliceBytes = img.encodePng(slice);
        final sliceImage = pw.MemoryImage(sliceBytes);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.zero,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(sliceImage, fit: pw.BoxFit.fitWidth, alignment: pw.Alignment.topCenter),
              );
            },
          ),
        );

        // Move the cursor down for the next iteration
        currentY += sliceHeight;
      }

      final now = DateTime.now();
      final timestamp = "${now.year}${now.month.toString().padLeft(2,'0')}${now.day.toString().padLeft(2,'0')}_${now.hour}${now.minute}";
      
      // 4. Save
      final Uint8List pdfBytes = await pdf.save();

      final result = await FileSaver.instance.saveFile(
        name: 'Overview_$timestamp',
        bytes: pdfBytes,
        ext: 'pdf',
        mimeType: MimeType.pdf,
      );
      
      return Result.ok(result);

    } catch (e) {
      return Result.error(CustomMessageException(e.toString()));
    }
  }
}