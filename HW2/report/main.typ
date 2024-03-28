#set text(font: ("New Computer Modern", "Source Han Serif"))
#set page(margin: 1.0in)
#show par: set block(spacing: 1.0em)
#show heading.where(level: 2): it => [
  #set align(center)
  #set text(14pt, weight: "bold")
  #block(it.body, above: 2em, below: 1.0em)
]
#set par(first-line-indent: 2em)
#let indent = h(2em)

#let fake-par = style(styles => {
  let b = par[#box()]
  let t = measure(b + b, styles);

  b
  v(-t.height)
})

#show heading: it => {
  it
  fake-par
}

#set page(header: context {
  if counter(page).get().first() > 1 [
  #text(size: 10pt)[
    #table(
      columns: (1fr,1fr,1fr),
      align: (left,center,right),
      stroke: none,
      inset: 0.3em,
      [第二次作业], [中国科学技术大学], [Assignment 2],
      [2024 年 3 月 28 日], [数学建模课程], [March 28, 2024]
    )
  ]
  // #line(length: 100%)
]})

#align(center)[
  = Mathematical Modeling \ 基于矩阵分解的图像处理 (第二次作业报告)
  2024 年 3 月 28 日
#pad[]
  马天开

  `tiankaima@mail.ustc.edu.cn`

  `ID: 15 / PB2100030`
]

== 摘要 / Introduction

=== 本次作业中使用 Python 实现了:

- 基于矩阵 SVD 分解的图像压缩算法


=== 我们将在本文中讨论如下内容:

- SVD 分解的原理
- 基于矩阵 SVD 分解的图像压缩原理
- 图像压缩的实验结果

== 前言 / Background

Singular Value Decomposition (SVD) 是一种常用的矩阵分解方法，可以将任意矩阵分解为三个矩阵($U, S, V$, 其中 $U, V$ 是正交矩阵，$S$ 是对角矩阵)
的乘积。在图像处理中，我们可以使用 SVD 分解来实现图像压缩和图像修复。

在 Python 中, `numpy` 库提供了 SVD 分解的实现，我们可以直接调用 `numpy.linalg.svd` 函数来进行 SVD 分解。

== 问题分析 / Problem Analysis

实现过程主要包含如下过程:
- 以灰度方式读入图像, 以 2D 矩阵的形式存储
- 对图像矩阵进行 SVD 分解
- 保留部分奇异值, 重构图像矩阵
- 保存压缩后的图像

#pagebreak()

== 数学模型 / Mathematical Model

=== SVD 分解 / Singular Value Decomposition

SVD 分解的目标是得到如下形式:

$
A = U Sigma V^T
$ 其中 $U in F^(m times m), V in F^(n times n)$ 是正交矩阵($U U^T = I, V V^T = I$),
$Sigma in F^(m times n)$ 是主对角矩阵:
$ Sigma_r = "diag"(s_1, s_2, ..., s_r) $
// $ Sigma = display(mat(Sigma_r,0;0,0)) $


#box(fill: blue.lighten(90%), inset: 10pt, width: 100%)[
#indent 历史上研究 SVD 问题主要来自如下双线性形式 (billinear form) 的问题:

$
f(x,y) = x^T A y
$
其中 $f: V times W -> K$, $V, W$是两个向量空间, $K$是数域.

考虑 $V, W$ 中各一组标准正交基 $U, V$(即 $U^T U = I, V^T V = I$), 任意 $x in V, y in W$ 可以表示为
$ x = U xi, quad y = V eta $

#indent 则 $ f(x,y) = xi^T (U^T A V) eta $

如果能找到这样一组 $U, V$, 使得 $U^T A V$ 是对角矩阵, 则 $f(x,y)$ 可以简化为 $xi^T Sigma eta$ 的形式.

上述 $Sigma = U^T A V$ 也即 $A=U Sigma V^T$, 这就是 SVD 的基本思想.
]

SVD 分解定理给出了上述分解的存在性:

#box(stroke: red, inset: 10pt, width: 100%)[
设 $A in RR^(m times n)$, 则存在 $U in RR^(m times m), V in RR^(n times n)$ 是正交矩阵, $Sigma in RR^(m times n)$ 是对角矩阵, 使得:

$
U^T A V = mat(Sigma_r, 0; 0, 0)
$ 其中 $Sigma_r = "diag"(s_1, s_2, ..., s_r)$, $s_1 >= s_2 >= ... >= s_r >= 0$

我们称 $s_1 >= ... >= s_r$ 为 $A$ 的奇异值, $U, V$ 的列向量为 $A$ 的左奇异向量和右奇异向量.

则有 $
A = U Sigma V^T = sum_(i=1)^r s_i u_i v_i^T = s_1 u_1 v_1^T + ... + s_r u_r v_r^T
$
]

=== 图像压缩 / Image Compression

在图像压缩中, 我们可以保留部分奇异值, 从而实现图像的压缩.

设 $A in RR^(m times n)$ 是图像矩阵, $U, Sigma, V$ 是 $A$ 的 SVD 分解, 则可以通过保留部分奇异值来重构图像矩阵:

$
A_k = U Sigma_k V^T = sum_(i=1)^k s_i u_i v_i^T = s_1 u_1 v_1^T + ... + s_k u_k v_k^T
$

其中 $k < r$, $A_k$ 是 $A$ 的一个近似, $k$ 越小, 图像的压缩率越高.

对于彩色图像, 我们可以对每个通道分别进行 SVD 分解, 从而实现彩色图像的压缩.

// == 符号说明

// == 数学模型建立

#pagebreak()

== 结果与对比 / Results and Comparison

#box[
=== 灰度图像压缩 / Grayscale Image Compression
#table(columns: (auto,auto,auto,auto,auto), align: center, [
  #image("./code-py/input.png") Original],[
  #image("./code-py/output/input-80.jpg") $k=80$],[
  #image("./code-py/output/input-160.jpg") $k=160$],[
  #image("./code-py/output/input-320.jpg") $k=320$],[
  #image("./code-py/output/input-640.jpg")  $k=640$
])
]

#box[
=== 彩色图像压缩 / Color Image Compression
#table(columns: (auto,auto,auto,auto,auto), align: center, [
  #image("./code-py/input_color.jpg") Original],[
  #image("./code-py/output/input_color-80.jpg") $k=80$],[
  #image("./code-py/output/input_color-160.jpg") $k=160$],[
  #image("./code-py/output/input_color-320.jpg") $k=320$],[
  #image("./code-py/output/input_color-640.jpg")  $k=640$
])
]

#box[
=== 标准测试图像压缩 / Standard Test Image Compression
#table(columns: (auto,auto,auto,auto), align: center, [
  #image("./code-py/test.png") Original],[
  #image("./code-py/output/test-2.jpg") $k=2$],[
  #image("./code-py/output/test-4.jpg") $k=4$],[
  #image("./code-py/output/test-8.jpg") $k=8$
])
]

#pagebreak()

== 结论 / Conclusion

SVD 图像压缩能实现图像压缩(并保留大部分图像细节), 主要得益于 SVD 分解的奇异值截断性质(如下图所示)，大部分图像信息集中在前几个奇异值上。

#align(center)[
#image("./code-py/output/input-sigma_distribution.png", width: 90%)
]

== 备注 / Remarks

- 安装：
```bash
cd code-py
python3 -m pip install -r requirements.txt
```

- 运行：

  - 灰度：
  ```bash
  python3 main.py --input input.png --output output --k 80
  ```

  - 彩色：
  ```bash
  python3 main.py --input input_color.jpg --output output --k 80 -c
  ```

  - 导出奇异值分布图：
  ```bash
  python3 main.py --input input.png --output output --k 80 -e
  ```

// == 问题
