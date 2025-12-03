import 'package:ephor/ui/dashboard/subviews/overview/view_model/overview_viewmodel.dart';
import 'package:ephor/utils/responsiveness.dart';
import 'package:flutter/material.dart';

class OverviewSubView extends StatelessWidget {
  final OverviewViewModel viewModel;
  const OverviewSubView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Overview",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 24),
          // Top Statistics Row
          const _TopStatsRow(),
          const SizedBox(height: 24),
          // Bottom Content Row (Charts & Activity)
          const _BottomContentRow(),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SECTION 1: Top Statistics Cards
// -----------------------------------------------------------------------------

class _TopStatsRow extends StatelessWidget {
  const _TopStatsRow();

  @override
  Widget build(BuildContext context) {
    // Using LayoutBuilder to switch between Row (desktop) and Column (mobile)
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: "Training Needs Identified",
                  value: "205",
                  subtitle: "Training Identified",
                  // Gradient Red
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD32F2F), Color(0xFFEF5350)],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                  iconOrChart: _MockLineChart(),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _StatCard(
                  title: "Pending Training Requests",
                  value: "3",
                  subtitle: "Pending Training",
                  // Salmon/Pink
                  color: const Color(0xFFFF8A80),
                  textColor: Colors.black87,
                  iconOrChart: Icon(Icons.description_outlined, size: 48, color: Colors.black54),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _StatCard(
                  title: "Skills Gap Analysis",
                  value: "136",
                  subtitle: "Skills Gap Analysis",
                  // Dark Maroon
                  color: const Color(0xFF5D0000),
                  iconOrChart: Icon(Icons.track_changes_outlined, size: 48, color: Colors.white24),
                ),
              ),
            ],
          );
        } else {
          // Mobile layout (vertical)
          return Column(
            children: [
              _StatCard(
                title: "Training Needs Identified",
                value: "205",
                subtitle: "Training Identified",
                gradient: const LinearGradient(
                    colors: [Color(0xFFD32F2F), Color(0xFFEF5350)]),
                iconOrChart: _MockLineChart(),
              ),
              const SizedBox(height: 16),
              _StatCard(
                title: "Pending Training Requests",
                value: "3",
                subtitle: "Pending Training",
                color: const Color(0xFFFF8A80),
                textColor: Colors.black87,
                iconOrChart: const Icon(Icons.description_outlined, size: 48, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              _StatCard(
                title: "Skills Gap Analysis",
                value: "136",
                subtitle: "Skills Gap Analysis",
                color: const Color(0xFF5D0000),
                iconOrChart: const Icon(Icons.track_changes_outlined, size: 48, color: Colors.white24),
              ),
            ],
          );
        }
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color? color;
  final Gradient? gradient;
  final Color textColor;
  final Widget iconOrChart;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    this.color,
    this.gradient,
    this.textColor = Colors.white,
    required this.iconOrChart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: textColor.withOpacity(0.9), fontSize: 16)),
              const Spacer(),
              Text(value, style: TextStyle(color: textColor, fontSize: 36, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 12)),
            ],
          ),
          // Icon or Chart Positioned
          Positioned(
            right: 0,
            bottom: 0,
            top: 0, // Stretch to allow chart to fill height if needed
            child: Center(child: iconOrChart),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SECTION 2: Bottom Charts and Activity
// -----------------------------------------------------------------------------

class _BottomContentRow extends StatelessWidget {
  const _BottomContentRow();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _TrainingNeedsChartCard()),
              SizedBox(width: 24),
              Expanded(flex: 3, child: _RecentActivityCard()),
            ],
          );
        } else {
          return const Column(
            children: [
              _TrainingNeedsChartCard(),
              SizedBox(height: 24),
              _RecentActivityCard(),
            ],
          );
        }
      },
    );
  }
}

class _TrainingNeedsChartCard extends StatelessWidget {
  const _TrainingNeedsChartCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // Dark gradient background for chart card
        gradient: const LinearGradient(
          colors: [Color(0xFF3E0000), Color(0xFF5A1010)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Training Needs by Department",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Row(
              children: [
                // Donut Chart Mockup
                const Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: 0.76,
                          strokeWidth: 25,
                          backgroundColor: Colors.white12,
                          color: Color(0xFFEF5350), // Red progress
                        ),
                      ),
                      Text("76%", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                // Legend
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LegendItem(color: Colors.redAccent, label: "Business Developer"),
                      _LegendItem(color: Colors.white24, label: "Educator"),
                      _LegendItem(color: Colors.white24, label: "Development Needs"),
                      _LegendItem(color: Colors.white10, label: "Others"),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 12, height: 12,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 8),
          Expanded(
              child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Activity",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Header Row
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text("Employee", style: TextStyle(color: Colors.grey[600], fontSize: 12))),
                Expanded(flex: 2, child: Text("Enrolled", style: TextStyle(color: Colors.grey[600], fontSize: 12))),
                Expanded(flex: 2, child: Text("Status", style: TextStyle(color: Colors.grey[600], fontSize: 12))),
              ],
            ),
          ),
          const Divider(),
          // List Items
          Expanded(
            child: ListView(
              children: const [
                _ActivityRow(name: "Dady Ruman", time: "14 hours ago", status: "Completed", isCompleted: true),
                _ActivityRow(name: "Jall Kantin", time: "2 Forametes ago", status: "Pending", isCompleted: false),
                _ActivityRow(name: "Fhronel Woolk", time: "14 hours ago", status: "Completed", isCompleted: true),
                _ActivityRow(name: "Mrmiort Smith", time: "14 hours ago", status: "Completed", isCompleted: true),
                _ActivityRow(name: "Grinother Groman", time: "21 hours ago", status: "Pending", isCompleted: false),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final String name;
  final String time;
  final String status;
  final bool isCompleted;

  const _ActivityRow({
    required this.name,
    required this.time,
    required this.status,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(time, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.red : Colors.orange[200],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(status, style: TextStyle(color: Colors.grey[800], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Helper: Custom Painter for the wavy line chart visual
// -----------------------------------------------------------------------------
class _MockLineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(100, 50),
      painter: _LineChartPainter(),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.9, size.width * 0.5, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.75, 0, size.width, size.height * 0.2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}