//
//  ContentView.swift
//  ShaderSample
//
//  Created by yotahara on 2024/06/27.
//

import SwiftUI

struct ContentView: View {
    @State private var topRed: Float = 1.0
    @State private var topGreen: Float = 0.0
    @State private var topBlue: Float = 0.0
    @State private var leftRed: Float = 0.0
    @State private var leftGreen: Float = 1.0
    @State private var leftBlue: Float = 0.0
    @State private var rightRed: Float = 0.0
    @State private var rightGreen: Float = 0.0
    @State private var rightBlue: Float = 1.0
    
    @State private var isOpenTop: Bool = false
    @State private var isOpenLeft: Bool = false
    @State private var isOpenRight: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            TriangleRGBMetalView(topRed: $topRed,
                                 topGreen: $topGreen,
                                 topBlue: $topBlue,
                                 leftRed: $leftRed,
                                 leftGreen: $leftGreen,
                                 leftBlue: $leftBlue,
                                 rightRed: $rightRed,
                                 rightGreen: $rightGreen,
                                 rightBlue: $rightBlue)
            .frame(height: UIScreen.main.bounds.width)
            .edgesIgnoringSafeArea(.top)
            
            ScrollView {
                VStack(spacing: 0) {
                    FoldableSection(isOpen: $isOpenTop, title: "Top RGB") {
                        RGBSlider($topRed, title: "R")
                        RGBSlider($topGreen, title: "G")
                        RGBSlider($topBlue, title: "B")
                    }
                    FoldableSection(isOpen: $isOpenLeft, title: "Bottom Left RGB") {
                        RGBSlider($leftRed, title: "R")
                        RGBSlider($leftGreen, title: "G")
                        RGBSlider($leftBlue, title: "B")
                    }
                    FoldableSection(isOpen: $isOpenRight, title: "Bottom Right RGB") {
                        RGBSlider($rightRed, title: "R")
                        RGBSlider($rightGreen, title: "G")
                        RGBSlider($rightBlue, title: "B")
                    }
                }
                .padding(.bottom, 24)
            }
            
            Spacer()
        }
        .ignoresSafeArea()
    }
    
    private func FoldableSection<Content: View>(isOpen: Binding<Bool>, title: String, @ViewBuilder content:  @escaping () -> Content) -> some View {
        VStack(spacing: 0) {
            VStack {
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image(systemName: isOpen.wrappedValue ? "chevron.down" : "chevron.right")
                }
                .padding()
                .background(Color(.systemGray4))
                .onTapGesture {
                    isOpen.wrappedValue.toggle()
                }
                
                if isOpen.wrappedValue {
                    VStack {
                        content()
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private func RGBSlider(_ value: Binding<Float>, title: String) -> some View {
        HStack {
            Text(title)
                .font(.callout)
            Text(String(format: "%.f", 255 * value.wrappedValue))
                .font(.callout)
            Slider(value: value, in: 0.0...1.0, step: 0.01)
                .padding(.horizontal)
        }
    }
}

#Preview {
    ContentView()
}
