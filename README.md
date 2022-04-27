### 前沿

最近有看到不少贝塞尔曲线相关的文章，勾发了我对Flutter贝塞尔曲线探究的兴趣，这里通过Flutter对贝塞尔曲线做几个有趣的探索，希望对大家有所帮助。

[贝塞尔曲线](https://baike.baidu.com/item/%E8%B4%9D%E5%A1%9E%E5%B0%94%E6%9B%B2%E7%BA%BF/1091769)是一个大家比较熟悉的绘制曲线了，这里就不过多介绍。如果有不清楚原理的同学，可以点击[这里](https://juejin.cn/post/7082701281969569829)了解。

### 探索

#### 一、贝塞尔曲线实现自定义图案

1. 通过贝塞尔曲线[可视化工具](https://www.tweenmax.com.cn/tool/bezier/)预先绘制图案，这里以绘制爱心为例，我们先绘制如下形状：

![爱心绘制](https://gitee.com/fitem/photo/raw/master/photo/WX20220412-095501.png)

2. Flutter中绘制。Flutter的Path封装了贝塞尔曲线的对应api，我们只需要将上述工具绘制的坐标点传入。注意当我们绘制完左半爱心后，右半爱心只需要根据中心点坐标对称绘制即可。

~~~
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
~~~

效果图如下：

![效果图1](https://gitee.com/fitem/photo/raw/master/photo/Screenshot_20220427_180851.png)

ok，我们完成了一个通过贝塞尔曲线绘制自定义图形的探索，是不是感觉非常简单！

#### 二、绘制的曲线添加绘制动画

如果仅仅实现上面的实例，那太简单了，我们做一点更有难度的探索。比如说在绘制的过程中添加动画，让绘制过程动起来。
刚开始有这个想法的时候，大脑毫无头绪。因为我们的图形是通过贝塞尔曲线画出来的，我们没有掌握到path轨迹绘制的细节，也就无法通过动画来增量更新path的绘制...

那我们有没有办法获取到Path的细节呢，结论是有的。经过一系列对Flutter的Api探索（其实是百度、Google）后，Path.computeMetrics()给了我答案。我们可以通过PathMetric获取到Path的测量位置，然后遍历获取到Path的所有Point，然后通过drawPoints()按照时间维度进行绘制，最后实现我们想要的绘制动画效果。

好了，废话不多说直接上代码：

~~~~
 // 获取path上的点数据
    // 左边
    PathMetrics leftPms = leftPath.computeMetrics();
    PathMetric leftPm = leftPms.elementAt(0);
    double leftLen = leftPm.length;

    double tmpStart = 0;
    double leftEnd = min(_fraction, leftLen);
    var isCompleted = leftEnd == leftLen;
    
    for (; tmpStart < leftEnd; tmpStart += 1) {
      Tangent? t = leftPm.getTangentForOffset(tmpStart);
      if (t != null) {
        _leftPoints.add(t.position);
      }
    }
    // 右边
    PathMetrics rightPms = rightPath.computeMetrics();
    PathMetric rightPm = rightPms.elementAt(0);
    double rightLen = rightPm.length;
    tmpStart = 0;
    double rightEnd = min(_fraction, rightLen);
    for (; tmpStart < rightEnd; tmpStart += 1) {
      Tangent? t = rightPm.getTangentForOffset(tmpStart);
      if (t != null) {
        _rightPoints.add(t.position);
      }
    }

    // 绘制背景线
    canvas.drawPath(leftPath, _paint1);
    canvas.drawPath(rightPath, _paint1);
    // 绘制点
    canvas.drawPoints(PointMode.points, _leftPoints, _paint2);
    canvas.drawPoints(PointMode.points, _rightPoints, _paint2);
~~~~

然后通过动画增量更新Points的绘制进度
~~~
    _animation = Tween(begin: 0.0, end: len).animate(_controller)
      ..addListener(() {
        setState(() {
          _fraction = _animation.value;
        });
      });
~~~

当动画执行完成的时候，我们把爱心填充，这样更加突出
~~~
    // 绘制爱心
    // 动画结束时，填充爱心
    if (isCompleted) {
      _paint1.style = PaintingStyle.fill;
      _paint1.color = red;
    }
~~~

最后不要忘记了将CustomPainter的shouldRepaint设置为true，允许widget触发build的时候重新绘制
~~~
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
~~~

现在我们来看看最终实现的效果吧：

![效果图2](https://gitee.com/fitem/photo/raw/master/photo/bloggif_62692cda0d4e2.gif)

目前，我们尝试了：(1)通过贝塞尔曲线绘制自定义图形；(2)为绘制的曲线添加绘制动画；2种曲线绘制的探究，后续在《Flutter贝塞尔曲线的有趣探索(下)》文章中将尝试以下探索：(3)通过手势绘制自定义图形；(4)将绘制的图形生成个人作品并添加自定义特效；欢迎大家点赞收藏持续关注我，最后贴上项目源码的[Github](https://github.com/Fitem/draw_demo)。

   