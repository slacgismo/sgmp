//
//  CardGroupBoxStyle.swift
//  Dynamic
//
//  Created by Fincher on 12/9/20.
//

import Foundation
import SwiftUI

struct ListCardGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            configuration.content
        }
        .frame(idealWidth: .infinity, maxWidth: .infinity)
        .padding(.vertical)
        .background(Color.init(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
