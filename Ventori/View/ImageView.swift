//
//  ImageView.swift
//  Ventori
//
//  Created by Proyash Saha on 2022-02-06.
//

import SwiftUI

struct ImageView: View {
    
    var image: UIImage
    @State var scale = 1.0
    @State private var lastScale = 1.0
    private let minScale = 1.0
    private let maxScale = 1.0
    
    var magnification: some Gesture {
        MagnificationGesture()
            .onChanged { state in
                if state > 1 {
                    adjustScale(from: state)
                }
            }
            .onEnded { state in
                withAnimation {
                    validateScaleLimits()
                }
                lastScale = 1.0
            }
    }

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .scaleEffect(scale)
            .gesture(magnification)
    }
    
    func adjustScale(from state: MagnificationGesture.Value) {
        let delta = state / lastScale
        scale *= delta
        lastScale = state
    }
    
    func getMinimumScaleAllowed() -> CGFloat {
        return max(scale, minScale)
    }
    
    func getMaximumScaleAllowed() -> CGFloat {
        return min(scale, maxScale)
    }
    
    func validateScaleLimits() {
        scale = getMinimumScaleAllowed()
        scale = getMaximumScaleAllowed()
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(image: UIImage())
    }
}
