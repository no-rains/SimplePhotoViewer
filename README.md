# SimplePhotoViewer

在这里我们来看一下如何通过SwiftUI完成一个简单的图片显示。这里的图片显示，重点不在于如何搜索图片、显示缩略图之类，而是在于显示图片的时候，如何实现缩放以及拖动功能。

## 显示图片

如果要显示图片，在SwiftUI里实在是太简单了，直接使用Image即可：

```swift
struct ContentView: View {
    var body: some View {
        return ZStack(alignment: .topLeading) {
            Image(uiimage: UIImage(named: "photo")!)
        }
    }
}
```

是不是非常简单？感觉没有任何技术性含量。但如果我们需要在此基础上实现缩放以及拖动功能，那么还是要花费一定的功夫的。

## 手势基础

对图片的操作，自然离不开手势，所以我们这里就需要看一下相关的手势操作。

### MagnificationGesture

MagnificationGesture主要是用来处理缩放的，其形式大致如下：

```swift
let rotateAndZoom = MagnificationGesture()
            .onChanged { scale in
                //一直缩放的时候，就会执行这里
            }
            .onEnded { scale in
            		//放手的时候，就会执行这里
            }
```

对于MagnificationGesture而言，我们需要关心的是onChanged和onEnded这两个闭包：

- onChanged：当我们两个手指不停地进行合拢和放开的时候，就是不停地执行这里
- onEnded：最后放手的时候，就执行这里

无论哪个闭包，参数都是只有一个，那就是缩放比例scale。需要留意的是，scale的数值指的是相对于上一次调用onChanged的大小。这样说可能比较抽象，我们不妨以数据来看一下。

假设我们最一开始的图片大小的数值是10，那么先来看第一次手势：

|    动作    | scale数值 | 实际大小（原始大小为10） |
| :--------: | :-------: | :----------------------: |
| .onChanged |    1.2    |         12.00000         |
| .onChanged |    1.1    |         13.20000         |
|  .onEnded  |    1.3    |         17.16000         |

承接第一次手势，第二次手势的数值则是：

|    动作    | scale数值 | 实际大小（原始大小为10） |
| :--------: | :-------: | :----------------------: |
| .onChanged |    1.2    |         20.59200         |
| .onChanged |    0.8    |         16.47360         |
|  .onEnded  |    1.3    |         21.41568         |

也就是说，如果我们需要使用一个属性来存储每次缩放手势之后的比例，那么我们代码需要这么写：

```swift
//原始的比例设置为1
@State private var scaleRatio: CGFloat = 1 

@State private var lastScale: CGFloat?
...
 let rotateAndZoom = MagnificationGesture()
            .onChanged { scale in

                if let lastScale = self.lastScale {
                    // The zoom gesture is base on the center, so is a half
                    let ratio = 1.0 + (scale - lastScale)
                    self.scaleRatio *= ratio
                }

                self.lastScale = scale
            }
            .onEnded { scale in

                if let lastScale = self.lastScale {
                    let ratio = 1.0 + (scale - lastScale)
                    self.scaleRatio *= ratio
                }

                self.lastScale = nil
            }
```

属性scaleRatio便是存储了缩放手势中的所有的数值。

### DragGesture

DragGesture是用于处理滑动的，和MagnificationGesture一样，也是有onChanged和onEnded这两个闭包：

```swift
let dragOrDismiss = DragGesture()
            .onChanged { value in
                //一直滑动的时候，就会执行这里
            }
            .onEnded { value in
            		//放手的时候，就会执行这里
            }
```

对于拖动的手势，我们一般使用的是value.translation数值，它其实是结束位置减去起始位置的数值，也就是整个滑动过程中的偏移数值。

这里需要注意两点：

- 和MagnificationGesture一样，数值也是基于上一次的数值
- 实际的滑动距离，还需要乘上缩放的比例

我们不妨来看一下例子，这是第一次滑动的时候的情况：

|    动作    | value.translation.width数值 | x的位置（假设缩放比例为1） | x的位置（假设缩放比例为2） |
| :--------: | :-------------------------: | :------------------------: | -------------------------- |
| .onChanged |             10              |             10             | 20                         |
| .onChanged |              8              |             18             | 36                         |
|  .onEnded  |             20              |             38             | 76                         |

第二次滑动手势调用之后，情况如下：

|    动作    | value.translation.width数值 | x的位置（假设缩放比例为1） | x的位置（假设缩放比例为2） |
| :--------: | :-------------------------: | :------------------------: | -------------------------- |
| .onChanged |             10              |             48             | 96                         |
| .onChanged |              8              |             56             | 112                        |
|  .onEnded  |             20              |             76             | 156                        |

鉴于此，所以不难得出如下的计算偏移度的代码：

```swift
@State private var actualScale: CGFloat = 1.0
@State private var lastTranslation: CGSize?
...
let dragOrDismiss = DragGesture()
            .onChanged { value in

                if let lastTranslation = self.lastTranslation {
                    self.actualOffset.x += (value.translation.width - lastTranslation.width) * self.scaleRatio
                    self.actualOffset.y += (value.translation.height - lastTranslation.height) * self.scaleRatio
                }

                self.lastTranslation = value.translation
            }
            .onEnded { value in

                if let lastTranslation = self.lastTranslation {
                    self.actualOffset.x += (value.translation.width - lastTranslation.width) * self.scaleRatio
                    self.actualOffset.y += (value.translation.height - lastTranslation.height) * self.scaleRatio
                }

                self.fixOffset()

                self.lastTranslation = nil
            }
```

### TapGesture

TapGesture主要是用来处理单击或双击事件的，这手势就比较简单。假如我们需要双击的时候，恢复为图片原始大小，那么代码可以如下：

```swift
let fitToFill = TapGesture(count: 2)
            .onEnded {
                if self.scaleRatio > 1 {
                    self.scaleRatio = 1
                } 
            }
```

相对于前面的两种手势，双击是不是显得简单多了？

### 添加手势

手势的对象有了，那么该如何将手势加到Image去呢？一个简单的步骤如下：

- 通过exclusively将DragGesture和MagnificationGesture关联到TapGesture上
- Image通过gesture将TapGesture手势绑定过来

也就是说，简单的示例如下所示：

```swift
        let fitToFill = TapGesture(count: 2)
            .onEnded {
                if self.scaleRatio > 1 {
                    self.scaleRatio = 1
                } 
            }
            .exclusively(before: dragOrDismiss)
            .exclusively(before: rotateAndZoom)
            
        Image(uiImage: image)
            .renderingMode(.original)
            .gesture(fitToFill)
```

这里还存在一个问题，就是MagnificationGesture和DragGesture数值改如何在Image上体现呢？其实靠的就是scaleEffect和offset函数：

```swift
return Image(uiImage: image)
            .renderingMode(.original)
            .gesture(fitToFill)
            .scaleEffect(scaleRatio, anchor: .center)
            .offset(x: actualOffset.x, y: actualOffset.y)
```

## 改进手势

这里所谓的改进，指的是添加一些限制条件，让图片显示更符合平时的用法，比如缩放到最大的时候，只能是图片原始大小等等。

### 等比缩放

我们这里只考虑一个情况，就是图片是等比显示的。如果要实现这样的状况，我们需要进行如下几步：

- 知道当前View的显示区域大小
- 根据显示区域大小确定缩放比率

如果需要知道当前view的显示区域大小，那么我们需要使用到GeometryReader。如果我们将之前的操作全部封装为一个名为ImageWrapper，那么可以得到如下的代码：

```swift
struct PhotoViewer: View {
    var image: UIImage
    var body: some View {
        return GeometryReader { geometryProxy in
            ImageWrapper(image: self.image,
                         frame: CGRect(x: geometryProxy.safeAreaInsets.leading, y: geometryProxy.safeAreaInsets.trailing, width: geometryProxy.size.width, height: geometryProxy.size.height))
        }
    }
}

fileprivate struct ImageWrapper: View {
    // The image
    private let image: UIImage

    // The frame for the image view
    private let frame: CGRect
    
    init(image: UIImage, frame: CGRect) {
        self.image = image
        self.frame = frame
    }
}
```

根据frame的大小，我们就可以算出一个合适的缩放比例用来刚好全屏显示：

```swift
fileprivate struct ImageWrapper: View {
    init(image: UIImage, frame: CGRect) {
        ...
        var fitRatio: CGFloat = min(frame.width / CGFloat(image.cgImage!.width), frame.height / CGFloat(image.cgImage!.height))
        if fitRatio > 1 {
            fitRatio = 1
        }
    }
}
```

### 改进拖动

我们稍微来改进一下拖动这个功能，达到如下效果：

- 如果图片宽度大于屏幕宽度，放开拖动的时候，如果左边有空白，则图片会自动往左移动，以最左边开始为显示的起点（右边以及上下亦然）
- 如果图片宽度小于屏幕宽度，放开拖动的时候，横轴居中显示

不过，在改进拖动功能之前，需要等比缩放显示全屏时的图片大小，我们这里定义为minImgSize：

```swift
fileprivate struct ImageWrapper: View {
    private let minImgSize: CGSize
    ...
    
    init(image: UIImage, frame: CGRect) {
        ...
        maxImgSize = CGSize(width: CGFloat(image.cgImage!.width),
                            height: CGFloat(image.cgImage!.height))

        minImgSize = CGSize(width: maxImgSize.width * fitRatio,
                            height: maxImgSize.height * fitRatio)
    }
}
```

然后，我们就有了fixOffset函数，并且在放开手的时候调用：

```swift
fileprivate struct ImageWrapper: View {
    private func fixOffset() {
        if frame.width > minImgSize.width * scaleRatio {
            actualOffset.x = 0
        } else {
            let trailingBaseLine = (frame.width - minImgSize.width * scaleRatio) / 2
            if actualOffset.x < trailingBaseLine {
                actualOffset.x = trailingBaseLine
            }

            let leadingBaseLine = (minImgSize.width * scaleRatio - frame.width) / 2
            if actualOffset.x > leadingBaseLine {
                actualOffset.x = leadingBaseLine
            }
        }

        if frame.height > minImgSize.height * scaleRatio {
            actualOffset.y = 0
        } else {
            let trailingBaseLine = (frame.height - minImgSize.height * scaleRatio) / 2
            if actualOffset.y < trailingBaseLine {
                actualOffset.y = trailingBaseLine
            }

            let leadingBaseLine = (minImgSize.height * scaleRatio - frame.height) / 2
            if actualOffset.y > leadingBaseLine {
                actualOffset.y = leadingBaseLine
            }
        }
    }
    
     let dragOrDismiss = DragGesture()
            .onEnded { value in
                if let lastTranslation = self.lastTranslation {
                    self.actualOffset.x += (value.translation.width - lastTranslation.width) * self.scaleRatio
                    self.actualOffset.y += (value.translation.height - lastTranslation.height) * self.scaleRatio
                }

                self.fixOffset()

                self.lastTranslation = nil
            }
}
```

### 改进缩放

如果需要改进缩放的话，我们需要做到如下两个方面：

- 如果超过照片的最大大小，那么则恢复为最大的大小
- 如果缩放比例小于最小的缩放比，那么则使用最小的缩放

鉴于此，我们需要有两个属性minScale和maxScale来存储最小和最大缩放值：

```swift
fileprivate struct ImageWrapper: View {
	private let minScale: CGFloat
    private let maxScale: CGFloat
    ...
    init(image: UIImage, frame: CGRect) {
        minScale = fitRatio
        maxScale = min(maxImgSize.width / minImgSize.width, maxImgSize.height / minImgSize.height) * minScale
    }
}
```

接着来看一下手势放开后的复原操作：

```swift
let rotateAndZoom = MagnificationGesture()
            .onEnded { scale in

                if let lastScale = self.lastScale {
                    let ratio = 1.0 + (scale - lastScale)
                    self.scaleRatio *= ratio

                    if self.scaleRatio < 1 {
                        self.scaleRatio = 1
                    } else if self.scaleRatio * self.minScale > self.maxScale {
                        self.scaleRatio = self.maxScale / self.minScale
                    }
                }

                self.fixOffset()

                self.lastScale = nil
            }
```



## 工程源码

如果需要本工程的原始代码，可以见如下网址：

https://github.com/no-rains/SimplePhotoViewer

