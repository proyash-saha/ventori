//
//  AddScreen.swift
//  Ventori
//
//  Created by Proyash Saha on 2021-10-26.
//

import SwiftUI

struct AddView: View {
    
    @Environment(\.presentationMode) var presentation
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(entity: ItemCoreData.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \ItemCoreData.addedOnDate, ascending: false)]) var items: FetchedResults<ItemCoreData>

    
    @State private var image: UIImage = UIImage(imageLiteralResourceName: "DefaultItemImage")
    @State private var name: String = ""
    @State private var count: String = ""
    @State private var sold: String = ""
    @State private var expiryDate: Date = Date()
    @State private var costPrice: String = ""
    @State private var sellingPrice: String = ""
    @State private var tagColor: Color = Color.gray
    @State private var tagColorIndex: Int = -1
    @State private var scannedCode: String = ""
    @State private var category: String = "None"
    @State private var notes: String = ""
    
    @State private var showActionSheet: Bool = false
    @State private var showEmptyFieldAlert: Bool = false
    @State private var showDuplicateBarcodeAlert: Bool = false
    @State private var showCamera: Bool = false
    @State private var showGalery: Bool = false
    @State private var tagColors: [Color] = [.orange, .green, .red, .blue, .yellow, .purple]
    @State private var tagTapped: [Bool] = [false, false, false, false, false, false]
    @State private var showBarCodeScanner = false
    @State private var itemIndex: Int = -1
    
    @State private var dateComponent = DateComponents()
    @State private var emptyFields: [String] = []
    @State private var tempString: String = ""
    
    
    let screenSize = UIScreen.main.bounds
    
    init() {
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Group {
                    Image(uiImage: image)
                        .resizable()
                        .clipped()
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 160, height: 160)
                        .overlay(
                            CameraButton(showActionSheet: $showActionSheet)
                                .offset(x: 55, y: 60)
                        )
                        .padding(.vertical)
                    VStack(alignment: .leading) {
                        Text("Name")
                            .labelStyle1()
                        TextField("", text: $name)
                            .textFieldStyle()
                    }
                    Divider()
                    VStack(alignment: .leading) {
                        Text("Barcode")
                            .labelStyle1()
                        HStack {
                            TextField("", text: $scannedCode)
                                .keyboardType(.numberPad)
                                .textFieldStyle()
                            Divider()
                            Button {
                                self.showBarCodeScanner.toggle()
                            } label: {
                                Image(systemName: "barcode.viewfinder")
                                    .resizable()
                                    .frame(width: 35,height: 28)
                            }
                            .sheet(isPresented: $showBarCodeScanner) {
                                BarcodeScanner(showBarCodeScanner: $showBarCodeScanner, scannedCode: $scannedCode, itemIndex: $itemIndex, mode: "add")
                            }
                        }
                    }
                    Divider()
                    HStack() {
                        VStack(alignment: .leading) {
                            Text("Cost Price")
                                .labelStyle1()
                                .fixedSize(horizontal: true, vertical: false)
                            TextField("", text: $costPrice)
                                .keyboardType(.decimalPad)
                                .textFieldStyle()
                        }
                        Divider()
                        VStack(alignment: .leading) {
                            Text("Sell Price")
                                .labelStyle1()
                                .fixedSize(horizontal: true, vertical: false)
                            TextField("", text: $sellingPrice)
                                .keyboardType(.decimalPad)
                                .textFieldStyle()
                        }
                    }
                    Divider()
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Count")
                                .labelStyle1()
                            TextField("", text: $count)
                                .keyboardType(.numberPad)
                                .textFieldStyle()
                        }
                        Divider()
                        VStack(alignment: .leading) {
                            Text("Sold")
                                .labelStyle1()
                            TextField("", text: $sold)
                                .keyboardType(.numberPad)
                                .textFieldStyle()
                        }
                    }
                    Divider()
                }
                Group {
                    NavigationLink(destination: CategoryView(seclectedCategory: $category)) {
                        HStack {
                            Text("Category")
                                .labelStyle1()
                            Spacer()
                            Text(category).foregroundColor(colorScheme == .light ? Color.black : Color.white)
                            Image(systemName: "chevron.forward")
                        }
                    }
                    Divider()
                    HStack {
                        Text("Expiry Date")
                            .labelStyle1()
                        DatePicker("", selection: $expiryDate, in: Calendar.current.date(byAdding: dateComponent, to: Date())!..., displayedComponents: [.date])
                    }
                    Divider()
                    HStack {
                        Text("Tag")
                            .labelStyle1()
                        Spacer()
                        ForEach(0..<tagColors.count) { index in
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(tagTapped[index] ? Color.gray : colorScheme == .light ? Color.white : Color.black, lineWidth: 3)
                                .frame(width: 25, height: 25)
                                .background(Circle().foregroundColor(tagColors[index]))
                                .padding(.leading, 5)
                                .gesture(
                                    TapGesture()
                                        .onEnded { _ in
                                            if tagTapped[index]{
                                                tagTapped[index] = false
                                            }
                                            else {
                                                unselectTags()
                                                tagTapped[index].toggle()
                                            }
                                        }
                                )
                        }
                    }
                    Divider()
                    VStack(alignment: .leading) {
                        Text("Notes")
                            .labelStyle1()
                        TextEditor(text: $notes)
                            .frame(minHeight: 80, maxHeight: 80)
                            .padding(6)
                            .background(Color(.secondarySystemBackground))
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.green, lineWidth: 0.5))
                    }
                    Spacer()
                }
            }
            .navigationTitle(Text("New Item"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: BackButton())
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        emptyFields.removeAll()
                        tempString = ""
                        
                        validateFields()
                                                
                        if emptyFields.count != 0 {
                            if emptyFields.count > 1
                            {
                                for i in 0..<emptyFields.count - 1 {
                                    tempString += emptyFields[i]
                                    if i != emptyFields.count - 2 {
                                        tempString += ","
                                    }
                                }
                                tempString += " and "
                                tempString += emptyFields[emptyFields.count - 1]
                            }
                            else if emptyFields.count == 1
                            {
                                tempString += emptyFields[0]
                            }
                            showEmptyFieldAlert.toggle()
                        }
                        
                        else {
                            if validateBarcode(){
                                saveItem()
                            }
                            else{
                                showDuplicateBarcodeAlert.toggle()
                            }
                        }
                    } label: {
                        Text("Add")
                            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                            .background(Color.green)
                            .foregroundColor(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .fixedSize(horizontal: true, vertical: false)
                            .font(.system(size: 16, weight: .bold))
                    }
                    .alert(isPresented: $showEmptyFieldAlert) {
                        Alert(title: Text("\(tempString) cannot be empty."), dismissButton: .default(Text("OK")))
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button {
                        hideKeyboard()
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                }
            }
            .actionSheet(isPresented: $showActionSheet, content: { () -> ActionSheet in
                ActionSheet(title: Text(verbatim: "Select an image for your item"), buttons: [
                    ActionSheet.Button.default(Text("Take Photo"), action: {
                        self.showCamera.toggle()
                    }),
                    ActionSheet.Button.default(Text("Choose Photo"), action: {
                        self.showGalery.toggle()
                    }),
                    ActionSheet.Button.cancel()
                ])
            })
            .padding(.horizontal, 30)
            .sheet(isPresented: $showCamera) {
                ImagePickerController(selectedImage: self.$image, sourceType: .camera)
            }
            .sheet(isPresented: $showGalery) {
                ImagePickerController(selectedImage: self.$image, sourceType: .photoLibrary)
            }
            .onAppear {
                dateComponent.day = 2
            }
            .alert(isPresented: $showDuplicateBarcodeAlert) {
                Alert(title: Text("Barcode \"\(scannedCode)\" is already assigned to an item."), dismissButton: .default(Text("OK")))
            }
        }
        .accentColor(.green)
    }

    
    private func validateFields() {
        if name == "" {
            emptyFields.append("Name")
        }
        if costPrice == "" {
            emptyFields.append("Cost Price")
        }
        if sellingPrice == "" {
            emptyFields.append("Sell Price")
        }
        if count == "" {
            emptyFields.append("Count")
        }
    }
    
    
    private func validateBarcode() -> Bool
    {
        var result: Bool = true
        if scannedCode != "" {
            for item in items {
                if item.barCode == scannedCode {
                    result = false
                    break
                }
            }
        }
        return result
    }
    
    
    private func saveItem() {
        
        guard let imageData = image.pngData() else {
            print("The UIImage could not be converted !")
            return
        }
        
        tagColorIndex = findSelectedTag()
        
        let item = Item(imageData, name, Int(count) ?? 0, Int(sold) ?? 0, expiryDate, Double(costPrice) ?? 0.0, Double(sellingPrice) ?? 0.0, tagColorIndex, scannedCode, category, notes)
        let cdItem = ItemCoreData(context: self.moc)
        
        cdItem.image = item.image
        cdItem.id = item.id
        cdItem.name = item.name
        cdItem.count = Int64(item.count)
        cdItem.sold = Int64(item.sold)
        cdItem.addedOnDate = item.addedOnDate
        cdItem.updatedOnDate = item.updatedOnDate
        cdItem.expiryDate = item.expiryDate
        cdItem.costPrice = item.costPrice
        cdItem.sellingPrice = item.sellingPrice
        cdItem.profit = item.profit
        cdItem.tagColorIndex = Int64(item.tagColorIndex)
        cdItem.barCode = item.barCode
        cdItem.category = item.category
        cdItem.notes = item.notes
        
        do {
          try self.moc.save()
        } catch {
            print("Error while saving item!")
            self.moc.rollback()
            print("Rolled back!")
        }
        
        self.presentation.wrappedValue.dismiss()
    }
    
    private func unselectTags() {
        for index in 0..<tagTapped.count {
            tagTapped[index] = false
        }
    }
    
    private func findSelectedTag() -> Int {
        var index: Int = -1
        for i in 0..<tagTapped.count {
            if tagTapped[i] {
                index = i
            }
        }
        return index
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


extension View {
    func labelStyle1() -> some View {
        self.foregroundColor(.gray)
            .font(.system(size: 15, weight: .semibold))
    }
    
    func textFieldStyle() -> some View {
        self.disableAutocorrection(true)
            .font(.system(size: 22, weight: .semibold))
            .frame(height: 30.0)
            .padding(6)
            .background(Color(.secondarySystemBackground))
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.green, lineWidth: 0.5))
    }
}


struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView()
    }
}
