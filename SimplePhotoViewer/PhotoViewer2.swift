//
//  PhotoViewer2.swift
//  SimplePhotoViewer
//
//  Created by norains on 2020/3/30.
//  Copyright © 2020 norains. All rights reserved.
//

import SwiftUI

struct PhotoViewer2: View {
    var name: String

    @GestureState private var dragOffset = CGSize.zero
    @State private var position = CGSize.zero
    @State private var scale: CGFloat = 1.0

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
