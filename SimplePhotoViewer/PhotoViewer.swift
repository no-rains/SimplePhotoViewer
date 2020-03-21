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
                         frame: CGRect(x: geometryProxy.safeAreaInsets.leading, y: geometryProxy.safeAreaInsets.trailing, width: geometryProxy.size.width, height: geometryProxy.size.height))
        }
    }
}

fileprivate struct ImageWrapper: View {
    // The image name
    var imageName: String

    // The frame for the image view
    var frame: CGRect

    // Magnify and Rotate States
    @State private var magScale: CGFloat = 1
    // @State private var rotAngle: Angle = .zero
    @State private var isScaled: Bool = false

    // Drag Gesture Binding
    @State private var dragOffset: CGSize = .zero

    // The actual position and size after scaling and being offset
    @State private var actualPosition: CGPoint = .zero
    @State private var actualSize: CGSize = .zero

    var body: some View {
        let rotateAndZoom = MagnificationGesture()
            .onChanged {
                self.magScale = $0
                self.isScaled = true
            }
            .onEnded {
                $0 > 1 ? (self.magScale = $0) : (self.magScale = 1)
                self.isScaled = $0 > 1
            }

        let dragOrDismiss = DragGesture()
            .onChanged { self.dragOffset = $0.translation
                print("location:\($0.location)")
                print("startlocation:\($0.startLocation)")
            }
            .onEnded { value in
                if self.isScaled {
                    self.dragOffset = value.translation
                    
                    self.actualSize.width += value.translation.width
                    self.actualSize.height += value.translation.height

                    // print(self.dragOffset)

                    /*
                     if self.dragOffset.height <= UIScreen.main.bounds.height{
                         self.dragOffset.height = 0
                     }

                     if self.dragOffset.width <= UIScreen.main.bounds.width{
                         self.dragOffset.width = 0
                     }
                     */

                } else {
                    self.dragOffset = CGSize.zero
                    
                    self.actualSize = CGSize.zero
                }
            }

        let fitToFill = TapGesture(count: 2)
            .onEnded {
                self.isScaled.toggle()
                if !self.isScaled {
                    self.magScale = 1
                    self.dragOffset = .zero
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
            .offset(x: dragOffset.width * magScale, y: dragOffset.height * magScale)
            .animation(.spring(response: 0.4, dampingFraction: 0.9))
    }
}
