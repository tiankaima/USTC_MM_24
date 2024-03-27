#set text(font: "Source Han Serif")
#set page(margin: 1.0in)
// #set par(leading: 0.55em, first-line-indent: 1.8em, justify: true)
#show raw: set text(font: "New Computer Modern Mono")
#show par: set block(spacing: 0.55em)
#show heading: set block(above: 1.4em, below: 1em)

#set page(header: context {
  if counter(page).get().first() > 1 [
  #text(size: 10pt)[
    #table(
      columns: (1fr,1fr,1fr),
      align: (left,center,right),
      stroke: none,
      inset: 0.3em,
      [第一次作业], [中国科学技术大学], [Assignment 1],
      [2024 年 3 月 16 日], [数学建模课程], [March 16, 2024]
    )
  ]
  // #line(length: 100%)
]})

#align(center)[
  = Mathematical Modeling \ 图像缩放 第一次作业报告

  #grid(columns: (60pt,60pt,60pt),
    [马天开], [ID: 15], [PB2100030]
  )\2024 年 3 月 16 日
]

== 摘要

本次作业中使用 Python 实现了 Seam Carving 算法，并对算法以及性能做了初步的测试。

== 前言

内容感知的图像缩放是一种在保留图像主要内容的同时，对图像进行缩放的方法。Seam Carving 算法是一种常见的内容感知图像缩放算法，它通过在图像中寻找能量最小的路径，然后删除这些路径上的像素，从而实现图像的缩放。

== 相关工作

Shai Avidan and Ariel Shamir. Seam Carving for Content-Aware Image Resizing. SIGGRAPH2007.

== 问题分析

=== 图像能量的计算

文章中提出了几种计算能量的方法，我们这里选用最基础的：

$
e_1(I) = abs(diff/(diff x)I) + abs(diff/(diff y)I)
$

图像“导数”的定义使用 Sobel filter:

$
p^'_u=mat(1,2,1;0,0,0;-1,-2,-1) * G  space.quad p^'_v=mat(1,0,-1;2,0,-2;1,0,-1) * G
$

能量图：
#image("./figure/image_energy.png", width: 300pt)

=== 能量最小路径的寻找

我们使用动态规划的方法寻找能量最小的路径。设 $M(i,j)$ 为从 $(0,0)$ 到 $(i,j)$ 的最小能量路径的能量值，那么有：

$
M(i,j) = e(i,j) + min(M(i-1,j-1), M(i-1,j), M(i-1,j+1))
$

== 数学模型

在 Python 中使用 `np.array` 来表示图像

== 符号说明

略

== 数学模型建立

略

== 结果（与对比）

输入图像：
#image("./figure/image.jpg", width: 300pt)

#grid(columns:(auto,auto),
  [
  输出图像 ($w = w\/ 2$) ：
  #image("./figure/image_cropped.jpg", width: 140pt)
  ],

  [
  对照（直接缩放）：
  #image("./figure/image_resized.jpg", width: 140pt)
  ]
)

== 结论

从结果上看，Seam Carving 算法在缩放图像时保留了图像的主要内容，而直接缩放则会导致图像内容的变形。

== 问题

Seam Carving 算法的运行时间较长，每移除一px width所需时间在5s左右，尤其在手机等移动设备上，这样的效率显然是无法接受的。

同时，对于部分主体不明显的图像，能量图区分度不高，可能会导致算法无法保留图像的主要内容；处理前后会导致比较明显的变形等等。