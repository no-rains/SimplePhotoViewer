//
//  ContentView.swift
//  TestImageView
//
//  Created by norains on 2020/3/17.
//  Copyright © 2020 norains. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var sourceRect: CGRect = .zero
    @State var selectedImage: ImageData = ImageData()

    let imageViewerAnimatorBindings = ImageViewerAnimatorBindings()

    var body: some View {
        return ZStack(alignment: .topLeading) {
            /*
            ImageView(sourceRect: $sourceRect, selectedImage: $selectedImage, imageName: "photo", height: 200, cornerRadius: 20)
                .padding()
                .environmentObject(imageViewerAnimatorBindings)

            ImageViewAnimator(sourceRect: sourceRect, selectedImage: selectedImage)
                .environmentObject(imageViewerAnimatorBindings)
             */
            
            PhotoViewer(image: UIImage(named: "photo")!)
        }
        .environmentObject(imageViewerAnimatorBindings)
        .coordinateSpace(name: "globalCooardinate")
    }
}
