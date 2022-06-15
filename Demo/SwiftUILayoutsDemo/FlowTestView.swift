//
//  ContentView.swift
//  SwiftUILayouts
//
//  Created by T Brennan on 11/6/2022.
//

import SwiftUI
import SwiftUILayouts

struct FlowTestView: View {
    @State var testContent = ["Hello World", "Custom layouts in SwiftUI wow!", "This is a very long string that takes up multiple lines in portrait mode", "String with\nline break", "Short text"]
    @State var horizontalAlignment: HorizontalAlignment = .leading
    @State var verticalAlignment: VerticalAlignment = .top
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                AnyLayout(FlowLayout(alignment:.init(horizontal: horizontalAlignment, vertical: verticalAlignment))) {
                    ForEach(testContent, id: \.self) { i in
                        Text(i)
                            .padding(6)
                            .frame(maxHeight: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                            )
                    }
                }.padding(10)
                Divider()
            }
            .animation(.default, value: horizontalAlignment)
            .animation(.default, value: verticalAlignment)
            .animation(.default, value: testContent)
        }
        .safeAreaInset(edge: .top) {
            HStack {
                picker.pickerStyle(.menu)
                Spacer()
                Button("Shuffle") {
                    testContent.shuffle()
                }
            }.padding().background(.thinMaterial)
        }
        .navigationTitle("Flow Layout")
    }
    var picker: some View {
        Picker("Alignment", selection: $horizontalAlignment) {
            Text("Leading").tag(HorizontalAlignment.leading)
            Text("Center").tag(HorizontalAlignment.center)
            Text("Trailing").tag(HorizontalAlignment.trailing)
        }.pickerStyle(.segmented)
    }
}

extension HorizontalAlignment: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: self))
    }
}


struct FlowTestView_Previews: PreviewProvider {
    static var previews: some View {
        FlowTestView()
    }
}
