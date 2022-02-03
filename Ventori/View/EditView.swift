//
//  UpdateScreen.swift
//  Ventori
//
//  Created by Proyash Saha on 2021-10-26.
//

import SwiftUI


struct EditView: View {

    var body: some View {
        VStack {

        }
        .navigationTitle(Text("Edit"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
    }
}

struct UpdateView_Previews: PreviewProvider {
    static var previews: some View {
        EditView()
    }
}
