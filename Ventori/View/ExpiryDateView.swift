//
//  ExpiryDateView.swift
//  Ventori
//
//  Created by Proyash Saha on 2022-02-20.
//

import SwiftUI

struct ExpiryDateView: View {
    
    @Binding var expiryDate: Date
    @State private var dateComponent = DateComponents()
    
    var body: some View {
        VStack {
            DatePicker("", selection: $expiryDate, in: Calendar.current.date(byAdding: dateComponent, to: Date())!..., displayedComponents: [.date])
        }
        .navigationTitle(Text("Pick an Expiry Date"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
        .onAppear {
            dateComponent.day = 2
        }
    }
}

struct ExpiryDateView_Previews: PreviewProvider {
    static var previews: some View {
        ExpiryDateView(expiryDate: .constant(Date()))
    }
}
