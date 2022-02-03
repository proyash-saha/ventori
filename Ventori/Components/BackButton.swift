//
//  BackButton.swift
//  Ventori
//
//  Created by Proyash Saha on 2021-10-26.
//

import SwiftUI

struct BackButton: View {
    
    @Environment(\.presentationMode) var presentation

    var body : some View {
        Button(action: {
            self.presentation.wrappedValue.dismiss()
        }) {
            HStack{
                Image(systemName: "arrow.backward.circle")
                    .font(Font.system(size: 25, weight: .semibold))
            }
        }
    }
}

struct BackButton_Previews: PreviewProvider {
    static var previews: some View {
        BackButton()
    }
}
