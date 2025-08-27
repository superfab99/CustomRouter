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

protocol Router {
    func presentScreen<T: View>(destination: T)
    func presentScreen<T: View>(destination: () -> T)
}

struct RouterView<Content: View>: View, Router {
    @State private var path: [AnyDestination] = []
    @ViewBuilder var content: (Router) -> Content
    
    var body: some View {
        NavigationStack(path: $path){
            content(self)
                .navigationDestination(for: AnyDestination.self) { value in
                    value.destination
                }
        }
    }
    
    func presentScreen<T: View>(destination: T) {
        path.append(AnyDestination(destination: destination))
    }
    
    func presentScreen<T: View>(destination: () -> T) {
        path.append(AnyDestination(destination: destination()))
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
                    router.presentScreen(destination: Text("hello world"))
                }
            }
        }
    }
}

struct ProfileView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, ProfileView")
        }
        .padding()
    }
}


#Preview {
    ContentView()
}
