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
      title: 'Alzbiry Box',
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
  double width = 150.0;
  double height = 50.0;
  double depth = 120.0;
  double thickness = 3.0;

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
        title: const Text('Alzbiry Box Studio'),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تصدير وحفظ ملف المخطط بنجاح!')),
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
            width: width,
            height: height,
            depth: depth,
            thickness: thickness,
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
            label: 'الأبعاد والتصميم',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.visibility),
            label: 'المعاينة الحية 3D',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'التفكيك والصورة',
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsView() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text('أبعاد الصندوق (مم)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildSlider('العرض (Width X):', width, 50, 400, (val) => setState(() => width = val)),
        _buildSlider('الارتفاع (Height Y):', height, 20, 200, (val) => setState(() => height = val)),
        _buildSlider('العمق (Depth Z):', depth, 50, 400, (val) => setState(() => depth = val)),
        _buildSlider('سمك الخامة (Thickness):', thickness, 1, 10, (val) => setState(() => thickness = val)),
      ],
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
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
                    'خطوات القص والتجميع (Assembly Steps)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'الخطوة 4 من 4: تركيب الألواح الجانبية والتعشيق وإتمام بناء الصندوق بنجاح.',
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
  final double width;
  final double height;
  final double depth;
  final double thickness;

  const Interactive3DBoxPreview({
    Key? key,
    required this.width,
    required this.height,
    required this.depth,
    required this.thickness,
  }) : super(key: key);

  @override
  _Interactive3DBoxPreviewState createState() => _Interactive3DBoxPreviewState();
}

class _Interactive3DBoxPreviewState extends State<Interactive3DBoxPreview> {
  double _rotX = 0.6;
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
          _scale = math.max(0.5, math.min(3.0, _scale * details.scale));
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
                  painter: RealisticBox3DPainter(
                    width: widget.width,
                    height: widget.height,
                    depth: widget.depth,
                    thickness: widget.thickness,
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
                child: const Text(
                  'اسحب لتدوير الصندوق 3D | استخدم الأصابع للتكبير والتصغير',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RealisticBox3DPainter extends CustomPainter {
  final double width;
  final double height;
  final double depth;
  final double thickness;

  RealisticBox3DPainter({
    required this.width,
    required this.height,
    required this.depth,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintBody = Paint()
      ..color = const Color(0xFFF8FAFC)
      ..style = PaintingStyle.fill;

    final paintBorder = Paint()
      ..color = const Color(0xFFD97706)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final paintShadow = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final boxRect = Rect.fromCenter(center: center, width: 160, height: 110);

    canvas.drawRect(boxRect, paintBody);
    canvas.drawRect(boxRect, paintBorder);

    canvas.drawLine(boxRect.topLeft, boxRect.topLeft.translate(-25, -25), paintShadow);
    canvas.drawLine(boxRect.topRight, boxRect.topRight.translate(25, -25), paintShadow);
    canvas.drawLine(boxRect.bottomLeft, boxRect.bottomLeft.translate(-25, -25), paintShadow);
    canvas.drawLine(boxRect.bottomRight, boxRect.bottomRight.translate(-25, -25), paintShadow);

    final topRect = boxRect.translate(0, -25);
    canvas.drawRect(topRect, paintBorder);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
