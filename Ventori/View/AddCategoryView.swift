//
//  AddCategoryView.swift
//  Ventori
//
//  Created by Proyash Saha on 2021-11-29.
//

import SwiftUI

struct AddCategoryView: View {
    
    @Environment(\.presentationMode) var presentation
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(entity: CategoriesCoreData.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \CategoriesCoreData.date, ascending: false)]) var categories: FetchedResults<CategoriesCoreData>
    
    @State private var name: String = ""
    @State private var showExistsAlert: Bool = false
    @State private var alreadyExists: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            TextField("Add a category", text: $name)
                .textFieldStyle()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
        }
        .padding()
        .navigationTitle(Text("New Category"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    alreadyExists = checkExistence()
                    if alreadyExists {
                        showExistsAlert.toggle()
                    }
                    else {
                        saveCategory()
                    }
                } label: {
                    Text("Add")
                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                        .background(Theme.mainColor)
                        .foregroundColor(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .fixedSize(horizontal: true, vertical: false)
                        .font(.system(size: 16, weight: .bold))
                }
                .disabled(name == "" ? true : false)
                .opacity(name == "" ? 0.6 : 1.0)
            }
        }
        .alert(isPresented: $showExistsAlert) {
            Alert(title: Text("Category \"\(name)\" already exists."), dismissButton: .default(Text("OK")))
        }
    }

    
    private func checkExistence() -> Bool {
        for i in 0..<categories.count {
            if categories[i].category!.lowercased() == name.lowercased() {
                return true
            }
        }
        return false
    }
    
    
    private func saveCategory() {
        let category = Category(name)
        let cdCategory = CategoriesCoreData(context: self.moc)
        
        cdCategory.id = category.id
        cdCategory.category = category.category
        cdCategory.date = category.date
        
        do {
          try self.moc.save()
        } catch {
            print("Error while saving category!")
            self.moc.rollback()
            print("Rolled back!")
        }
        
        self.presentation.wrappedValue.dismiss()
    }
    
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


struct AddCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        AddCategoryView()
    }
}
