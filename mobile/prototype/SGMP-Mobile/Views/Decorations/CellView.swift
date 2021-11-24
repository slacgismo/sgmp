//
//  CellView.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/31/21.
//

import SwiftUI

struct TitleDescCellView : View {
    var title : String?
    var content : String?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(title ?? "-")")
                .font(.footnote.smallCaps())
                .foregroundColor(.init(UIColor.secondaryLabel))
            Text("\(content ?? "-")")
                .font(.subheadline.monospaced())
        }
    }
}
