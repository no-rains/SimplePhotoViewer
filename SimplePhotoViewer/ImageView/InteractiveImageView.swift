//
//  ImageViewer.swift
//  Scribe
//
//  Created by Cyril Zakka on 7/21/19.
//  Copyright © 2019 Cyril Zakka. All rights reserved.
//
import SwiftUI

/// A view responsible for creating the now-standard image viewer on iOS. Enables zooming, panning, action sheet presentation and swipe-to-dismiss.
struct InteractiveImageView: View {
    
    // Environment Object
    @EnvironmentObject var imageViewerAnimatorBindings: ImageViewerAnimatorBindings
    
    // Magnify and Rotate States
    @State private var magScale: CGFloat = 1
    @State private var rotAngle: Angle = .zero
    @State private var isScaled: Bool = false
    
    // Drag Gesture Binding
    @Binding var dragOffset: CGSize
    
    // Double Tap Gesture State
    @State private var shouldFit: Bool = true
    
    // Action Sheet State
    @State var shouldShowActionSheet = false
    
    // Image CGSize State
    @State var imageSize: CGSize = .zero
    
    var selectedImage: ImageData
    var sourceRect: CGRect
    
    var sheet: ActionSheet {
        ActionSheet(title: Text("Image options"), message: nil, buttons: [
            .default(Text("Save Image")) { self.shouldShowActionSheet = false },
            .destructive(Text("Delete Image")){ self.shouldShowActionSheet = false },
            .cancel(){self.shouldShowActionSheet = false}
        ])
    }
    
    var body: some View {
        
        // Gestures
        let activateActionSheet = LongPressGesture()
            .onEnded { _ in self.shouldShowActionSheet = true }
        
        let rotateAndZoom = MagnificationGesture()
            .onChanged {
                self.magScale = $0
                self.isScaled = true
        }
        .onEnded {
            $0 > 1 ? (self.magScale = $0):(self.magScale = 1)
            self.isScaled = $0 > 1
        }
        .simultaneously(with: RotationGesture()
            .onChanged { self.rotAngle = $0 }
            .onEnded { _ in  self.rotAngle = .zero }
        )
        
        let dragOrDismiss = DragGesture()
            .onChanged { self.dragOffset = $0.translation }
            .onEnded { value in
                if self.isScaled {
                    self.dragOffset = value.translation
                } else {
                    if abs(self.dragOffset.height) > 100 {
                        self.imageViewerAnimatorBindings.shouldAnimateTransition = false
                    }
                    self.dragOffset = CGSize.zero
                }
        }
        
        let fitToFill = TapGesture(count: 2)
            .onEnded {
                self.isScaled ? (self.shouldFit = true):(self.shouldFit = false)
                self.isScaled.toggle()
                if !self.isScaled {
                    self.magScale = 1
                    self.dragOffset = .zero
                }
        }
        .exclusively(before: activateActionSheet)
            .exclusively(before: dragOrDismiss)
            .exclusively(before: rotateAndZoom)
        
        
        return ZStack(alignment: .center) {
            Image(selectedImage.imageName)
                .resizable()
                .renderingMode(.original)
                .clipShape(RoundedRectangle(cornerRadius: self.imageViewerAnimatorBindings.shouldAnimateTransition ? 0:selectedImage.cornerRadius,
                                            style: .continuous)
                    .size(
                        width:  self.imageViewerAnimatorBindings.shouldAnimateTransition ? self.imageSize.width:sourceRect.width,
                        height: self.imageViewerAnimatorBindings.shouldAnimateTransition ? self.imageSize.height:sourceRect.height
                )
                    .offset(x: 0, y: self.imageViewerAnimatorBindings.shouldAnimateTransition ? 0:yOffset(sizeOfImage: self.imageSize, targetMaskSize: self.sourceRect.size))
            )
                .gesture(fitToFill)
                .scaleEffect(isScaled ? magScale: max(1 - abs(self.dragOffset.height)*0.004, 0.6), anchor: .center)
                .rotationEffect(rotAngle, anchor: .center)
                .offset(x: dragOffset.width*magScale, y: dragOffset.height*magScale)
                .background(ImageViewGeometry())
                .onPreferenceChange(CGRectPreferenceKey.self, perform: { self.imageSize = $0.size })
                .animation(.spring(response: 0.4, dampingFraction: 0.9))
        }
            
            .actionSheet(isPresented: $shouldShowActionSheet, content: { sheet })
    }
    
    func yOffset(sizeOfImage: CGSize, targetMaskSize: CGSize) -> CGFloat {
        let midImage = sizeOfImage.height/2
        let midMask = targetMaskSize.height/2
        return midImage - midMask
    }
}
