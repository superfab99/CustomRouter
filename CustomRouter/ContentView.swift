//
//  ContentView.swift
//  CustomRouter
//
//  Created by Suyog Sawant on 27/08/25.
//

import SwiftUI

struct AnyDestination: Hashable {
    
    let id = UUID().uuidString
    var destination: AnyView
    
    init<T: View>(destination: T) {
        self.destination = AnyView(destination)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AnyDestination, rhs: AnyDestination) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

extension Binding where Value == Bool {
    init<T: Sendable>(ifNotNil value: Binding<T?>) {
        self.init {
            value.wrappedValue != nil
        } set: { newValue in
            if !newValue {
                value.wrappedValue = nil
            }
        }
    }
}

enum SegueOption {
    case push, sheet, fullSheet
}

extension EnvironmentValues {
    @Entry var router: Router = MockRouter()
}

struct MockRouter: Router {
    func presentScreen<T>(destination: T) where T : View {
        print("Mock methods are not implemented")
    }
    
    func presentScreen<T: View>(_ option: SegueOption, @ViewBuilder destination: @escaping (Router) -> T) {
        print("Mock methods are not implemented")
    }
    
    func pop() {
        print("Mock methods are not implemented")
    }
}

protocol Router {
    func presentScreen<T: View>(destination: T)
    func presentScreen<T: View>(_ option: SegueOption, @ViewBuilder destination: @escaping (Router) -> T)
    func pop()
}

struct RouterView<Content: View>: View, Router {
    @Environment(\.dismiss) private var dismiss
    
    var addNavigationView: Bool
    @Binding var screenStack: [AnyDestination]
    @State private var path: [AnyDestination] = []

    @State private var sheetScreen: AnyDestination? = nil
    @State private var fullSheetScreen: AnyDestination? = nil
    
    @ViewBuilder var content: (Router) -> Content
    
    init(
        addNavigationView: Bool = true,
        screenStack: (Binding<[AnyDestination]>)? = nil,
        content: @escaping (Router) -> Content
    ) {
        self.addNavigationView = addNavigationView
        self._screenStack = screenStack ?? .constant([])
        self.content = content
    }
    
    var body: some View {
        NavigationStackIfNeeded(path: $path, addNavigationView: addNavigationView) {
            content(self)
                .sheet(
                    isPresented: Binding(ifNotNil: $sheetScreen)) {
                        ZStack {
                            if let sheetScreen {
                                sheetScreen.destination
                            }
                        }
                    }
                    .fullScreenCover(isPresented: Binding(ifNotNil: $fullSheetScreen)) {
                        ZStack {
                            if let fullSheetScreen {
                                fullSheetScreen.destination
                            }
                        }
                    }
        }
        .environment(\.router, self)
    }
    
    // this method will not work for pop logic as we are not exposing router like below method
    func presentScreen<T: View>(destination: T) {
        let screen = RouterView<T>(addNavigationView: false, screenStack: $path) { router in
            destination
        }
        
        path.append(AnyDestination(destination: screen))
    }
    
    func presentScreen<T: View>(_ option: SegueOption, @ViewBuilder destination: @escaping (Router) -> T) {
        let screen = RouterView<T>(
            addNavigationView: false,
            screenStack: screenStack.isEmpty ? $path : $screenStack
        ) { router in
            destination(router)
        }
        
        let destination = AnyDestination(destination: screen)
        
        switch option {
        case .push:
            if screenStack.isEmpty {
                path.append(destination)
            }
            else {
                screenStack.append(destination)
            }
        case .sheet:
            sheetScreen = destination
        case .fullSheet:
            fullSheetScreen = destination
        }
    }
    
    func pop() {
        dismiss()
    }
}

struct ContentView: View {
    var body: some View {
        RouterView { router in
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, HomeView")
                Button("Go to Profile") {
                    router.presentScreen(.push) { _ in
                        ProfileView()
                    }
                }
            }
        }
    }
}

struct NavigationStackIfNeeded<Content: View>: View {
    @Binding var path : [AnyDestination]
    var addNavigationView: Bool = true
    @ViewBuilder var content: Content
    
    var body: some View {
        if addNavigationView{
            NavigationStack(path: $path){
                content
                    .navigationDestination(for: AnyDestination.self) { value in
                        value.destination
                    }
            }
        } else {
            content
        }
    }
}

struct ProfileView: View {
    @Environment(\.router) var router
    
    var body: some View {
        VStack {
            Image(systemName: "person.bust")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, Profile View")
            
            Spacer().frame(height: 20)
            Button("Go to Settings") {
                router.presentScreen(.sheet) { _ in
                    SettingsView()
                }
            }
        }
        .padding()
    }
}

struct SettingsView: View {
    @Environment(\.router) var router
    
    var body: some View {
        VStack {
            Image(systemName: "questionmark.text.page.rtl")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, Settings View")
            Button("Dismiss Settings") {
                router.pop()
            }
            
            Spacer().frame(height: 20)
            Button("Go to Accounts") {
                router.presentScreen(.fullSheet) { _ in
                    AccountsView()
                }
            }
        }
        .padding()
    }
}

struct AccountsView: View {
    @Environment(\.router) var router
    var body: some View {
        VStack {
            Image(systemName: "graduationcap")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, Accounts View")
            
            Spacer().frame(height: 20)
            Button("Dismiss Settings") {
                router.pop()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
