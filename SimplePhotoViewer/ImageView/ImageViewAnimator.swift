//
//  ImageViewerHelper.swift
//  Scribe
//
//  Created by Cyril Zakka on 7/21/19.
//  Copyright © 2019 Cyril Zakka. All rights reserved.
//
import SwiftUI
import Combine

/// A binding responsible for propagating animation information for `ImageViewAnimator`.
class ImageViewerAnimatorBindings: ObservableObject {
    let willChange = PassthroughSubject<Void, Never>()

    var shouldAnimateTransition: Bool = false {
        willSet { willChange.send() }
    }
}

/// A view responsible for animating the transition from `ImageView` to `InteractiveImageView`.
struct ImageViewAnimator: View {
    
    @EnvironmentObject var imageViewerAnimatorBindings: ImageViewerAnimatorBindings
    @State var dragOffset: CGSize = .zero
    
    var sourceRect: CGRect
    var selectedImage: ImageData
    
    var body: some View {
        /*
        ZStack(alignment: self.imageViewerAnimatorBindings.shouldAnimateTransition ? .center:.topLeading) {
            Rectangle()
                .opacity(
                    self.dragOffset.height != .zero ? Double(max(1 - abs(self.dragOffset.height)*0.004, 0.6)):self.imageViewerAnimatorBindings.shouldAnimateTransition ? 1:0
                )
                .animation(.linear)
 */
            InteractiveImageView(dragOffset: $dragOffset, selectedImage: selectedImage, sourceRect: sourceRect)
                .aspectRatio(contentMode: self.imageViewerAnimatorBindings.shouldAnimateTransition ? .fit:.fill)
                .frame(width: self.imageViewerAnimatorBindings.shouldAnimateTransition ? nil:sourceRect.width, height: self.imageViewerAnimatorBindings.shouldAnimateTransition ? nil:sourceRect.height, alignment: .center)
                .offset(x: self.imageViewerAnimatorBindings.shouldAnimateTransition ? 0:sourceRect.origin.x, y: self.imageViewerAnimatorBindings.shouldAnimateTransition ? 0:sourceRect.origin.y + 42)
                // TODO: Find a way to get `.edgesIgnoringSafeArea(.all)` offset programatically instead
       // }
            
        //.opacity(self.imageViewerAnimatorBindings.shouldAnimateTransition ? 1:0)
        //.animation(self.imageViewerAnimatorBindings.shouldAnimateTransition ? nil:Animation.linear(duration:0.2).delay(0.4))
        //.edgesIgnoringSafeArea(.all)
    }
}
