//
//  ContentView.swift
//  TestImageView
//
//  Created by norains on 2020/3/17.
//  Copyright © 2020 norains. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        return ZStack(alignment: .topLeading) {
            PhotoViewer(name: "photo2")
        }
    }
}
