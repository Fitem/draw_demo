import 'package:flutter/material.dart';

///  Name: 探索一：贝塞尔曲线实现自定义图案
///  Created by fitem on 2022/4/27
class ExploreOneScreen extends StatefulWidget {
  const ExploreOneScreen({Key? key}) : super(key: key);

  @override
  _ExploreOneScreenState createState() => _ExploreOneScreenState();
}

class _ExploreOneScreenState extends State<ExploreOneScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 500,
          child: CustomPaint(
            painter: BezierPainter(),
          ),
        ),
      ],
    );
  }
}

class BezierPainter extends CustomPainter {
  Path leftPath = Path();
  Path rightPath = Path();
  static const blue = Color(0xFF156FEC);
  final _paint1 = Paint()
    ..color = blue
    ..strokeWidth = 2.0
    ..style = PaintingStyle.stroke;
  double centerX = 0;

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制背景
    canvas.drawColor(const Color(0xFFF1F1F1), BlendMode.color);
    // 获取屏幕中心点坐标
    centerX = size.width * 0.5;
    // 左半爱心
    leftPath.moveTo(centerX, 400);
    leftPath.cubicTo(centerX - 207, 267, centerX - 107, 100, centerX, 194);
    // 右半爱心
    rightPath.moveTo(centerX, 400);
    rightPath.cubicTo(centerX + 207, 267, centerX + 107, 100, centerX, 194);
    // 绘制曲线
    canvas.drawPath(leftPath, _paint1);
    canvas.drawPath(rightPath, _paint1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
