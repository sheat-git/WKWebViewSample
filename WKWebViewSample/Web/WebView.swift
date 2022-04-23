//
//  WebView.swift
//  WKWebViewSample
//
//  Created by sheat on 2022/04/16.
//

import SwiftUI

struct WebView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var action: WebViewControllerWrapper.Action? = nil
    @State private var canGoBack: Bool = false
    @State private var canGoForward: Bool = false
    @State private var isLoading: Bool = true
    @State private var estimatedProgress: Double = 0
    @State private var url: URL? = nil
    @State private var isBarHidden: Bool = false
    @State private var toolBarHeight: CGFloat = 0
    @State private var bottomSafeAreaInset: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            WebViewControllerWrapper(
                action: $action,
                canGoBack: $canGoBack,
                canGoForward: $canGoForward,
                isLoading: $isLoading,
                estimatedProgress: $estimatedProgress,
                url: $url,
                isBarHidden: $isBarHidden,
                toolBarHeight: $toolBarHeight,
                bottomSafeAreaInset: $bottomSafeAreaInset
            )
            .overlay(
                GeometryReader { geometry in
                    Rectangle()
                        .foregroundColor(.accentColor)
                        .frame(
                            width: geometry.size.width * estimatedProgress,
                            height: 2,
                            alignment: .topLeading
                        )
                        .opacity(isLoading ? 1 : 0)
                }
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if canGoBack {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Image(systemName: "chevron.backward")
                                .font(Font.body.weight(.semibold))
                        })
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isLoading {
                        Button(action: {
                            action = .stopLoading
                        }, label: {
                            Image(systemName: "xmark")
                        })
                    } else {
                        Button(action: {
                            action = .reload
                        }, label: {
                            Image(systemName: "arrow.clockwise")
                        })
                    }
                }
            }
            .zIndex(0)
            
            if !isBarHidden {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        Divider()
                        Spacer()
                        HStack {
                            Button(action: {
                                action = .goBack
                            }, label: {
                                Image(systemName: "chevron.backward")
                            })
                            .disabled(!canGoBack)
                            Spacer()
                            Button(action: {
                                action = .goForward
                            }, label: {
                                Image(systemName: "chevron.forward")
                            })
                            .disabled(!canGoForward)
                            Spacer()
                            Button(action: {
                                action = .share
                            }, label: {
                                Image(systemName: "square.and.arrow.up")
                            })
                            .disabled(url == nil)
                            Spacer()
                            Button(action: {
                                action = .openSafari
                            }, label: {
                                Image(systemName: "safari")
                            })
                            .disabled(url == nil)
                        }
                        .imageScale(.large)
                        .padding([.horizontal])
                        Spacer()
                    }
                    .frame(height: toolBarHeight)
                    Spacer()
                        .frame(height: bottomSafeAreaInset)
                }
                .background(.regularMaterial)
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
