//
//  ExpandableView.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/14/21.
//

import SwiftUI

struct ExpandableView<Content1: View, Content2: View>: View {
    
    @ViewBuilder var title: () -> Content1
    @ViewBuilder var expandable: () -> Content2
    
    @State var expanded = false
    
    var body: some View {
        Group {
            HStack {
                title()
                Spacer()
                ZStack {
                    Image(systemName: "chevron.compact.right")
                        .rotationEffect(expanded ? .degrees(90) : .degrees(0))
                }.aspectRatio(1, contentMode: .fit)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                expanded.toggle()
            }
            if expanded {
                expandable()
            }
        }.animation(.easeInOut)
    }
}

struct ExpandableView_Previews: PreviewProvider {
    static var previews: some View {
//        ExpandableView()
        ZStack {}
    }
}
