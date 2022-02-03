//
//  BarCodeScanner.swift
//  Ventori
//
//  Created by Proyash Saha on 2021-10-26.
//

import SwiftUI
import AVFoundation

struct BarcodeScanner: View {
    
    @FetchRequest(entity: ItemCoreData.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \ItemCoreData.addedOnDate, ascending: false)]) var items: FetchedResults<ItemCoreData>
    
    @Binding var showBarCodeScanner: Bool
    @Binding var scannedCode: String
    @Binding var itemIndex: Int
    @State var mode: String
    
    @State private var flashLightOn: Bool = false
    @State private var showAlert: Bool = false
    @State private var itemFound: Bool = false
    @State private var index: Int = 0
    @State private var alertCode: String = ""
    
    var body: some View {
        VStack {
            BarCodeScannerController(
                codeTypes: [.qr, .ean8, .ean13, .upce, .aztec],
                scanMode: .continuous,
                completion: { result in
                    if mode == "add" {
                        if case let .success(code) = result {
                            scannedCode = code
                            self.showBarCodeScanner.toggle()
                        }
                    }
                    else if mode == "search" {
                        if case let .success(code) = result {
                            while index < items.count  && !itemFound {
                                if items[index].barCode! == code {
                                    scannedCode = code
                                    itemIndex = index
                                    itemFound = true
                                }
                                index += 1
                            }
                            if itemFound {
                                self.showBarCodeScanner.toggle()
                                itemFound = false
                                index = 0
                            }
                            else {
                                alertCode = code
                                showAlert.toggle()
                                index = 0
                            }
                        }
                    }
                }
            )
            .overlay(
                VStack {
                    Spacer()
                    Image(systemName: "barcode.viewfinder")
                        .resizable()
                        .frame(width: 300,height: 200)
                        .font(.system(size: 16, weight: .thin))
                        .foregroundColor(Color.white)
                        .opacity(0.5)
                        .offset(x: 0, y: 40)
                    Spacer()
                    HStack {
                        Button {
                            self.showBarCodeScanner.toggle()
                        } label: {
                            Text("Cancel")
                                .buttonStyle()
                                .fixedSize(horizontal: true, vertical: false)
                                .font(.system(size: 16, weight: .bold))
                        }
                        Spacer()
                        Button {
                            self.flashLightOn.toggle()
                            toggleTorch(on: self.flashLightOn)
                        } label: {
                            Image(systemName: flashLightOn ? "bolt.slash.fill" : "bolt.fill")
                                .buttonStyle()
                        }
                    }
                    .padding(.vertical, 30)
                    .padding(.horizontal, 20)
                }
            )
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Item could not be found!"), message: Text("Scanned Code:\n\(alertCode)"), dismissButton: .default(Text("Dismiss")))
        }
        .interactiveDismissDisabled(true)
        .ignoresSafeArea()
    }
    
    
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }

        if device.hasTorch {
            do {
                try device.lockForConfiguration()

                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }

                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
}


extension View {
    func buttonStyle() -> some View {
        self.frame(width: 70, height: 20)
            .padding(10)
            .background(Color.green)
            .foregroundColor(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}


struct BarcodeScanner_Previews: PreviewProvider {
    static var previews: some View {
        BarcodeScanner(showBarCodeScanner: .constant(true), scannedCode: .constant(""), itemIndex: .constant(-1), mode: "")
    }
}
