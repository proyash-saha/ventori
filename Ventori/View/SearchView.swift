//
//  SearchScreen.swift
//  Ventori
//
//  Created by Proyash Saha on 2021-10-26.
//

import SwiftUI

struct SearchView: View {
    
    @Environment(\.presentationMode) var presentation
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(entity: ItemCoreData.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \ItemCoreData.addedOnDate, ascending: false)]) var items: FetchedResults<ItemCoreData>
    @FetchRequest(entity: SearchCoreData.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \SearchCoreData.date, ascending: false)]) var searchedItemNames: FetchedResults<SearchCoreData>
    
    @State private var searchText: String = ""
    @State private var showCancelButton: Bool = false
    
    @State private var scannedCode: String = ""
    @State private var showBarCodeScanner: Bool = false
    @State private var itemIndex: Int = -1
    
    @State private var searchedItem: [ItemCoreData] = []
    
    @State private var tempIdList: [UUID] = []
    
    @State private var toBeDeleted: IndexSet = []
    @State private var showDeleteAlert: Bool = false

    var body: some View {
            VStack {
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")

                        TextField("Search an item by name...", text: $searchText, onEditingChanged: { isEditing in
                            withAnimation {
                                self.showCancelButton = true
                            }
                        })
                        .foregroundColor(.primary)
                        .disableAutocorrection(true)

                        if searchText != "" {
                            Button {
                                self.searchText = ""
                                self.tempIdList.removeAll()
                                
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
                    .foregroundColor(.secondary)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10.0)

                    if showCancelButton  {
                        Button {
                            withAnimation {
                                hideKeyboard()
                                self.searchText = ""
                                self.searchedItem.removeAll()
                                self.tempIdList.removeAll()
                                self.itemIndex = -1
                                self.showCancelButton = false
                            }
                        } label: {
                            Text("Cancel")
                        }
                    }
                    else {
                        Button {
                            withAnimation {
                                self.showBarCodeScanner.toggle()
                            }
                        } label: {
                            Image(systemName: "barcode.viewfinder")
                                .resizable()
                                .frame(width: 35,height: 28)
                        }
                        .sheet(isPresented: self.$showBarCodeScanner) {
                            BarcodeScanner(showBarCodeScanner: self.$showBarCodeScanner, scannedCode: self.$scannedCode, itemIndex: self.$itemIndex, mode: "search")
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
                .onChange(of: itemIndex) { newValue in
                    if itemIndex != -1 && searchText == "" {
                        searchedItem.append(items[newValue])
                        withAnimation {
                            self.showCancelButton = true
                        }
                    }
                }
                
                if searchedItemNames.count != 0 && itemIndex == -1 && searchText == "" {
                    HStack {
                        Text("Recently Searched")
                        
                        Spacer()
                        
                        Button {
                            var indexSet: IndexSet = []
                            for i in 0..<searchedItemNames.count {
                                indexSet.insert(i)
                            }
                            deleteSearch(at: indexSet)
                        } label: {
                            Text("Clear")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .font(.system(size: 16, weight: .bold))
                    
                    Divider().frame(height: 0.5).background(Color(.secondarySystemBackground)).padding(.horizontal)
                }
                
                if itemIndex == -1 && searchText == "" {
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(searchedItemNames) { data in
                                Button {
                                    withAnimation {
                                        searchText = data.name!
                                        showCancelButton = true
                                    }
                                } label: {
                                    Text(data.name!)
                                }
                                .padding(5)
                                .font(.system(size: 18, weight: .regular))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    }
                }
                
                Spacer()

                if searchText != "" || !searchedItem.isEmpty {
                    List {
                        ForEach(searchText == "" ? searchedItem : items.filter { $0.name!.lowercased().contains(searchText.lowercased()) }) { item in
                            NavigationLink(destination: DetailView(item: item, tag: "search")) {
                                Text(item.name!)
                            }
                            .alert(isPresented: self.$showDeleteAlert) {
                                Alert(title: Text("Do you want to delete this Item?"),
                                      primaryButton: .destructive(Text("Delete")) {
                                    for index in self.toBeDeleted {
                                            let tempId = tempIdList[index]
                                            for i in 0..<items.count {
                                                if items[i].id == tempId {
                                                    self.moc.delete(items[i])
                                                    tempIdList.removeAll()
                                                    break
                                                }
                                            }
                                        }
                                        do {
                                            try self.moc.save()
                                        } catch {
                                            print("Error while saving item!")
                                            self.moc.rollback()
                                            print("Rolled back!")
                                        }
                                            self.toBeDeleted = []
                                        },
                                      secondaryButton: .cancel() {
                                        self.toBeDeleted = []
                                    }
                                )
                            }
                            .onAppear{
                                if searchText != "" {
                                    tempIdList.append(item.id!)
                                }
                            }
                        }
                        .onDelete(perform: deleteItem)
                    }
                }
        }
        .navigationTitle(Text("Search"))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
    private func deleteItem(at indexSet: IndexSet) {
        self.toBeDeleted = indexSet
        self.showDeleteAlert = true
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
    
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
