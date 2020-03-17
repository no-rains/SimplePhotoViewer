//
//  ImageView.swift
//  Scribe
//
//  Created by Cyril Zakka on 7/21/19.
//  Copyright © 2019 Cyril Zakka. All rights reserved.
//
import SwiftUI

/// A struct responsible for holding `ImageView` metadata.
struct ImageData: Codable, Identifiable {
    let id = UUID()
    var imageName: String = "photo"
    var cornerRadius: CGFloat = 0
}

/// Sets a `PreferenceKey` for the `CGRect` of an `ImageView`.
/// For more information, read the following [post](https://swiftui-lab.com/communicating-with-the-view-tree-part-1/).
struct CGRectPreferenceKey: PreferenceKey {
    static var defaultValue = CGRect.zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
    
    typealias Value = CGRect
}

/// A view responsible for fetching the `CGSize` and `CGRect` of an `ImageView`.
/// For more information, read the following [post](https://swiftui-lab.com/communicating-with-the-view-tree-part-1/).
struct ImageViewGeometry: View {
    var body: some View {
        GeometryReader { reader in
            return Rectangle()
                .fill(Color.clear)
                .preference(key: CGRectPreferenceKey.self, value: reader.frame(in: .named("globalCooardinate")))
        }
    }
}

/// A view responsible for displaying an image.
struct ImageView: View {
    
    @EnvironmentObject var imageViewerAnimatorBindings: ImageViewerAnimatorBindings
    @Binding var sourceRect: CGRect
    @Binding var selectedImage: ImageData
    
    var imageName: String
    
    var width: CGFloat?
    var height: CGFloat?
    var cornerRadius: CGFloat = 0
    
    var body: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: height, alignment: .center)
            .opacity(self.imageViewerAnimatorBindings.shouldAnimateTransition ? 0:1)
            .animation(Animation.linear(duration: self.imageViewerAnimatorBindings.shouldAnimateTransition ? 0.05:0.1).delay(self.imageViewerAnimatorBindings.shouldAnimateTransition ? 0:0.3))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .background(ImageViewGeometry()).onTapGesture {
                self.selectedImage = ImageData(imageName: self.imageName, cornerRadius: self.cornerRadius)
                self.imageViewerAnimatorBindings.shouldAnimateTransition = true
            }
            .onPreferenceChange(CGRectPreferenceKey.self, perform: { self.sourceRect = $0 })
    }
}
