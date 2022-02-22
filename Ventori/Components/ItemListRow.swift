//
//  ItemListRow.swift
//  Ventori
//
//  Created by Proyash Saha on 2022-02-06.
//

import SwiftUI

struct ItemListRow: View {
    
    @State private var tagColors: [Color] = [.orange, .green, .red, .blue, .yellow, .purple]
    
    var item: ItemCoreData
    
    var body: some View {
        HStack {
            if item.tagColorIndex != -1 {
                RoundedRectangle(cornerRadius: 50)
                    .frame(width: 10)
                    .foregroundColor(tagColors[Int(item.tagColorIndex)])
            }
            else {
                RoundedRectangle(cornerRadius: 50)
                    .frame(width: 10, height: 30)
                    .hidden()
            }
            Text(item.name!)
                .font(.system(size: 20, weight: .semibold))
            Spacer()
            Text("\(item.count)")
                .padding(.trailing, 20)
        }
    }
}

struct ItemListRow_Previews: PreviewProvider {
    static var previews: some View {
        ItemListRow(item: ItemCoreData())
    }
}
