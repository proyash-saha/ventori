//
//  HomeView.swift
//  Ventori
//
//  Created by Proyash Saha on 2021-10-26.
//

import SwiftUI

struct HomeView: View {
    
    @Environment(\.presentationMode) var presentation
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var moc

    @FetchRequest(entity: ItemCoreData.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \ItemCoreData.addedOnDate, ascending: false)]) var items: FetchedResults<ItemCoreData>
    
    @State private var toBeDeleted: IndexSet = []
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        TabView {
            NavigationView {
                ZStack {
                    List {
                        ForEach(items) { item in
                            NavigationLink(destination: DetailView(item: item, tag: "main", indexOfItem: items.firstIndex(of: item) ?? -1)) {
                                ItemListRow(item: item)
                            }
                            .alert(isPresented: self.$showDeleteAlert) {
                                Alert(title: Text("Do you want to delete this Item?"),
                                      primaryButton: .destructive(Text("Delete")) {
                                        for index in self.toBeDeleted {
                                            let item = items[index]
                                            self.moc.delete(item)
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
                        }
                        .onDelete(perform: deleteItem)
                    }
                    //.listStyle(PlainListStyle())
                    .navigationTitle(Text("Ventori"))
                    .environment(\.defaultMinListRowHeight, 60)
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gearshape")
                                    .font(Font.system(size: 20, weight: .semibold))
                            }
                        }
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            NavigationLink(destination: AddUpdateView(purpose: "Add", indexOfItem: -1)) {
                                Image(systemName: "plus")
                                    .font(Font.system(size: 23, weight: .semibold))
                            }
                        }
                    }
                    
                    if items.count == 0 {
                        Image("EmptyList")
                            .resizable()
                            .frame(width: 450.0,height: 450.0)
                    }
                }
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            
            NavigationView {
                SearchView()
            }
            .tabItem {
                Image(systemName: "magnifyingglass.circle")
                Text("Search")
            }
            
            NavigationView {
                StatView()
            }
            .tabItem {
                Image(systemName: "chart.pie")
                Text("Stats")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(Theme.mainColor)
    }
    
    
    private func deleteItem(at indexSet: IndexSet) {
        self.toBeDeleted = indexSet
        self.showDeleteAlert = true
    }
}


extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
