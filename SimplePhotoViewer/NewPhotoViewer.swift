//
//  PhotoViewer2.swift
//  SimplePhotoViewer
//
//  Created by norains on 2020/3/30.
//  Copyright © 2020 norains. All rights reserved.
//

import SwiftUI

struct NewPhotoViewer: View {
    var name: String
    var body: some View {
        return GeometryReader { geometryProxy in
            ImageWrapper(name: self.name,
                         frame: CGRect(x: geometryProxy.safeAreaInsets.leading, y: geometryProxy.safeAreaInsets.trailing, width: geometryProxy.size.width, height: geometryProxy.size.height))
        }
    }
}

fileprivate struct ImageWrapper: View {
    // The image
    private let name: String

    // The frame for the image view
    private let frame: CGRect

    // The value is for draging and zoom gesture
    private let minImgSize: CGSize
    private let maxImgSize: CGSize
    private let minImgDisplayPoint: CGPoint
    private let minScale: CGFloat
    private let maxScale: CGFloat

    @GestureState private var dragOffset = CGSize.zero
    @State private var position = CGSize.zero
    @State private var scale: CGFloat = 1.0

    init(name: String, frame: CGRect) {
        self.name = name
        self.frame = frame

        // TODO: Find another way to get the image width and height
        let uiImage = UIImage(named: name)!
        let imageSize = uiImage.size
        
        var fitRatio: CGFloat = min(frame.width  / CGFloat(imageSize.width), frame.height / CGFloat(imageSize.height))
        if fitRatio > 1 {
            fitRatio = 1
        }

        maxImgSize = CGSize(width: CGFloat(imageSize.width),
                            height: CGFloat(imageSize.height))

        minImgSize = CGSize(width: maxImgSize.width * fitRatio,
                            height: maxImgSize.height * fitRatio)

        minImgDisplayPoint = CGPoint(x: (frame.width - minImgSize.width) / 2,
                                     y: (frame.height - minImgSize.height) / 2)

        minScale = fitRatio
        maxScale = min(maxImgSize.width / minImgSize.width, maxImgSize.height / minImgSize.height) * minScale
        
    }

    var body: some View {
        Image(name)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .offset(x: position.width + dragOffset.width, y: position.height + dragOffset.height)
            .animation(.easeInOut)
            .scaleEffect(scale)

            // 缩放
            .gesture(MagnificationGesture()
                .onChanged { value in
                    self.scale = value.magnitude
                }
            )
            // 拖拽
            .gesture(
                DragGesture()
                    .updating($dragOffset, body: { value, state, _ in

                        state = value.translation
                    })
                    .onEnded({ value in
                        self.position.height += value.translation.height
                        self.position.width += value.translation.width
                    })
            )
            // 点击放大
            .gesture(
                TapGesture()
                    .onEnded { _ in
                        self.scale += 0.1
                        print("\(self.scale)")
                    }
            )
    }
}
