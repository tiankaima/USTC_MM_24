#set text(
  font: ("linux libertine", "Source Han Serif SC", "Source Han Serif"),
  size: 10pt,
)
#set page(numbering: "1 of 1")

#show math.equation: it => [
  #math.display(it)
]
#show image: it => [
  #set align(center)
  #it
]
#show heading: it => pad(it, y: 0.2em)
#show raw.where(block: true): it => rect(width: 100%, inset: 1em, stroke: 0.02em, it)

#let dcases(..args) = {
  let dargs = args.pos().map(it => math.display(it))
  math.cases(..dargs)
}
#let blue_note(it) = [
  #rect(stroke: blue + 0.02em, width: 100%, inset: 1em)[
    #set text(fill: blue)
    #it
  ]
]

#align(right + horizon)[
  #text(size: 16pt, weight: "bold")[
    数学建模课程大作业 · 数码相机定位
  ]

  PB21000030 马天开

  2024.05.28
]

= 摘要

我们首先解决一个简化的数码相机的标定问题. 我们首先讨论#highlight[相机成像模型], 对给定靶标的像使用 `python` 进行处理, 得到靶标上所有正方形的像坐标, 再利用坐标系之间的转换, 解出相机坐标系 (_camera coordinate system_) 到世界坐标系 (_world coordinate system_) 之间的旋转变换 (_rotation_) $cal(R)$ 和平移变换 (_translation_) $cal(T)$, 据此确定每部相机对世界坐标系的相对位置.

在此基础上我们讨论更一般的#highlight[特征点匹配问题], 并给出实际问题中的解决方案.

#image("imgs/world.png")
#align(center)[
  场景示意图
]

#columns(3)[
  #show: it => align(center, it)
  #image("imgs/camera_1.png")
  Camera 1
  #colbreak()
  #image("imgs/camera_2.png")
  Camera 2
  #colbreak()
  #image("imgs/camera_3.png")
  Camera 3
]

#pagebreak()

= 问题分析

== 模型假设

我们在这个问题中做如下的简化:

- 物点、光心、像点共线, 即我们忽略了透镜的畸变.
- 数码相机光轴垂直于成像平面, 即我们忽略了透镜的倾斜.
- 焦距远小于物体到透镜的距离, 即我们可以近似为小孔成像原理.
- 透镜的焦距 $f$ 已知, 且相机的内部参数已知.

根据物理光学的知识, 我们有:

$
  1 / f = 1 / u + 1 / v
$

其中 $f$ 是焦距, $u$ 为物体到透镜的距离, $v$ 为像到透镜的距离. 考虑到 $u >> f$, 我们有 $v approx f$, 此时透镜成像原理可以近似为小孔成像原理.

对于空间内任何一点 $P$ 在图像上的成像位置可以通过针孔模型得到, 即任何点 $P$ 在像平面上的投影位置 $P'$, 是连接光心 $O$ 到 $P$ 的连线 $O P$ 与像平面的交点 $P'$, 这样的投影方式称为透视投影.

== 符号说明

在下面的讨论中, 我们使用如下的符号系统:

#box(stroke: gray, width: 100%, inset: 1em)[
  #columns(2)[
    *坐标系*
    - 世界坐标系中的点 $(X_w, Y_w, Z_w)^T$

    - 相机坐标系中的点 $(X_c, Y_c, Z_c)^T$
    - 图像坐标系中的点 $(u, v)^T$

    *变换*
    - 世界坐标系到相机坐标系的变换 $cal(P)$

    - 相机坐标系到图像坐标系的变换 $cal(P')$
    - 世界坐标系到图像坐标系的变换 $cal(M) = cal(P') dot.c cal(P)$

    #colbreak()

    *参数*
    - 相机的内部参数 $cal(K)$

    - 相机的外部参数 $cal(R), cal(T)$

    *靶标*
    - 参考点 $i$ 的世界坐标 $(X_w^((i)), Y_w^((i)), Z_w^((i)))^T$

    - 参考点 $i$ 的图像坐标 $(u_i, v_i)^T$
    - 参考图形 $i$ 在像平面上的轮廓 $C_i={P_n}$
    - $C_i$ 中每点 $P_n$ 的图像坐标 $(u_i^((n)), v_i^((n)))^T$
  ]
]

#pagebreak(weak: true)

= 模型设计

== 相机成像模型

在此问题中我们会处理四个坐标系的转换问题, 他们分别是:

#pad(x: 0em)[
  #rect(width: 100%, stroke: 0.02em)[
    #table(
      columns: (1fr, 1fr),
      stroke: none,
      column-gutter: 0em,
      align: horizon,
      [
        - 世界坐标系 (_world coordinate system_): $RR^3$, 我们选取靶标的中心为原点, 在靶标平面上向右为 $x$ 正方向, 向上为 $y$ 正方向, 向外为 $z$ 正方向.
      ],
      [
        - 相机坐标系 (_camera coordinate system_): $RR^3$, 我们选取相机的光心为原点, 相机的光轴为 $z$ 轴, 相机的水平方向为 $x$ 轴, 垂直方向为 $y$ 轴.
      ],
      [
        #image("imgs/world_coord.png", width: 100%)
      ],
      [
        #image("imgs/camera_coord.png", width: 100%)
      ],
      table.hline(stroke: 0.02em),
      [
        - 图像坐标系 (_image coordinate system_): $RR^2$, 我们选取图像的中心为原点, 图像的右侧为 $x$ 轴正方向, 上侧为 $y$ 轴正方向.
      ],
      [
        - 像素坐标系 (_pixel coordinate system_): $RR^2$, 我们选取图像的左上角为原点, 图像的右侧为 $x$ 轴正方向, 下侧为 $y$ 轴正方向. 单位是像素.
      ],
      [
        #image("imgs/image_coord.png", width: 100%)
      ],
      [
        #image("imgs/camera_1.png", width: 100%)
      ],
    )
  ]
]

// 世界坐标系提供了一个与相机无关的坐标系, 在此基础上相机坐标系对其进行了平移和旋转变换, 变成了「相机观察的坐标系」

他们之间的变换方式是:

- 世界坐标系 $=>$ 相机坐标系: 旋转变换 $R$ 和平移变换 $T$, 这是一个 $RR^3$ 中的刚体变换, 即我们只改变坐标系的原点和标架 ${O,arrow(x), arrow(y), arrow(z)}$, 同时变换保持了空间中的距离和角度.
- 相机坐标系 $=>$ 图像坐标系: 投影变换, 这是一个 $RR^3$ 到 $RR^2$ 的变换, 即我们将相机坐标系中的点投影到图像平面上, 由于投影的过程是一个非线性变换, 我们需要使用相机成像模型来描述这个变换.
- 图像坐标系 $=>$ 像素坐标系: 简单的平移变换, 由于我们已经知道了图像的中心, 我们可以通过一个平移变换将图像坐标系转化为像素坐标系. 这一步骤还会将物理尺寸转化为像素尺寸.

我们在下面详细讨论这些变换.

=== 世界坐标系 $=>$ 相机坐标系: 刚体变换

刚体是一种简化的质点模型, 具体地说, 我们忽略刚体内部的形变, 保持所有内部点的长度, 进而也就保持了所有角度. 我们把这样保持长度和角度的变换称为刚体变换.
可以证明, 任何一个刚体变换都可以分解为一个绕原点的旋转变换 (_rotation_) 和一个平移变换 (_translation_). 也就是说, 对于任意一个刚体变换 $cal(P)$, 存在一个旋转变换 $cal(R)$ 和一个平移变换 $cal(T)$ 使得 $ cal(P) = cal(R) space circle.small space cal(T) $

更具体的, 我们可以把一个绕原点的旋转拆分为三个独立的部分, 分别是绕 $x$ 轴的旋转, 绕 $y$ 轴的旋转和绕 $z$ 轴的旋转. 这三个旋转可以用三个旋转矩阵 $cal(R)_x, cal(R)_y, cal(R)_z$ 来表示, 他们的乘积就是总的旋转矩阵 $ cal(R) = cal(R)_x dot.c cal(R)_y dot.c cal(R)_z $

这三个矩阵有如下的形式:

$
  cal(R)_x = mat(
  1, 0, 0;
  0, cos alpha,  -sin alpha;
  0, sin alpha, cos alpha
)
  quad
  cal(R)_y = mat(
  cos beta, 0, sin beta;
  0, 1, 0;
  -sin beta, 0, cos beta
)
  quad
  cal(R)_z = mat(
  cos gamma, -sin gamma, 0;
  sin gamma, cos gamma, 0;
  0, 0, 1
)
$

展开, 得到:

$
  cal(R) = mat(
  cos beta cos gamma, -cos beta sin gamma, sin beta;
  sin alpha sin beta cos gamma + cos alpha sin gamma, -sin alpha sin beta sin gamma + cos alpha cos gamma, -sin alpha cos beta;
  - cos alpha sin beta cos gamma + sin alpha sin gamma, cos alpha sin beta sin gamma + sin alpha cos gamma, cos alpha cos beta
)
$

#rect(width: 100%, inset: 1em, stroke: 0.02em)[
  $cal(R)$ 是一个 $3 times 3$ 的正交矩阵, 即 $cal(R) dot.c cal(R)^T = I$, 同时 $cal(R) = (r_(i j))$ 满足:
  $
    dcases(
    r_(1 1)^2 + r_(1 2)^2 + r_(1 3)^2 = 1,
    r_(2 1)^2 + r_(2 2)^2 + r_(2 3)^2 = 1,
    r_(3 1)^2 + r_(3 2)^2 + r_(3 3)^2 = 1
  )
  $
  这实际上是 $(1,0,0) => (r_(1 1), r_(1 2), r_(1 3))$ 保距离的性质.
]

综上, 从世界坐标系 $(X_w, Y_w, Z_w)^T$ 到相机坐标系 $(X_c, Y_c, Z_c)^T$ 的变换可以用一个旋转矩阵 $cal(R) = (r_(i j))$ 和一个平移向量 $cal(T) = (T_x, T_y, T_z)^T$ 来表示, 即:

$
  vec(X_c, Y_c, Z_c) = mat(r_(1 1), r_(1 2), r_(1 3); r_(2 1), r_(2 2), r_(2 3); r_(3 1), r_(3 2), r_(3 3)) vec(X_w, Y_w, Z_w) + vec(T_x, T_y, T_z)
$

写成矩阵乘法的形式:

$
  vec(X_c, Y_c, Z_c) &= mat(r_(1 1), r_(1 2), r_(1 3), T_x; r_(2 1), r_(2 2), r_(2 3), T_y; r_(3 1), r_(3 2), r_(3 3), T_z) vec(X_w, Y_w, Z_w, 1) quad => quad
  vec(X_c, Y_c, Z_c,1 ) &= [cal(R) mid(|) cal(T)] vec(X_w, Y_w, Z_w, 1)
$

这样, 相机的外部参数 (_extrinsic parameters_) $[cal(R) mid(|) cal(T)]$ 包含了旋转矩阵 $cal(R)$ 和平移向量 $cal(T)$, 对应六个自由度: $(alpha, beta, gamma), (T_x, T_y, T_z)$.

// 即使这里我们确定了三个自由度, 实际依旧以 12 个参数来解线性方程, 而不是 6 个的非线性方程.

=== 相机坐标系 $=>$ 图像坐标系: 相似投影变换

从相机坐标系 $(X_c, Y_c, Z_c)^T$ 到图像坐标系 $(u, v)^T$ 的变换是一个相似投影变换, 即我们将相机坐标系中的点投影到图像平面上, 考虑到像平面到原点的距离是焦距 $f$, 我们可以把问题从 $RR^3->RR^2$ 转化为 $bb(R P)^2$,

$
  k dot vec(X_c, Y_c, Z_c) = vec(u, v, f) quad => dcases(
  u=X_c / Z_c dot f,\
  v=Y_c / Z_c dot f
  )
$

与上文保持类似的记号, 我们得到:

$
  Z_c dot vec(u,v,1)= mat(f,,,0;,f,,0;,,1,0) dot.c vec(X_c,Y_c,Z_c,1)
$

// 注意, 这里焦距 $f$ 已经处理了像素和实际长度的换算, 因此我们不需要再考虑这个问题.
// TODO: really ?

=== 图像坐标系 $=>$ 像素坐标系: 平移变换

从图像坐标系 $(u, v)^T$ 到像素坐标系 $(u', v')^T$ 的变换是一个平移变换, 我们可以通过一个平移向量 $(u_0, v_0)^T$ 来表示, 同时我们将 $u, v$ 除以像素间距 $Delta u, Delta v$ 来得到像素坐标系中的坐标:

$
  dcases(
    u' &= u/(Delta u) + u_0,
    v' &= v/(Delta v) + v_0
  ) quad => quad vec(
    u', v', 1
  ) = mat(
    1\/Delta u, 0, u_0; 0, 1\/Delta v, v_0; 0, 0, 1
  ) dot vec(
    u, v, 1
  )
$

在下面的讨论中, 我们前期将像素坐标系处理回图像坐标系, 并且不再讨论中提及像素坐标系.

=== 小结: 从 $(X_w, Y_w, Z_w)^T$ 到 $(u,v)^T$

用矩阵的记号整理上面的讨论, 我们得到:

$
  Z_c vec(u,v,1) &= mat(f,,,0;,f,,0;,,1,0) mat(cal(R),cal(T);0,1) vec(X_w,Y_w,Z_w,1) = mat(f  r_11, f  r_12, f  r_13, f  T_x; f  r_21, f  r_22, f  r_23, f  T_y; r_31, r_32, r_33, T_z) vec(X_w,Y_w,Z_w,1)\
$
$
  dcases(
    Z_c u &= f r_11 X_w + f r_12 Y_w + f r_13 Z_w + f T_x,
    Z_c v &= f r_21 X_w + f r_22 Y_w + f r_23 Z_w + f T_y,
    Z_c &= r_31 X_w + r_32 Y_w + r_33 Z_w + T_z
  )
$

$
  dcases(
    u &= (f r_11 X_w + f r_12 Y_w + f r_13 Z_w + f T_x) / (r_31 X_w + r_32 Y_w + r_33 Z_w + T_z),
    v &= (f r_21 X_w + f r_22 Y_w + f r_23 Z_w + f T_y) / (r_31 X_w + r_32 Y_w + r_33 Z_w + T_z)
  )
$

从以上过程, 我们完整得到了从 $(X_w, Y_w, Z_w)$ 到 $(u,v)$ 的映射关系, 此即#highlight[相机成像模型].

#pagebreak(weak: true)

== 特征点提取: 棋盘标定板

接下来面临的任务是从图像中提取特征点, 我们从简化模型的棋盘标定板开始:

首先我们对输入图像二值化:

#image("imgs/chessboard_bw.png", width: 50%)

接下来调用 `scikit` 中 `KMeans` 算法对图像进行#highlight[聚类], 得到每个聚类的中心:

```py
black_img_points = np.argwhere(black_img == 255)
kmenas = KMeans(n_clusters=8, random_state=0).fit(black_img_points)
centers = kmenas.cluster_centers_
```

我们把分类结果标注在图上:
#image("imgs/chessboard_clustered.png", width: 50%)

通过这样的方式, 我们可以得到棋盘标定板上每个黑色正方形的中心, 这些中心点就是我们的特征点.

#rect(width: 100%, inset: 1em, stroke: 0.02em)[
  棋盘检测有更为专用的办法, 对于一般的图像, 我们可以使用 `Harris` 角点检测算法, 通过计算图像的梯度来找到角点:

  ```py
  corners = cv2.goodFeaturesToTrack(gray, 100, 0.01, 10)
  ```
]

#rect(width: 100%, inset: 1em, stroke: 0.02em)[
  K-means 算法的过程大致如下:

  - 选取 $k$ 个 样本作为初始的聚类中心.
  - 对于每个样本 $x_i$, 计算其到每个聚类中心的距离, 将其归为距离最近的聚类中心.
  - 重新计算每个聚类中心, 使其为该类所有样本的平均值.
  - 重复上面两步, 直到收敛.

  一般来说, 通过 K-means 算法我们可以得到比较好的聚类效果, 而且容易转换到其他标定板上 (例如圆形标定板), 但精度不如专用的算法, 棋盘检测中为提高精度, 有专门的次像素级别的算法.
]

== 特征点匹配

通过上面的处理, 我们成功地得到了 $(u^((i)),v^((i)))$, 棋盘的世界坐标是已知的 $(X_w^((i)), Y_w^((i)), Z_w^((i)))$

我们重新整理相机成像模型中得到的方程:

$
  f X_w r_11 + f Y_w r_12 + f Z_w r_13 + f T_x - u X_w r_31 - u Y_w r_32 - u Z_w r_33 - u T_z = 0\
  f X_w r_21 + f Y_w r_22 + f Z_w r_23 + f T_y - v X_w r_31 - v Y_w r_32 - v Z_w r_33 - v T_z = 0\
$

我们接下来尝试从这些方程中解出相机的外部参数 $cal(R), cal(T)$.

#rect(width: 100%, inset: 1em, stroke: 0.02em)[
  我们自然地想到把上面的问题按照齐次线性方程来求解, 但这样的思路是不可行的, 原因在于:

  注意到一般的, 超定齐次方程通过 SVD 分解计算的主要思路是:

  考虑 $A x = 0$, 可以通过 SVD 分解 $A = U S V^T$ 来求解 $x$, 取 $x = V_(-1)^T$, 其中 $V_(-1)$ 是 $V$ 的最后一列.

  这样得到的 $x = "argmin"_x norm(A x)$. 但是我们这里需要 $r_(1 1)^2 + r_(1 2)^2 + r_(1 3)^2 = 1, dots.c$, 这是一个非线性约束, 不能通过 SVD 分解来求解, 通过将 SVD 分解的结果正交化也不能同时满足这样的条件.
]

我们这里将 $(alpha, beta, gamma)$ 代入 $(r_(i j))$, 对于每个 $(X_w^((i)), Y_w^((i)), Z_w^((i)))^T$ 我们可以得到两个方程:

$
  // T_x f + X_w^((i)) f cos beta cos gamma - Y_w^((i)) f sin gamma cos beta + Z_w^((i)) f sin beta\ - u (
  //   T_z + X_w^((i)) (sin alpha sin gamma - sin beta cos alpha cos gamma) + Y_w^((i)) (
  //     sin alpha cos gamma + sin beta sin gamma cos alpha
  //   ) + Z_w^((i)) cos alpha cos beta
  // ) = 0\
  // T_y f + X_w^((i)) f (sin alpha sin beta cos gamma + sin gamma cos alpha) + Y_w^((i)) f (
  //   - sin alpha sin beta sin gamma + cos alpha cos gamma
  // ) - Z_w^((i)) f sin alpha cos beta\ - v (
  //   T_z + X_w^((i)) (sin alpha sin gamma - sin beta cos alpha cos gamma) + Y_w^((i)) (
  //     sin alpha cos gamma + sin beta sin gamma cos alpha
  //   ) + Z_w^((i)) cos alpha cos beta
  // ) = 0
  dcases(
    T_x f + X_w^((i)) f cos beta cos gamma - Y_w^((i)) f sin gamma cos beta + Z_w^((i)) f sin beta ... &= 0,
    T_y f + X_w^((i)) f (sin alpha sin beta cos gamma + sin gamma cos alpha) + Y_w^((i)) f (- sin alpha sin beta sin gamma + cos alpha cos gamma ) ... &= 0
  )
$

即:

$
  dcases(
    f_u^((i))(alpha, beta, gamma, T_x, T_y, T_z) &= 0,
    f_v^((i))(alpha, beta, gamma, T_x, T_y, T_z) &= 0
  )
$

对多组 $X_w^((i)), Y_w^((i)), Z_w^((i)), u^((i)), v^((i))$ 我们可以得到多组 $(alpha, beta, gamma), (T_x, T_y, T_z)$, 我们可以得到多组 $f_u^((i)), f_v^((i))$, 我们可以通过牛顿法求解这个非线性方程组.

```py
scipy.optimize.fsolve(calc, [0, 0, 0, 0, 0, 0])
```

可以利用 Sympy 符号计算上面方程的 Jacobi 来提高计算精度:

```py
R = Ralpha * Rbeta * Rgamma
T = sym.Matrix([[Tx], [Ty], [Tz]])
K = sym.Matrix([[f, 0, 0], [0, f, 0], [0, 0, 1]])
P = K * sym.Matrix.hstack(R, T)
_eq = P * sym.Matrix([[Xw], [Yw], [Zw], [1]])
eq_u = _eq[0] - u * _eq[2]
eq_v = _eq[1] - v * _eq[2]
eq = sym.Matrix([eq_u, eq_v])
eq_jacobi = eq.jacobian([alpha, beta, gamma, Tx, Ty, Tz])
display(eq_jacobi)
```

到这里我们可以得到相机的外部参数 $cal(R), cal(T)$, 进而确定相机的位置.

```txt
[-4.04494258e+01  7.29146548e+00  1.02827280e-01  2.65111431e-01 2.12692992e-02  4.71411004e+00]
```

#pagebreak(weak: true)

= 讨论及优缺点

我们在上面的讨论中忽略了以下问题, 这些问题在实际中是非常重要的:

- 通过聚类算法得到的中心点的顺序是不确定的, 我们需要通过额外的方法来确定特征点的顺序, 即他们跟世界坐标系中的点的对应关系.
- 对于更一般的图像, 例如无标定板的图像, 我们需要使用更为复杂的特征点匹配算法, 例如 `SIFT`, `SURF`, `ORB` 等.
- 我们在建模中忽略了相机的畸变, 这在实际中是一个非常重要的问题, 一般的, 我们需要使用 `OpenCV` 中的 `calibrateCamera` 函数来进行标定.
- 我们没有讨论最终 `fsolve` 对精度的敏感问题, 实验中我们可以发现, 结果对于初值的敏感度是非常高的, 这是一个非常重要的问题.

另外需要指出的一点是, 我们上面的梯度下降的求解思路并不严格, 准确来说, 我们应该解决下面的最优化问题:

$
  E(alpha, beta, gamma, dots.c) = sum_(i=1)^n norm(hat(x)-x)^2\
  alpha, beta, gamma, dots.c = "argmin" E(alpha, beta, gamma, dots.c)
$

= SFMedu

SFMedu: Structure From Motion for Education 是一个专门用于教育的三维重建工具, 其提供了一个完整的三维重建流程, 包括特征点提取, 特征点匹配, 相机标定等.

SFMedu 的基本流程是:

- 使用 SIFT 算法提取特征点.
- 对于每一对图像, 使用 RANSAC 算法估计基础矩阵, 并移除不符合基础矩阵的特征点.
- 使用三角化算法估计三维点.

我们在这里重复 SFMedu 提供的 demo, 一窥完整的三维重建流程. 运行 Matlab, 将渲染出的 `.ply` 文件导入 Blender 中, 我们得到:

#table(
  columns: (1fr, 1fr, 1fr),
  stroke: 0.02em,
  align: horizon,
  [
    #image("imgs/ply_export_1.png", width: 100%)
  ],
  [
    #image("imgs/ply_export_2.png", width: 100%)
  ],
  [
    #image("imgs/ply_export_3.png", width: 100%)
  ],
)

= 结论

在这个问题中, 我们讨论了数码相机的标定问题, 并给出了一个简化的解决方案. 我们首先讨论了相机成像模型, 并通过 `python` 代码实现了这个模型. 我们接着讨论了特征点匹配问题, 并给出了实际问题中的解决方案.
在这个过程中, 我们发现了一些问题, 例如特征点的顺序问题, 畸变问题, 初值敏感度问题等, 这些问题在实际中是非常重要的.

最后我们重复了 SFMedu 的 demo, 一窥完整的三维重建流程, 并在 Blender 中渲染出了三维模型.

