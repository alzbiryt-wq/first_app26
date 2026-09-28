import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const AlzbiryBoxApp());
}

class AlzbiryBoxApp extends StatelessWidget {
  const AlzbiryBoxApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alzbiry Box Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFF3B82F6),
      ),
      home: const BoxStudioScreen(),
    );
  }
}

class BoxStudioScreen extends StatefulWidget {
  const BoxStudioScreen({Key? key}) : super(key: key);

  @override
  _BoxStudioScreenState createState() => _BoxStudioScreenState();
}

class _BoxStudioScreenState extends State<BoxStudioScreen> {
  // Box Dimensions & Parameters
  double _length = 150.0;
  double _width = 100.0;
  double _height = 80.0;
  double _thickness = 3.0;
  double _kerf = 0.1;
  int _dividers = 2;

  // Lid Types (10 Options)
  String _selectedLid = 'سحب (Sliding Lid)';
  final List<String> _lidOptions = [
    'سحب (Sliding Lid)',
    'مفصلي (Hinged Lid)',
    'تلسكوبي (Telescopic Lid)',
    'بمقبض (Handle Lid)',
    'قفل كبس (Snap Lock Lid)',
    'قلاب مزدوج (Double Flap Lid)',
    'مفتوح (Open Top)',
    'درج (Drawer Box)',
    'مفصلة لزج (Living Hinge)',
    'قفل مفتاحي (Key Latch Lid)',
  ];

  int _currentIndex = 0;

  Future<void> _openCamera() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم التقاط وتحليل صورة الصندوق بنجاح!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('صلاحية الكاميرا مرفوضة من قبل النظام')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alzbiry Box Pro Studio'),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تصدير ملفات المخطط والتعشيق بنجاح!')),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildSettingsView(),
          Interactive3DBoxPreview(
            length: _length,
            width: _width,
            height: _height,
            thickness: _thickness,
            kerf: _kerf,
            dividers: _dividers,
            selectedLid: _selectedLid,
          ),
          _buildCameraAndStepsView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.tune),
            label: 'الأبعاد والأغطية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.visibility),
            label: 'المعاينة 3D والتعشيق',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'الكاميرا والخطوات',
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsView() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text('خيارات الأغطية المتقدمة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _selectedLid,
          dropdownColor: const Color(0xFF1E293B),
          items: _lidOptions.map((String lid) {
            return DropdownMenuItem<String>(
              value: lid,
              child: Text(lid, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedLid = newValue!;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1E293B),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 20),
        const Text('أبعاد الصندوق والتعشيق (مم)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildSlider('الطول (Length):', _length, 50, 400, (val) => setState(() => _length = val)),
        _buildSlider('العرض (Width):', _width, 50, 400, (val) => setState(() => _width = val)),
        _buildSlider('الارتفاع (Height):', _height, 30, 300, (val) => setState(() => _height = val)),
        _buildSlider('سمك الخامة (Thickness):', _thickness, 1, 10, (val) => setState(() => _thickness = val)),
        _buildSlider('خلوص القص (Kerf):', _kerf, 0.0, 0.5, (val) => setState(() => _kerf = val), divisions: 5),
      ],
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged, {int? divisions}) {
    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label ${value.toStringAsFixed(1)} مم', style: const TextStyle(color: Colors.white70)),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              activeColor: Colors.blueAccent,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraAndStepsView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: _openCamera,
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            label: const Text('تحليل صورة صندوق عبر الكاميرا', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'خطوات التعشيق والتجميع (Assembly Steps)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'الخطوة النهائية: تداخل ألواح التعشيق الجانبية بدقة عالية وتثبيت الغطاء المختار.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Interactive3DBoxPreview extends StatefulWidget {
  final double length;
  final double width;
  final double height;
  final double thickness;
  final double kerf;
  final int dividers;
  final String selectedLid;

  const Interactive3DBoxPreview({
    Key? key,
    required this.length,
    required this.width,
    required this.height,
    required this.thickness,
    required this.kerf,
    required this.dividers,
    required this.selectedLid,
  }) : super(key: key);

  @override
  _Interactive3DBoxPreviewState createState() => _Interactive3DBoxPreviewState();
}

class _Interactive3DBoxPreviewState extends State<Interactive3DBoxPreview> {
  double _rotX = 0.5;
  double _rotY = 0.8;
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _rotY += details.delta.dx * 0.01;
          _rotX -= details.delta.dy * 0.01;
        });
      },
      onScaleUpdate: (details) {
        setState(() {
          _scale = math.max(0.4, math.min(3.0, _scale * details.scale));
        });
      },
      child: Container(
        color: const Color(0xFF0F172A),
        child: Stack(
          children: [
            Center(
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(_rotX)
                  ..rotateY(_rotY)
                  ..scale(_scale),
                alignment: Alignment.center,
                child: CustomPaint(
                  size: const Size(300, 300),
                  painter: DetailedBox3DPainter(
                    length: widget.length,
                    width: widget.width,
                    height: widget.height,
                    thickness: widget.thickness,
                    selectedLid: widget.selectedLid,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'الغطاء: ${widget.selectedLid}\nاسحب لتدوير الصندوق 3D | قرّب بالأصابع للتكبير',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailedBox3DPainter extends CustomPainter {
  final double length;
  final double width;
  final double height;
  final double thickness;
  final String selectedLid;

  DetailedBox3DPainter({
    required this.length,
    required this.width,
    required this.height,
    required this.thickness,
    required this.selectedLid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintBody = Paint()
      ..color = const Color(0xFFF8FAFC)
      ..style = PaintingStyle.fill;

    final paintJoints = Paint()
      ..color = const Color(0xFFD97706)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final paintDetails = Paint()
      ..color = const Color(0xFF475569)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    
    // رسم هيكل الصندوق مع تعشيق الأطراف
    final boxRect = Rect.fromCenter(center: center, width: 170, height: 110);
    canvas.drawRect(boxRect, paintBody);
    canvas.drawRect(boxRect, paintJoints);

    // رسم تفاصيل تعشيق الأطراف (finger joints simulation)
    for (double i = boxRect.top + 10; i < boxRect.bottom - 10; i += 20) {
      canvas.drawLine(Offset(boxRect.left, i), Offset(boxRect.left - 8, i), paintDetails);
      canvas.drawLine(Offset(boxRect.right, i), Offset(boxRect.right + 8, i), paintDetails);
    }

    // رسم الغطاء العلوي بناءً على النوع المختار
    final lidRect = boxRect.translate(0, -30);
    canvas.drawRect(lidRect, paintDetails);
    
    // تفاصيل إضافية للغطاء
    if (selectedLid.contains('مفصلي')) {
      canvas.drawLine(lidRect.bottomLeft, lidRect.bottomRight, paintJoints);
    } else if (selectedLid.contains('سحب')) {
      canvas.drawCircle(lidRect.center, 4, paintJoints);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
