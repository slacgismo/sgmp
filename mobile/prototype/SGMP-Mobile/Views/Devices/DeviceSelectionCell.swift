//
//  DeviceSelectionCell.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/28/21.
//

import SwiftUI

struct DeviceSelectionCell: View {
    @State var device : Device
    @State var showId : Bool = true
    
    var body: some View {
        NavigationLink {
            DeviceView(device: device)
        } label: {
            HStack {
                Text("\(device.device_id)")
                    .font(.caption.monospaced())
                VStack(alignment: .leading) {
                    Text("\(device.name)")
                        .font(.headline.bold())
                    Text("\(device.type)")
                        .font(.footnote)
                        .foregroundColor(.init(UIColor.tertiaryLabel))
                }
                Spacer()
                Text("\(device.description)")
                    .font(.caption)
                    .foregroundColor(.init(UIColor.secondaryLabel))
            }
        }
    }
}

struct DeviceSelectionCell_Previews: PreviewProvider {
    static var previews: some View {
//        DeviceSelectionCell()
        ZStack {}
    }
}
