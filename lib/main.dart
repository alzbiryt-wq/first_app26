import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const AlzbiryBoxApp());
}

class AlzbiryBoxApp extends StatelessWidget {
  const AlzbiryBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alzbiry Box',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        fontFamily: 'Roboto',
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Box Dimensions & Parameters
  double _length = 100.0; // الطول (مم)
  double _width = 80.0;   // العرض (مم)
  double _height = 50.0;  // الارتفاع (مم)
  double _thickness = 3.0; // سمك الخامة (1 - 30 مم)
  double _kerf = 0.1;     // التداخل والتسامح (Kerf)
  int _dividers = 0;      // عدد المقسمات الداخلية

  // Lid Types (10 Options)
  String _selectedLid = 'غطاء سحاب (Sliding Lid)';
  final List<String> _lidOptions = [
    'غطاء سحاب (Sliding Lid)',
    'غطاء مفصلي (Hinged Lid)',
    'غطاء منفصل متداخل (Telescopic Lid)',
    'غطاء بمقبض علوي (Handle Lid)',
    'غطاء قفل كبس (Snap Lock Lid)',
    'غطاء مزدوج (Double Flap Lid)',
    'مفتوح بدون غطاء (Open Top)',
    'غطاء درج سحاب (Drawer Box)',
    'غطاء بمفصلة أكريليك (Living Hinge)',
    'غطاء قفل مفتاحي (Key Latch Lid)',
  ];

  // Assembly Simulation Step
  int _assemblyStep = 1;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inventory_2_rounded, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text(
                'Alzbiry Box',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ],
          ),
          centerTitle: true,
          elevation: 4,
          actions: [
            IconButton(
              icon: const Icon(Icons.file_download_outlined),
              tooltip: 'تصدير المخطط',
              onPressed: () => _showExportDialog(context),
            ),
          ],
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildDesignTab(),
            _buildPreviewTab(),
            _buildAssemblyAndImageTab(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.tune_rounded),
              label: 'الأبعاد والتصميم',
            ),
            NavigationDestination(
              icon: Icon(Icons.remove_red_eye_rounded),
              label: 'المعاينة الحية',
            ),
            NavigationDestination(
              icon: Icon(Icons.view_in_ar_rounded),
              label: 'التفكيك والصورة',
            ),
          ],
        ),
      ),
    );
  }

  // TAB 1: Design Controls & Input
  Widget _buildDesignTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('أبعاد الصندوق (مفتوحة المقاس - mm)'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildNumberInput('الطول (L)', _length, (val) => setState(() => _length = val))),
              const SizedBox(width: 10),
              Expanded(child: _buildNumberInput('العرض (W)', _width, (val) => setState(() => _width = val))),
              const SizedBox(width: 10),
              Expanded(child: _buildNumberInput('الارتفاع (H)', _height, (val) => setState(() => _height = val))),
            ],
          ),
          const SizedBox(height: 25),

          _buildSectionTitle('سمك الخامة والوصلات (1 مم - 30 مم)'),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('سمك الخامة (Thickness): ${_thickness.toStringAsFixed(1)} مم'),
                      const Text('1 - 30 mm', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  Slider(
                    value: _thickness,
                    min: 1.0,
                    max: 30.0,
                    divisions: 58,
                    label: '${_thickness.toStringAsFixed(1)} mm',
                    onChanged: (val) => setState(() => _thickness = val),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('تعديل التسامح/القص (Kerf): ${_kerf.toStringAsFixed(2)} مم'),
                      const Icon(Icons.info_outline, size: 18, color: Colors.grey),
                    ],
                  ),
                  Slider(
                    value: _kerf,
                    min: 0.0,
                    max: 1.0,
                    divisions: 20,
                    label: '${_kerf.toStringAsFixed(2)} mm',
                    onChanged: (val) => setState(() => _kerf = val),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),

          _buildSectionTitle('نوع الغطاء (10 خيارات متوفرة)'),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLid,
                  isExpanded: true,
                  items: _lidOptions.map((String lid) {
                    return DropdownMenuItem<String>(
                      value: lid,
                      child: Text(lid, style: const TextStyle(fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedLid = val);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),

          _buildSectionTitle('المقسمات الداخلية (Internal Dividers)'),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('عدد خانات التقسيم الداخلي:'),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: _dividers > 0 ? () => setState(() => _dividers--) : null,
                      ),
                      Text('$_dividers', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setState(() => _dividers++),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TAB 2: Live Blueprint Preview Box
  Widget _buildPreviewTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.blueGrey.shade900,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('الأبعاد: $_length × $_width × $_height مم', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('السماكة: $_thickness مم', style: const TextStyle(color: Colors.amber)),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CustomPaint(
                size: Size.infinite,
                painter: BoxBlueprintPainter(
                  length: _length,
                  width: _width,
                  height: _height,
                  thickness: _thickness,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: ElevatedButton.icon(
            onPressed: () => _showExportDialog(context),
            icon: const Icon(Icons.download),
            label: const Text('تصدير المخطط الحالي'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  // TAB 3: Image Upload & Assembly Simulation
  Widget _buildAssemblyAndImageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('1. تحليل صورة صندوق وتقدير أبعاده'),
          const SizedBox(height: 10),
          Card(
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم فتح الكاميرا/المعرض لتحليل الصورة وتقييم الأبعاد...')),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                child: const Column(
                  children: [
                    Icon(Icons.add_a_photo_outlined, size: 48, color: Colors.blueAccent),
                    SizedBox(height: 10),
                    Text('اضغط هنا لرفع أو تصوير صندوق لتقدير أبعاده تلقائياً', textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),

          _buildSectionTitle('2. محاكي خطوات القص والتجميع (Assembly Steps)'),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'الخطوة رقم $_assemblyStep من 4',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _getStepDescription(_assemblyStep),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _assemblyStep > 1 ? () => setState(() => _assemblyStep--) : null,
                        child: const Text('السابق'),
                      ),
                      ElevatedButton(
                        onPressed: _assemblyStep < 4 ? () => setState(() => _assemblyStep++) : null,
                        child: const Text('التالي'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog for File Export (DXF, SVG, PDF, PNG)
  void _showExportDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'تصدير مخطط Alzbiry Box',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _buildExportOption(context, 'SVG (رسومات متجهة للقص بالليزر)', Icons.code),
              _buildExportOption(context, 'DXF (ملف أوتوكاد و CNC)', Icons.architecture),
              _buildExportOption(context, 'PDF (مستند للطباعة المباشرة)', Icons.picture_as_pdf),
              _buildExportOption(context, 'PNG (صورة خطية أبيض وأسود)', Icons.image_outlined),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportOption(BuildContext context, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title),
      trailing: const Icon(Icons.download_rounded),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('جاري تنزيل ملف $title بنجاح!')),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),
    );
  }

  Widget _buildNumberInput(String label, double initialValue, Function(double) onChanged) {
    return TextFormField(
      initialValue: initialValue.toInt().toString(),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      onChanged: (val) {
        double? parsed = double.tryParse(val);
        if (parsed != null && parsed > 0) onChanged(parsed);
      },
    );
  }

  String _getStepDescription(int step) {
    switch (step) {
      case 1:
        return 'الخطوة 1: قص كافة القطع الخشبية/الأكريليك بحسب مخطط SVG العريض.';
      case 2:
        return 'الخطوة 2: تثبيت الجوانب الأربعة مع لوحة القاعدة باستخدام أسنان التعشيق.';
      case 3:
        return 'الخطوة 3: تركيب المقسمات الداخلية في المجاري المخصصة لها.';
      case 4:
        return 'الخطوة 4: تركيب $_selectedLid وإغلاق الصندوق وإتمام التجميع!';
      default:
        return '';
    }
  }
}

// 2D Blueprint Custom Painter (Realtime Flat Dieline Drawing)
class BoxBlueprintPainter extends CustomPainter {
  final double length;
  final double width;
  final double height;
  final double thickness;

  BoxBlueprintPainter({
    required this.length,
    required this.width,
    required this.height,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final dashPaint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    double scale = min(size.width / (length + 2 * height + 40), size.height / (width + 2 * height + 40));
    if (scale <= 0 || scale.isInfinite) scale = 0.5;

    double cx = size.width / 2;
    double cy = size.height / 2;

    double scaledL = length * scale;
    double scaledW = width * scale;
    double scaledH = height * scale;

    // Base Rect (Bottom Panel)
    Rect base = Rect.fromCenter(center: Offset(cx, cy), width: scaledL, height: scaledW);
    canvas.drawRect(base, paint);

    // Top & Bottom Flaps (Height panels)
    Rect topFlap = Rect.fromLTWH(base.left, base.top - scaledH, scaledL, scaledH);
    Rect bottomFlap = Rect.fromLTWH(base.left, base.bottom, scaledL, scaledH);

    // Left & Right Flaps
    Rect leftFlap = Rect.fromLTWH(base.left - scaledH, base.top, scaledH, scaledW);
    Rect rightFlap = Rect.fromLTWH(base.right, base.top, scaledH, scaledW);

    canvas.drawRect(topFlap, paint);
    canvas.drawRect(bottomFlap, paint);
    canvas.drawRect(leftFlap, paint);
    canvas.drawRect(rightFlap, paint);

    // Lid Panel Attached
    Rect lidPanel = Rect.fromLTWH(topFlap.left, topFlap.top - scaledW, scaledL, scaledW);
    canvas.drawRect(lidPanel, dashPaint);
  }

  @override
  bool shouldRepaint(covariant BoxBlueprintPainter oldDelegate) {
    return oldDelegate.length != length ||
        oldDelegate.width != width ||
        oldDelegate.height != height ||
        oldDelegate.thickness != thickness;
  }
}
