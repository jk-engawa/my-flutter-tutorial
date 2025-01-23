import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

// 注釈モデル
class Annotation {
  Offset point; // 矢印の起点
  Offset annotationOffset; // 注釈本体の位置
  String text;
  bool isEditable; // 編集可能モードか
  String id;

  Annotation({
    required this.point,
    required this.annotationOffset,
    required this.text,
    this.isEditable = true,
    required this.id,
  });
}

// 状態管理
final annotationProvider =
    StateNotifierProvider<AnnotationNotifier, List<Annotation>>((ref) {
  return AnnotationNotifier();
});

class AnnotationNotifier extends StateNotifier<List<Annotation>> {
  AnnotationNotifier() : super([]);

  void addAnnotation(Offset point, double screenWidth) {
    state = [
      ...state,
      Annotation(
        point: point,
        annotationOffset: point.translate(50, -50),
        text: "",
        id: UniqueKey().toString(),
      ),
    ];
  }

  void updateAnnotation({
    required String id,
    Offset? newOffset,
    String? newText,
  }) {
    state = [
      for (final annotation in state)
        if (annotation.id == id)
          Annotation(
            point: annotation.point,
            annotationOffset: newOffset ?? annotation.annotationOffset,
            text: newText ?? annotation.text,
            isEditable: annotation.isEditable,
            id: annotation.id,
          )
        else
          annotation
    ];
  }

  void toggleEditable(String id) {
    state = [
      for (final annotation in state)
        if (annotation.id == id)
          Annotation(
            point: annotation.point,
            annotationOffset: annotation.annotationOffset,
            text: annotation.text,
            isEditable: !annotation.isEditable,
            id: annotation.id,
          )
        else
          annotation
    ];
  }

  void removeAnnotation(String id) {
    state = state.where((annotation) => annotation.id != id).toList();
  }
}

// アプリ本体
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

// インタラクティブなマップ
class InteractiveMap extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final annotations = ref.watch(annotationProvider);

    return GestureDetector(
      onTapDown: (details) {
        // クリック位置が既存の注釈の範囲内であるかを判定
        final isInsideAnnotation = annotations.any((annotation) {
          final annotationRect = Rect.fromLTWH(
            annotation.annotationOffset.dx,
            annotation.annotationOffset.dy,
            200, // 注釈の幅（柔軟に変更可能）
            50, // 注釈の高さ（柔軟に変更可能）
          );
          return annotationRect.contains(details.localPosition);
        });

        // 範囲内でなければ新しい注釈を作成
        if (!isInsideAnnotation) {
          ref.read(annotationProvider.notifier).addAnnotation(
                details.localPosition,
                MediaQuery.of(context).size.width,
              );
        }
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.white,
              child: Image.asset(
                'assets/map.png', // 背景地図画像
                fit: BoxFit.cover,
              ),
            ),
          ),
          for (final annotation in annotations)
            CustomAnnotationWidget(annotation: annotation),
        ],
      ),
    );
  }
}

// カスタム注釈ウィジェット
class CustomAnnotationWidget extends ConsumerWidget {
  final Annotation annotation;

  CustomAnnotationWidget({required this.annotation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        // 矢印線
        Positioned.fill(
          child: CustomPaint(
            painter: ArrowPainter(
              start: annotation.point,
              end: annotation.annotationOffset,
              annotationSize: const Size(200, 50), // 注釈のサイズ（任意に変更可能）
            ),
          ),
        ),
        // 注釈本体
        Positioned(
          left: annotation.annotationOffset.dx,
          top: annotation.annotationOffset.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              // ドラッグで注釈を移動
              ref.read(annotationProvider.notifier).updateAnnotation(
                    id: annotation.id,
                    newOffset: annotation.annotationOffset + details.delta,
                  );
            },
            child: Container(
              padding: EdgeInsets.all(8),
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
              constraints: BoxConstraints(
                minWidth: 50,
                maxWidth: 200,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // 常に左揃え
                children: [
                  // 操作ボタン（鉛筆・削除）
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          annotation.isEditable ? Icons.check : Icons.edit,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          ref
                              .read(annotationProvider.notifier)
                              .toggleEditable(annotation.id);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          ref
                              .read(annotationProvider.notifier)
                              .removeAnnotation(annotation.id);
                        },
                      ),
                    ],
                  ),
                  // テキスト表示
                  annotation.isEditable
                      ? TextField(
                          controller:
                              TextEditingController(text: annotation.text),
                          maxLines: null, // 自動改行
                          textAlign: TextAlign.start, // 左揃え
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            ref
                                .read(annotationProvider.notifier)
                                .updateAnnotation(
                                  id: annotation.id,
                                  newText: value,
                                );
                          },
                        )
                      : Text(
                          annotation.text,
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.start, // 左揃え
                        ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// 矢印線の描画
class ArrowPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Size annotationSize;

  ArrowPainter({
    required this.start,
    required this.end,
    required this.annotationSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    // 極座標で角度を計算
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final angle = atan2(dy, dx) * 180 / pi;

    // 注釈の頂点を決定
    final isRightTop = angle > 90 && angle < 270;
    final annotationVertex = isRightTop
        ? Offset(end.dx + annotationSize.width, end.dy)
        : Offset(end.dx, end.dy);

    // ポインタを描画
    canvas.drawLine(start, annotationVertex, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
