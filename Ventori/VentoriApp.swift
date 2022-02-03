//
//  VentoriApp.swift
//  Ventori
//
//  Created by Proyash Saha on 2021-10-26.
//

import SwiftUI

@main
struct InventoriApp: App {
    
    @Environment(\.scenePhase) var scenePhase
    
    let persistenceController = PersistenceController.shared
    
    init() {
        UIView.appearance().tintColor = UIColor(Color.green)
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