//
//  ContentView.swift
//  MSh
//
//  Created by Maximilian Schwenger on 04.03.23.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Image(systemName: "house")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                    .font(.largeTitle)
                    .padding(.bottom)
                Text("Welcome to your")
                Text("Smart Home")
                    .font(.largeTitle)
                    .padding(.bottom)
                NavigationLink(destination: HomeView()) {
                    Label("Start", systemImage: "play.fill")
                }
                Spacer()
                Text("Brought to you by")
                    .font(.caption2)
                Text("Schwenger Inc.")
                    .font(.callout)
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
