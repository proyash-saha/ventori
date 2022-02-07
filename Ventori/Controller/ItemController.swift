//
//  ItemController.swift
//  Ventori
//
//  Created by Proyash Saha on 2021-10-26.
//

import Foundation

struct Item: Identifiable, Hashable {
    
    var image: Data
    let id: UUID
    var name: String
    var count: Int
    var sold: Int
    let addedOnDate: Date
    var updatedOnDate: Date
    var expiryDate: Date
    var costPrice: Double
    var sellingPrice: Double
    var profit: Double
    var tagColorIndex: Int
    var barCode: String
    var category: String
    var notes: String
    
    init(_ image: Data, _ name: String, _ count: Int, _ sold: Int, _ expiryDate: Date, _ costPrice: Double, _ sellingPrice: Double, _ tagColorIndex: Int, _ barCode: String, _ category: String, _ notes: String){
        self.image = image
        self.id = UUID()
        self.name = name
        self.count = count
        self.sold = sold
        self.addedOnDate = Date()
        self.updatedOnDate = Date()
        self.expiryDate = expiryDate
        self.costPrice = costPrice
        self.sellingPrice = sellingPrice
        self.profit = (sellingPrice - costPrice) * Double(sold)
        self.tagColorIndex = tagColorIndex
        self.barCode = barCode
        self.category = category
        self.notes = notes
    }
    
//    mutating func newCount(_ num: Int){
//        self.count = num
//    }
//
//    mutating func addToCount(_ num: Int){
//        self.count += num
//    }
//
//    mutating func updateSold(_ num: Int){
//        self.sold += num
//        self.count -= num
//        self.profit += (self.sellingPrice - self.costPrice) * Double(num)
//    }
//
//    mutating func updateCostPrice(_ price: Double){
//        self.costPrice = price
//    }
//
//    mutating func updateSellingPrice(_ price: Double){
//        self.sellingPrice = price
//    }
}
