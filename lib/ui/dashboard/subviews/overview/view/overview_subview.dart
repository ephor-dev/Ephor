import 'package:ephor/ui/dashboard/subviews/overview/view_model/overview_viewmodel.dart';
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
            style: Theme.of(context).textTheme.titleLarge
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
                  color: const Color.from(alpha: 0.867, red: 139, green: 0, blue: 0),
                  iconOrChart: _MockLineChart(),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _StatCard(
                  title: "Pending Training Requests",
                  value: "3",
                  subtitle: "Pending Training",
                  color: Theme.brightnessOf(context) == Brightness.light 
                    ? const Color.fromARGB(255, 238, 238, 238)
                    : Theme.of(context).colorScheme.surfaceContainerHigh,
                  textColor: Theme.of(context).colorScheme.onSurface.withAlpha(222),
                  iconOrChart: Icon(
                    Icons.description_outlined, 
                    size: 48, 
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(138)
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _StatCard(
                  title: "Skills Gap Analysis",
                  value: "136",
                  subtitle: "Skills Gap Analysis",
                  color: Theme.brightnessOf(context) == Brightness.light 
                    ? Colors.white
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                  textColor: Theme.of(context).colorScheme.onSurface.withAlpha(222),
                  iconOrChart: Icon(
                    Icons.track_changes_outlined, 
                    size: 48, 
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(138)
                  ),
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
                color: const Color.from(alpha: 0.867, red: 139, green: 0, blue: 0),
                iconOrChart: _MockLineChart(),
              ),
              const SizedBox(height: 16),
              _StatCard(
                title: "Pending Training Requests",
                value: "3",
                subtitle: "Pending Training",
                color: Theme.brightnessOf(context) == Brightness.light 
                  ? const Color.fromARGB(255, 238, 238, 238)
                  : Theme.of(context).colorScheme.surfaceContainerHigh,
                textColor: Theme.of(context).colorScheme.onSurface.withAlpha(222),
                iconOrChart: Icon(
                  Icons.description_outlined, 
                  size: 48, 
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(138)
                ),
              ),
              const SizedBox(height: 16),
              _StatCard(
                title: "Skills Gap Analysis",
                value: "136",
                subtitle: "Skills Gap Analysis",
                color: Theme.brightnessOf(context) == Brightness.light 
                  ? Colors.white
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
                textColor: Theme.of(context).colorScheme.onSurface.withAlpha(222),
                iconOrChart: Icon(
                  Icons.track_changes_outlined, 
                  size: 48, 
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(138)
                ),
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
  final Color textColor;
  final Widget iconOrChart;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    this.color,
    this.textColor = Colors.white,
    required this.iconOrChart,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Card(
        color: color,
        shadowColor: Colors.black,
        elevation: 1.0,
        child: Padding(
          padding: const EdgeInsets.all(20),
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
        ),
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
    return SizedBox(
      height: 350,
      width: double.infinity,
      child: Card(
        color: Theme.brightnessOf(context) == Brightness.light
          ? Colors.white
          : Theme.of(context).colorScheme.surfaceContainerHighest,
        shadowColor: Theme.of(context).colorScheme.onSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Training Needs by Department",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18, fontWeight: FontWeight.bold
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    // Donut Chart Mockup
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: CircularProgressIndicator(
                              value: 0.76,
                              strokeWidth: 25,
                              backgroundColor: Theme.brightnessOf(context) == Brightness.light
                                ? Color.fromARGB(31, 114, 114, 114)
                                : Theme.of(context).colorScheme.outlineVariant,
                              color: Theme.brightnessOf(context) == Brightness.light 
                                ? Color.from(alpha: 0.867, red: 139, green: 0, blue: 0)
                                : Theme.of(context).colorScheme.primaryContainer,
                            ),
                          ),
                          Text(
                            "76%", 
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface, 
                              fontSize: 24, 
                              fontWeight: FontWeight.bold
                            )
                          ),
                        ],
                      ),
                    ),
                    // Legend
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LegendItem(color: Color.from(alpha: 0.867, red: 139, green: 0, blue: 0), label: "Business Developer"),
                          _LegendItem(color: Color.fromARGB(221, 0, 0, 0), label: "Educator"),
                          _LegendItem(color: Color.fromARGB(221, 54, 54, 54), label: "Development Needs"),
                          _LegendItem(color: Color.fromARGB(221, 88, 88, 88), label: "Others"),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
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
            child: Text(
              label, 
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface, 
                fontSize: 12
              ), 
            overflow: TextOverflow.ellipsis
            )
          ),
        ],
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      width: double.infinity,
      child: Card(
        color: Theme.brightnessOf(context) == Brightness.light
          ? Colors.white
          : Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadowColor: Theme.of(context).colorScheme.onSurface,
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                    Expanded(
                      flex: 3, 
                      child: Text(
                        "Employee", 
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface, 
                          fontSize: 12
                        )
                      )
                    ),
                    Expanded(
                      flex: 2, 
                      child: Text(
                        "Enrolled", 
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface, 
                          fontSize: 12
                        )
                      )
                    ),
                    Expanded(
                      flex: 2, 
                      child: Text(
                        "Status", 
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface, 
                          fontSize: 12
                        )
                      )
                    ),
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
        ),
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
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 16, color: Theme.of(context).colorScheme.surfaceContainerLowest),
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
                    color: isCompleted ? Color.from(alpha: 0.867, red: 139, green: 0, blue: 0) : const Color.fromARGB(255, 122, 122, 122),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(status, style: TextStyle(color: Colors.grey, fontSize: 12)),
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
      ..color = Colors.white.withAlpha(13)
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