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
    // The actual scale base on the minSize
    @State private var actualScale: CGFloat = 1.0

    // The actual offset base on the minPosition
    @State private var actualOffset: CGPoint = .zero

    // Base on the minScale, the min value is 1
    @State private var scaleRatio: CGFloat = 1

    @State private var lastTranslation: CGSize?
    @State private var lastScale: CGFloat?

    // The image
    private let image: UIImage

    // The frame for the image view
    private let frame: CGRect

    // The value is for draging and zoom gesture
    private let minImgSize: CGSize
    private let maxImgSize: CGSize
    private let minImgDisplayPoint: CGPoint
    private let minScale: CGFloat
    private let maxScale: CGFloat

    init(image: UIImage, frame: CGRect) {
        self.image = ImageWrapper.normalizedImage(image)
        self.frame = frame

        let imageSize = image.size

        var fitRatio: CGFloat = min(frame.width / CGFloat(imageSize.width), frame.height / CGFloat(imageSize.height))
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

    /**
     Normalized Image base on the orientation
     
     - Parameter image: The image for normalizing

     - Returns: The normalized image
     **/
    private static func normalizedImage(_ image: UIImage) -> UIImage {
        if image.imageOrientation == UIImage.Orientation.up {
            return image
        }

        UIGraphicsBeginImageContextWithOptions(image.size, false, 1)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return normalizedImage
    }

    private func fixOffset() {
        if frame.width > minImgSize.width * scaleRatio {
            actualOffset.x = 0
        } else {
            let trailingBaseLine = (frame.width - minImgSize.width * scaleRatio) / 2
            if actualOffset.x < trailingBaseLine {
                actualOffset.x = trailingBaseLine
            }

            let leadingBaseLine = (minImgSize.width * scaleRatio - frame.width) / 2
            if actualOffset.x > leadingBaseLine {
                actualOffset.x = leadingBaseLine
            }
        }

        if frame.height > minImgSize.height * scaleRatio {
            actualOffset.y = 0
        } else {
            let trailingBaseLine = (frame.height - minImgSize.height * scaleRatio) / 2
            if actualOffset.y < trailingBaseLine {
                actualOffset.y = trailingBaseLine
            }

            let leadingBaseLine = (minImgSize.height * scaleRatio - frame.height) / 2
            if actualOffset.y > leadingBaseLine {
                actualOffset.y = leadingBaseLine
            }
        }
    }

    var body: some View {
        let rotateAndZoom = MagnificationGesture()
            .onChanged { scale in

                if let lastScale = self.lastScale {
                    // The zoom gesture is base on the center, so is a half
                    let ratio = 1.0 + (scale - lastScale)
                    self.scaleRatio *= ratio
                }

                self.lastScale = scale
            }
            .onEnded { scale in

                if let lastScale = self.lastScale {
                    let ratio = 1.0 + (scale - lastScale)
                    self.scaleRatio *= ratio

                    if self.scaleRatio < 1 {
                        self.scaleRatio = 1
                    } else if self.scaleRatio * self.minScale > self.maxScale {
                        self.scaleRatio = self.maxScale / self.minScale
                    }
                }

                self.fixOffset()

                self.lastScale = nil
            }

        let dragOrDismiss = DragGesture()
            .onChanged { value in

                if let lastTranslation = self.lastTranslation {
                    //When being scaling, the size is rising to leading and trailing, so double the value
                    self.actualOffset.x += (value.translation.width - lastTranslation.width) * self.scaleRatio * 2
                    self.actualOffset.y += (value.translation.height - lastTranslation.height) * self.scaleRatio * 2
                }
                
                print(self.scaleRatio)
                print(self.actualOffset)

                self.lastTranslation = value.translation
            }
            .onEnded { value in

                if let lastTranslation = self.lastTranslation {
                    self.actualOffset.x += (value.translation.width - lastTranslation.width) * self.scaleRatio * 2
                    self.actualOffset.y += (value.translation.height - lastTranslation.height) * self.scaleRatio * 2
                }

                self.fixOffset()

                self.lastTranslation = nil
            }

        let fitToFill = TapGesture(count: 2)
            .onEnded {
                if self.scaleRatio > 1 {
                    self.scaleRatio = 1
                } else {
                    self.scaleRatio = self.maxScale / self.minScale
                }
                self.actualOffset = .zero
            }
            .exclusively(before: dragOrDismiss)
            .exclusively(before: rotateAndZoom)

        return Image(uiImage: image)
            // .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .gesture(fitToFill)
            // .scaleEffect(minScale * scaleRatio, anchor: .center)
            .scaleEffect(scaleRatio, anchor: .center)
            .offset(x: actualOffset.x, y: actualOffset.y)
            .animation(.spring(response: 0.4, dampingFraction: 0.9))
    }
}
