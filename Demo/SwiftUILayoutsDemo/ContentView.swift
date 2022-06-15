//
//  ContentView.swift
//  SwiftUILayouts
//
//  Created by T Brennan on 11/6/2022.
//

import SwiftUI

struct ContentView: View {
    
    @State var currentLayout: LayoutType?
    @State var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(LayoutType.allCases, selection: $currentLayout) { layout in
                Text(layout.title)
            }
            .navigationTitle("Layout Demos")
        } detail: {
            NavigationStack {
                DetailView(layoutType: currentLayout)
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

enum LayoutType: String, Identifiable, CaseIterable {
    case flow
    case waterfall
    
    var id: Self { self }
    var title: String {
        switch self {
        case .flow: return "Flow Layout"
        case .waterfall: return "Waterfall Layout"
        }
    }
}

struct DetailView: View {
    var layoutType: LayoutType?
    var body: some View {
        switch layoutType {
        case .none: Text("Select a layout from the sidebar.")
        case .flow: FlowTestView()
        case .waterfall: WaterfallTestView()
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
