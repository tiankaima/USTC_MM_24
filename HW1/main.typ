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
  = Mathematical Modeling \ 图形缩放 第一次作业报告

  #grid(columns: (60pt,60pt,60pt),
    [马天开], [ID: 15], [PB2100030]
  )\2024 年 3 月 16 日
]

== 摘要

本次作业中使用 Python 实现了 Seam Carving 算法，并对算法以及性能做了初步的测试。

== 前言


