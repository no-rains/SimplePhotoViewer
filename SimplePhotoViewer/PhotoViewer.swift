//
//  PhotoViewer.swift
//  SimplePhotoViewer
//
//  Created by norains on 2020/3/19.
//  Copyright © 2020 norains. All rights reserved.
//

import SwiftUI

struct PhotoViewer: View {
    var imageName: String
    var body: some View {
        return GeometryReader { geometryProxy in
            ImageWrapper(imageName: self.imageName,
                         frame: CGRect(x: geometryProxy.safeAreaInsets.leading, y: geometryProxy.safeAreaInsets.trailing, width: geometryProxy.size.width, height: geometryProxy.size.height),
                         actualSize: CGSize(width: geometryProxy.size.width, height: geometryProxy.size.height))
        }
    }
}

fileprivate struct ImageWrapper: View {
    // The image name
    let imageName: String

    // The frame for the image view
    let frame: CGRect

    @State var actualSize: CGSize

    /*
     init(imageName: String, frame: CGRect, size: CGSize) {
         self.imageName = imageName
         self.frame = frame
         self.actualSize = size

         print("frame.width:\(frame.width)")
         print("actualSize:\(self.actualSize.width)")
     }
     */

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
                    let curScale = 1.0 + (scale - lastScale)
                    self.actualPosition.x *= curScale / 2.0
                    self.actualPosition.y *= curScale / 2.0
                    self.actualSize.width *= curScale
                    self.actualSize.height *= curScale
                }

                self.lastScale = scale
            }
            .onEnded { scale in
                scale > 1 ? (self.magScale = scale) : (self.magScale = 1)
                self.isScaled = scale > 1

                if let lastScale = self.lastScale {
                    // The zoom gesture is base on the center, so is a half
                    let curScale = 1.0 + (scale - lastScale)
                    self.actualPosition.x *= curScale / 2.0
                    self.actualPosition.y *= curScale / 2.0
                    self.actualSize.width *= curScale
                    self.actualSize.height *= curScale
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
                self.isScaled.toggle()
                if !self.isScaled {
                    self.magScale = 1

                    // Reset the value
                    self.dragOffset = .zero
                    self.actualSize.width = self.frame.width
                    self.actualSize.height = self.frame.height
                }
            }
            .exclusively(before: dragOrDismiss)
            .exclusively(before: rotateAndZoom)

        return Image(imageName)
            .resizable()
            .renderingMode(.original)
            .aspectRatio(contentMode: .fit)
            .gesture(fitToFill)
            .scaleEffect(isScaled ? magScale : max(1 - abs(self.dragOffset.height) * 0.004, 0.6), anchor: .center)
            // .offset(x: dragOffset.width * magScale, y: dragOffset.height * magScale)
            .offset(x: actualPosition.x, y: actualPosition.y)
            .animation(.spring(response: 0.4, dampingFraction: 0.9))
    }
}
