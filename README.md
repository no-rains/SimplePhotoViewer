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

