//
//  PhotoViewer.swift
//  SimplePhotoViewer
//
//  Created by norains on 2020/3/19.
//  Copyright © 2020 norains. All rights reserved.
//

import SwiftUI

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
    // The image name
    let image: UIImage

    // The frame for the image view
    let frame: CGRect

    // The actual scale base on the minSize
    @State var actualScale: CGFloat = 1.0

    // The actual offset base on the minPosition
    @State var actualOffset: CGPoint = .zero

    var minImgSize: CGSize
    var maxImgSize: CGSize
    var minImgDisplayPoint: CGPoint
    var minScale: CGFloat
    var maxScale: CGFloat
    @State var scaleRatio: CGFloat = 1 // Base on the minScale

    init(image: UIImage, frame: CGRect) {
        self.image = image
        self.frame = frame

        var fitRatio: CGFloat = min(frame.width / CGFloat(image.cgImage!.width), frame.height / CGFloat(image.cgImage!.height))
        if fitRatio > 1 {
            fitRatio = 1
        }

        maxImgSize = CGSize(width: CGFloat(image.cgImage!.width),
                            height: CGFloat(image.cgImage!.height))

        minImgSize = CGSize(width: maxImgSize.width * fitRatio,
                            height: maxImgSize.height * fitRatio)

        minImgDisplayPoint = CGPoint(x: (frame.width - minImgSize.width) / 2,
                                     y: (frame.height - minImgSize.height) / 2)

        minScale = fitRatio
        maxScale = min(maxImgSize.width / minImgSize.width, maxImgSize.height / minImgSize.height) * minScale

        print("image size:\(image.cgImage!.width),\(image.cgImage!.height)")
        print("screen:\(frame)")
        print("minImgPoint:\(minImgDisplayPoint)")
        // print("actualSize:\(actualSize.width)")
    }

    @State var actualSize: CGSize = .zero

    // Magnify and Rotate States
    @State private var magScale: CGFloat = 1
    // @State private var rotAngle: Angle = .zero
    @State private var isScaled: Bool = false

    // Drag Gesture Binding
    @State private var dragOffset: CGSize = .zero

    // The actual position and size after scaling and being offset
    @State private var actualPosition: CGPoint = .zero

    @State private var lastTranslation: CGSize?
    @State private var lastScale: CGFloat?

    var body: some View {
        let rotateAndZoom = MagnificationGesture()
            .onChanged { scale in
                self.magScale = scale
                self.isScaled = true

                if let lastScale = self.lastScale {
                    // The zoom gesture is base on the center, so is a half
                    let ratio = 1.0 + (scale - lastScale)
                    self.scaleRatio *= ratio
                }

                self.lastScale = scale
            }
            .onEnded { scale in
                scale > 1 ? (self.magScale = scale) : (self.magScale = 1)
                self.isScaled = scale > 1

                if let lastScale = self.lastScale {
                    let ratio = 1.0 + (scale - lastScale)
                    self.scaleRatio *= ratio

                    if self.scaleRatio < 1 {
                        self.scaleRatio = 1
                    } else if self.scaleRatio * self.minScale > self.maxScale {
                        self.scaleRatio = self.maxScale / self.minScale
                    }
                }

                self.lastScale = nil
            }

        let dragOrDismiss = DragGesture()
            .onChanged { value in
                self.dragOffset = value.translation

                if let lastTranslation = self.lastTranslation {
                    self.actualPosition.x += value.translation.width - lastTranslation.width
                    self.actualPosition.y += value.translation.height - lastTranslation.height
                }

                self.lastTranslation = value.translation

                // self.actualPosition.x += value.translation.width
                // self.actualPosition.y += value.translation.height
            }
            .onEnded { value in
                if self.isScaled {
                    self.dragOffset = value.translation

                    if let lastTranslation = self.lastTranslation {
                        self.actualPosition.x += value.translation.width - lastTranslation.width
                        self.actualPosition.y += value.translation.height - lastTranslation.height
                    }

                    self.lastTranslation = nil

                    if self.actualSize.width <= self.frame.width {
                        self.actualPosition.x = 0
                    }

                    if self.actualSize.height <= self.frame.height {
                        self.actualPosition.y = 0
                    }

                } else {
                    self.dragOffset = CGSize.zero

                    self.actualPosition = .zero
                    self.actualSize.width = self.frame.width
                    self.actualSize.height = self.frame.height
                }
            }

        let fitToFill = TapGesture(count: 2)
            .onEnded {
                if self.scaleRatio > 1 {
                    self.scaleRatio = 1
                } else {
                    self.scaleRatio = self.maxScale / self.minScale
                }
            }
            .exclusively(before: dragOrDismiss)
            .exclusively(before: rotateAndZoom)

        return Image(uiImage: image)
            // .resizable()
            .renderingMode(.original)
            // .aspectRatio(contentMode: .fit)
            .gesture(fitToFill)
            // .scaleEffect(isScaled ? magScale : max(1 - abs(self.dragOffset.height) * 0.004, 0.6), anchor: .center)
            // .offset(x: dragOffset.width * magScale, y: dragOffset.height * magScale)
            // .offset(x: actualPosition.x, y: actualPosition.y)
            .scaleEffect(minScale * scaleRatio, anchor: .center)
            // .offset(x: minImgPoint.x, y:minImgPoint.y)
            .animation(.spring(response: 0.4, dampingFraction: 0.9))
    }
}
