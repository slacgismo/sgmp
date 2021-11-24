//
//  DeviceFormulaView.swift
//  SGMP-Mobile
//
//  Created by fincher on 11/8/21.
//

import SwiftUI

struct DeviceFormulaView: View {
    
    @State var device : DeviceDetail
    @State var formula : String
    
    var body: some View {
        List {
            DeviceFormulaAnalyticsView(device: device, formula: formula)
        }
        .animation(.easeInOut)
        .navigationTitle(formula)
    }
}
