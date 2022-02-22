//
//  VentoriApp.swift
//  Ventori
//
//  Created by Proyash Saha on 2021-10-26.
//

import SwiftUI

@main
struct VentoriApp: App {
    
    @Environment(\.scenePhase) var scenePhase
    
    let persistenceController = PersistenceController.shared
    
    init() {
        UIView.appearance().tintColor = UIColor(Theme.mainColor)
        UITextView.appearance().backgroundColor = .clear
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
                }
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
}

extension Color {
  init(_ hex: UInt, alpha: Double = 1) {
    self.init(
      .sRGB,
      red: Double((hex >> 16) & 0xFF) / 255,
      green: Double((hex >> 8) & 0xFF) / 255,
      blue: Double(hex & 0xFF) / 255,
      opacity: alpha
    )
  }
}
