//
//  CategoryView.swift
//  Ventori
//
//  Created by Proyash Saha on 2021-11-03.
//

import SwiftUI

struct CategoryView: View {
    
    @Environment(\.presentationMode) var presentation
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var moc

    @FetchRequest(entity: CategoriesCoreData.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \CategoriesCoreData.date, ascending: false)]) var categories: FetchedResults<CategoriesCoreData>
    
    @Binding var seclectedCategory: String
    
    @State private var text: String = ""
    
    @State private var toBeDeleted: IndexSet = []
    @State private var showDeleteAlert: Bool = false
    @State private var flag: Bool = false
    
    var body: some View {
        Form {
            Section() {
                Button {
                    seclectedCategory = "None"
                } label: {
                    HStack {
                        Text("None")
                            .foregroundColor(colorScheme == .light ? Color.black : Color.white)
                        Spacer()
                        if seclectedCategory == "None" {
                            Image(systemName: "checkmark")
                                .foregroundColor(Theme.mainColor)
                        }
                    }
                }
            }

            Section() {
                ForEach(0..<categories.count, id: \.self) { index in
                    Button {
                        seclectedCategory = categories[index].category!
                    } label: {
                        HStack {
                            Text(categories[index].category!)
                                .foregroundColor(colorScheme == .light ? Color.black : Color.white)
                            Spacer()
                            if seclectedCategory == categories[index].category! {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Theme.mainColor)
                            }
                        }
                    }
                    .deleteDisabled(seclectedCategory == categories[index].category)
                    .alert(isPresented: $showDeleteAlert) {
                        Alert(title: Text("Do you want to delete this Category?"),
                              primaryButton: .destructive(Text("Delete")) {
                                for index in self.toBeDeleted {
                                    let category = categories[index]
                                    self.moc.delete(category)
                                }
                                do {
                                    try self.moc.save()
                                } catch {
                                    print("Error while saving category!")
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
                }
                .onDelete(perform: deleteCategory)
            }
        }
        .navigationTitle(Text("Choose a Category"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                NavigationLink(destination: AddCategoryView()) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 23.0,height: 23.0)
                }
            }
        }
    }
    
    
    private func deleteCategory(at indexSet: IndexSet) {
        self.toBeDeleted = indexSet
        self.showDeleteAlert = true
    }
    
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView(seclectedCategory: .constant("None"))
    }
}
