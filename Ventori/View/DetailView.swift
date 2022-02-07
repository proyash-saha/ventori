//
//  DetailView.swift
//  Ventori
//
//  Created by Proyash Saha on 2021-10-26.
//

import SwiftUI
import AVFAudio

struct DetailView: View {
    
    let MAX_SEARCH: Int = 10
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(entity: SearchCoreData.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \SearchCoreData.date, ascending: false)]) var searchedItemNames: FetchedResults<SearchCoreData>
    
    var item: ItemCoreData
    var tag: String
    var indexOfItem: Int
    
    @State private var tagColors: [Color] = [.orange, .green, .red, .blue, .yellow, .purple]
    @State private var flag = 0
    @State private var isShowingUpdateView = false
    
    var body: some View {
        
        let image: UIImage = UIImage(data: item.image!)!
        
        ScrollView {
            VStack(alignment: .leading) {
                Group {
                    HStack {
                        Spacer()
                        VStack {
                            NavigationLink(destination: ImageView(image: image)) {
                                Image(uiImage: image)
                                    .resizable()
                                    .clipped()
                                    .clipShape(Circle())
                                    .frame(width: 100, height: 100)
                                    .aspectRatio(contentMode: .fill)
                            }
                            Text("\(item.name!)")
                                .font(.system(size: 28, weight: .semibold))
                        }
                        Spacer()
                    }
                }
                Group {
                    Spacer()
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Count")
                            .labelStyle2()
                        Text("\(item.count)")
                            .infoStyle()
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Sold")
                            .labelStyle2()
                        Text("\(item.sold)")
                            .infoStyle()
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Cost Price")
                            .labelStyle2()
                        Text(String(format: "$%.2f", item.costPrice))
                            .infoStyle()
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Selling Price")
                            .labelStyle2()
                        Text(String(format: "$%.2f", item.sellingPrice))
                            .infoStyle()
                    }
                }
                Group {
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Profit")
                            .labelStyle2()
                        Text(String(format: "$%.2f", item.profit))
                            .infoStyle()
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Added On")
                            .labelStyle2()
                        Text("\(item.addedOnDate!, format: .dateTime.day().month().year())")
                            .infoStyle()
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Last Updated On")
                            .labelStyle2()
                        Text("\(item.updatedOnDate!, format: .dateTime.day().month().year())")
                            .infoStyle()
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Expiry Date")
                            .labelStyle2()
                        if flag != 1 {
                            Text("\(item.expiryDate!, format: .dateTime.day().month().year())")
                                .infoStyle()
                        }
                        else {
                            Text("N/A")
                                .infoStyle()
                        }
                    }
                    Spacer()
                }
                Group {
                    VStack(alignment: .leading) {
                        Text("Barcode")
                            .labelStyle2()
                        if item.barCode != "" {
                            Text("\(item.barCode!)")
                                .infoStyle()
                        }
                        else {
                            Text("N/A")
                                .infoStyle()
                        }
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Category")
                            .labelStyle2()
                        Text("\(item.category!)")
                            .infoStyle()
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Notes")
                            .labelStyle2()
                        if item.notes != "" {
                            Text("\(item.notes!)")
                                .infoStyle()
                        }
                        else {
                            Text("N/A")
                                .infoStyle()
                        }
                    }
                    Spacer()
                }
                Spacer()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: BackButton())
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            isShowingUpdateView.toggle()
                        } label: {
                            Text("Edit")
                            Image(systemName: "pencil.circle")
                        }
                    } label: {
                        Text("Options")
                    }
                    .background(
                        NavigationLink(destination: AddUpdateView(purpose: "Update", indexOfItem: indexOfItem), isActive: $isShowingUpdateView) {
                            EmptyView()
                        })
                }
            }
            .onAppear {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                
                if dateFormatter.string(from: item.addedOnDate!) == dateFormatter.string(from: item.expiryDate!) {
                    flag = 1
                }

                if tag == "search" {
                    let searchedName = SearchCoreData(context: self.moc)
                    searchedName.name = item.name!
                    searchedName.date = Date()

                    do {
                      try self.moc.save()
                    } catch {
                        print("Error while saving searched item name!")
                        self.moc.rollback()
                        print("Rolled back!")
                    }
                    
                    for i in 1..<searchedItemNames.count {
                        if searchedItemNames[i].name! == item.name! {
                            deleteSearch(at: [i])
                            break
                        }
                    }
                    
                    if searchedItemNames.count > MAX_SEARCH {
                        deleteSearch(at: [MAX_SEARCH])
                    }
                }
            }
        }
    }
    
    
    private func deleteSearch(at offsets: IndexSet) {
        for index in offsets {
            let search = searchedItemNames[index]
            self.moc.delete(search)
        }
        do {
            try self.moc.save()
        } catch {
            print("Error while saving searched item name!")
            self.moc.rollback()
            print("Rolled back!")
        }
    }
}


extension View {
    func labelStyle2() -> some View {
        self.foregroundColor(.gray)
            .font(.system(size: 15, weight: .semibold))
    }
    
    func infoStyle() -> some View {
        self.font(.system(size: 22, weight: .semibold))
    }
}


struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(item: ItemCoreData(), tag: "", indexOfItem: -1)
    }
}
