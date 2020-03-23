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

## 手势

对图片的操作，自然离不开手势，所以我们这里就需要看一下相关的手势操作。

### MagnificationGesture

MagnificationGesture主要是用来处理缩放的，其形式大致如下：

```swift
let rotateAndZoom = MagnificationGesture()
            .onChanged { scale in
                //一直拖动的时候，就会执行这里
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



### DragGesture



### TapGesture



