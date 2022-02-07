//
//  ImageView.swift
//  Ventori
//
//  Created by Proyash Saha on 2022-02-06.
//

import SwiftUI

struct ImageView: View {
    
    var image: UIImage
    @GestureState var scale: CGFloat = 1.0
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width, height: 300)
                .scaleEffect(scale)
                .gesture(MagnificationGesture()
                    .updating($scale, body: { (value, scale, trans) in
                        if value >= 1 {
                            scale = value.magnitude
                        }
                    })
            )
        }
        .navigationTitle(Text(""))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(image: UIImage())
    }
}
