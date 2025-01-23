import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

// モックデータモデル
class Building {
  final String name;
  final Offset position; // 建物の位置
  final String description;
  final double r; // 半径
  final double theta; // 角度
  final bool useRightTop; // 右上頂点を使用するかどうか

  Building({
    required this.name,
    required this.position,
    required this.description,
    required this.r,
    required this.theta,
    required this.useRightTop,
  });
}

// 建物データのモック
final mockBuildings = [
  Building(
    name: "Building A",
    position: Offset(350, 200),
    description: "Modern office building.",
    r: 150,
    theta: 135,
    useRightTop: true,
  ),
  Building(
    name: "Building B",
    position: Offset(450, 300),
    description: "Residential apartment.",
    r: 150,
    theta: 45,
    useRightTop: false,
  ),
  Building(
    name: "Building C",
    position: Offset(320, 450),
    description: "Shopping mall.",
    r: 150,
    theta: 225,
    useRightTop: true,
  ),
  Building(
    name: "Building D",
    position: Offset(700, 150),
    description: "Luxury villa.",
    r: 150,
    theta: 45,
    useRightTop: false,
  ),
  Building(
    name: "Building E",
    position: Offset(600, 400),
    description: "Warehouse.",
    r: 150,
    theta: 315,
    useRightTop: false,
  ),
];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: InteractiveMap(),
      ),
    );
  }
}

class InteractiveMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        // 背景地図
        Positioned.fill(
          child: Image.asset(
            'assets/map.png', // 地図画像
            fit: BoxFit.cover,
          ),
        ),
        // 各建物とその情報表示
        for (final building in mockBuildings)
          BuildingWidget(
            building: building,
            screenSize: screenSize,
          ),
      ],
    );
  }
}

class BuildingWidget extends StatelessWidget {
  final Building building;
  final Size screenSize;

  BuildingWidget({
    required this.building,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    // 注釈の幅（定数として設定）
    const double annotationWidth = 200;

    // Flutter座標系に合わせて角度を調整
    final double adjustedTheta = (-building.theta + 360) % 360;

    // 極座標から注釈の中心位置を計算
    final annotationCenterPosition = Offset(
      building.position.dx + building.r * cos(adjustedTheta * pi / 180),
      building.position.dy + building.r * sin(adjustedTheta * pi / 180),
    );

    // 注釈の位置調整（右上または左上を使用）
    final adjustedPosition = Offset(
      building.useRightTop
          ? annotationCenterPosition.dx - annotationWidth // 右上: 左に平行移動
          : annotationCenterPosition.dx, // 左上: そのまま
      annotationCenterPosition.dy,
    );

    // 画面外にならないように調整
    final finalPosition = Offset(
      adjustedPosition.dx.clamp(0, screenSize.width - annotationWidth),
      adjustedPosition.dy.clamp(0, screenSize.height - 100), // 高さを考慮
    );

    // ポインタの終点（注釈の右上または左上頂点）
    final pointerEnd = building.useRightTop
        ? Offset(finalPosition.dx + annotationWidth, finalPosition.dy) // 右上頂点
        : Offset(finalPosition.dx, finalPosition.dy); // 左上頂点

    return Stack(
      children: [
        // 建物の位置を示すアイコン
        Positioned(
          left: building.position.dx - 10,
          top: building.position.dy - 10,
          child: Icon(Icons.location_on, size: 20, color: Colors.red),
        ),
        // 建物情報
        Positioned(
          left: finalPosition.dx,
          top: finalPosition.dy,
          child: Container(
            padding: EdgeInsets.all(8),
            width: annotationWidth,
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  building.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  building.description,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        // ポインタ線
        Positioned.fill(
          child: CustomPaint(
            painter: PointerPainter(start: building.position, end: pointerEnd),
          ),
        ),
      ],
    );
  }
}

// ポインタ線の描画
class PointerPainter extends CustomPainter {
  final Offset start;
  final Offset end;

  PointerPainter({required this.start, required this.end});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
