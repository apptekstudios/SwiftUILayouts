//
//  ContentView.swift
//  SwiftUILayouts
//
//  Created by T Brennan on 11/6/2022.
//

import SwiftUI
import SwiftUILayouts

struct DemoItem: Identifiable, Equatable {
    var imageName: String
    var id = UUID()
}

struct WaterfallTestView: View {
    @State var testContent: [DemoItem] = (0...7).map { DemoItem(imageName: "demo\($0)") }  // (0...10).flatMap { _ in (existing) }
    @State var columns: Int = 3
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                AnyLayout(VerticalWaterfallLayout(columns: columns)) {
                    ForEach(testContent) { item in
                        Image(item.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                }.padding(.horizontal, 10)
                Divider()
            }
            .animation(.default, value: columns)
            .animation(.default, value: testContent)
            
        }
        .safeAreaInset(edge: .top) {
            HStack {
                Stepper("Columns", value: $columns, in: 1...5)
                Spacer()
                Button("Shuffle") {
                    testContent.shuffle()
                }
            }.padding().background(.thinMaterial)
        }
        .navigationTitle("Waterfall")
    }
}

struct WaterfallTestView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WaterfallTestView()
        }
        
    }
}
