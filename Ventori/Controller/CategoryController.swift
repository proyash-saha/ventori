//
//  CategoryController.swift
//  Ventori
//
//  Created by Proyash Saha on 2021-11-22.
//

import Foundation

struct Category: Identifiable, Hashable {
    
    let id: UUID
    var category: String
    var date: Date
    
    init(_ category: String){
        self.id = UUID()
        self.category = category
        self.date = Date()
    }
}
