//
//  DeviceSelectionCell.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/28/21.
//

import SwiftUI
import Defaults

struct DeviceSelectionCell: View {
    @Namespace private var animation
    @State var device : Device
    @State var showId : Bool = true
    @State var showIcon : Bool = false
    @Default(.showIconInDeviceList) var defaultShowIcon
    
    var body: some View {
        NavigationLink {
            DeviceView(device: device)
        } label: {
            HStack {
                VStack(alignment: .center, spacing: 8) {
                    if showIcon || defaultShowIcon {
                        Image(systemName: device.sfSymbolName)
                    }
                    if showId {
                        Text("\(device.device_id)")
                            .font(.caption.monospaced())
                    }
                }.frame(width: (showIcon || defaultShowIcon || showId) ? 32 : 0, alignment: .center)
                
                VStack(alignment: .leading) {
                    Text("\(device.description)")
                        .font(.headline.bold())
                    Text("\(device.type)")
                        .font(.footnote.monospaced())
                        .foregroundColor(.init(UIColor.tertiaryLabel))
                }
                Spacer()
                Text("\(device.name)")
                    .font(.caption)
                    .foregroundColor(.init(UIColor.secondaryLabel))
            }
            .matchedGeometryEffect(id: "device.select.\(device.device_id)", in: animation)
            .contextMenu {
                Label {
                    Text("\(device.name)")
                } icon: {
                    Image(systemName: device.sfSymbolName)
                }
                Divider()
                Button {
                    
                } label: {
                    Label {
                        Text("Share QR code")
                    } icon: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }

            }
            .animation(.easeInOut)
        }
    }
}

struct DeviceSelectionCell_Previews: PreviewProvider {
    static var previews: some View {
//        DeviceSelectionCell()
        ZStack {}
    }
}
