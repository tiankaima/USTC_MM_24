#set text(font: ("New Computer Modern", "Source Han Serif", "Source Han Serif SC"))
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
  let t = measure(b + b, styles)

  b
  v(-t.height)
})

#show heading: it => {
  it
  fake-par
}

#set page(header: context {
  if counter(page).get().first() > 1 [
    #set text(weight: "medium")
    #text(size: 10pt)[
      #table(
        columns: (1fr, 1fr, 1fr),
        align: (left, center, right),
        stroke: none,
        inset: 0.3em,
        [第三次作业],
        [中国科学技术大学],
        [Assignment 3],
        [2024 年 4 月 21 日],
        [数学建模课程],
        [April 21, 2024],
      )
    ]
    #v(-1em)
    #line(length: 100%)
  ]
})

#align(center)[
  = Mathematical Modeling \ 使用神经网络进行昆虫分类 (第三次作业报告)
  2024 年 4 月 21 日
  #pad[]
  马天开

  `tiankaima@mail.ustc.edu.cn`

  `ID: 15 / PB2100030`
]

== 摘要 / Introduction

=== 本次作业中使用 Python 实现了:

- 一个简单的神经网络模型，用于识别昆虫的种类
  - 使用 Tensorflow 的 Keras API 构建神经网络模型
- 数据集的导入、模型的保存与加载、模型的训练与测试等功能
- 数据可视化、训练过程可视化等功能

// === 我们将在本文中讨论如下内容:

// #pagebreak()

== 前言 / Background

Tensorflow 是一个由 Google 开发的开源机器学习框架，它提供了一系列用于构建、训练和部署机器学习模型的工具。Tensorflow 的 Keras API 提供了一种高级的神经网络构建接口，使得用户可以更加方便地构建神经网络模型。

在本次作业中，我们将使用 Tensorflow 的 Keras API 构建一个简单的神经网络模型，用于识别昆虫的种类。我们将使用一个包含 3 个类别的昆虫数据集，通过不同的属性(体长、翼长)来训练一个简单的分类模型。

== 问题分析 / Problem Analysis

- 导入数据集:

  使用 `numpy.loadtxt` 直接导入为 `np.array` 类型的数据

- `tf.model` 的设置:

  ```Python
  model = tf.keras.models.Sequential([
      tf.keras.layers.Dense(200, activation='relu'),
      tf.keras.layers.Dropout(0.2),
      tf.keras.layers.Dense(3)
  ])
  ```

#pagebreak()

// == 数学模型 / Mathematical Model

// == 符号说明

// == 数学模型建立

// #pagebreak()

== 结果与对比 / Results and Comparison

=== 数据可视化 / Data Visualization

#table(
  columns: (auto, auto),
  stroke: white,
  [
    - 无误差数据:
    #image("imgs/output.png")
  ],
  [
    - 有误差数据:
    #image("imgs/output-2.png")
  ],
)

#v(3em)

=== 训练过程可视化 / Training Process Visualization

#box[
  - 无误差数据: (\~1000 epoch)

  #image("imgs/output-3.png")

  可以看到模型稳定地收敛到了一个较好的结果. 最终效果

  `- accuracy: 0.9629 - loss: 0.1135 - val_accuracy: 0.9714 - val_loss: 0.1166`
]

#v(3em)

#box[
  - 有误差数据: (\~1000 epoch)

  #image("imgs/output-4.png")

  模型在 50 epoch 后 loss 不再下降, 而是在 0.25 左右波动. 最终效果

  `- accuracy: 0.8999 - loss: 0.2132 - val_accuracy: 0.9429 - val_loss: 0.1436`
]

#v(3em)

=== 不同模型对比 / Comparison of Different Models

#box[
  - 移除 Dropout 层后的模型效果(无误差数据):

  #image("imgs/output-5.png")

  `- accuracy: 0.9667 - loss: 0.1057 - val_accuracy: 0.9714 - val_loss: 0.1129`
]

#v(3em)

#box[
  - 激活函数使用 `softmax` 的模型效果(无误差数据):

  #image("imgs/output-6.png")

  训练过程更加平滑, 但是结果略差于 `relu` 激活函数

  `- accuracy: 0.9194 - loss: 0.1999 - val_accuracy: 0.8857 - val_loss: 0.2377`
]

#v(3em)

#box[
  - 激活函数使用 `sigmoid` 的模型效果(无误差数据):

  #image("imgs/output-7.png")

  `- accuracy: 0.8687 - loss: 0.3126 - val_accuracy: 0.8619 - val_loss: 0.2717`
]

#pagebreak()

== 结论 / Conclusion

- 本次作业中, 我们使用 Tensorflow 的 Keras API 构建了一个简单的神经网络模型, 用于识别昆虫的种类

- 我们通过不同的实验, 对比了不同模型的效果, 并且讨论了一些可能的改进方案

- 通过本次作业, 我们对神经网络的构建、训练和测试有了更深入的了解

== 备注 / Remarks

- 安装：
  ```bash
  pip install numpy matplotlib tensorflow
  ```

// == 问题
