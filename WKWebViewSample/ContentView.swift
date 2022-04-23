//
//  ContentView.swift
//  WKWebViewSample
//
//  Created by sheat on 2022/04/16.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            NavigationLink("go web", destination: {
                VStack(spacing: 0) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.red)
                            .frame(height: 50)
                        Text("Some Banner")
                    }
                    WebView()
                }
            })
        }
        .navigationViewStyle(.stack)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
