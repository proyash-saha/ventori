//
//  CameraButton.swift
//  Ventori
//
//  Created by Proyash Saha on 2021-10-26.
//

import SwiftUI

struct CameraButton: View {
    
    @Binding var showActionSheet: Bool
    
    var body: some View {
        Button(action: {
            self.showActionSheet.toggle()
        }) {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 36, height: 36, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .foregroundColor(Color.init(red: 0.8, green: 0.8, blue: 0.8))
                .overlay(
                    Image(systemName: "camera.fill")
                        .foregroundColor(.black)
                )
        }
    }
}

struct CameraButton_Previews: PreviewProvider {
    static var previews: some View {
        CameraButton(showActionSheet: .constant(false))
    }
}
