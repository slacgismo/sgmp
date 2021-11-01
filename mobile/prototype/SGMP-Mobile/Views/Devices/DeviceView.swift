//
//  DeviceView.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/14/21.
//

import SwiftUI

struct DeviceView: View {
    var device : Device
    @State var deviceDetail : DeviceDetail?
    @State var loadingDeviceDetail : Bool = false
    
    func loadDetail() {
        self.loadingDeviceDetail = true
        NetworkManager.shared.getDeviceDetail(deviceId: device.device_id) { detail, err in
            if let detail = detail {
                deviceDetail = detail
            } else if let err = err {
                print(err)
            }
            self.loadingDeviceDetail = false
        }
    }
    
    var body: some View {
        List {
            Section {
                TitleDescCellView(title: "Device ID", content: "\(device.device_id)")
                if let deviceDetail = deviceDetail {
                    TitleDescCellView(title: "House ID", content: "\(deviceDetail.house_id)")
                }
                TitleDescCellView(title: "Description", content: "\(deviceDetail?.description ?? device.description)")
                TitleDescCellView(title: "Type", content: "\(deviceDetail?.type ?? device.type)")
            } header: {
                Text("Info")
            }
            
            if loadingDeviceDetail {
                ProgressView().progressViewStyle(CircularProgressViewStyle())
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if let deviceDetail = deviceDetail {
                switch deviceDetail.type {
                case "sonnen":
                    DeviceConfigSonnenView(detail: deviceDetail)
                case "powerflex":
                    DeviceConfigPowerflexView(detail: deviceDetail)
                case "egauge":
                    DeviceConfigEgaugeView(detail: deviceDetail)
                default:
                    DeviceConfigDefaultView(detail: deviceDetail)
                }
            } else {
                Button("Load Config") {
                    loadDetail()
                }
            }
        }
        .onAppear(perform: {
            loadDetail()
        })
        .refreshable {
            loadDetail()
        }
        .navigationTitle("\(deviceDetail?.name ?? device.name)")
        .animation(.easeInOut)
    }
}

struct DeviceView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceView(device: Device(device_id: 1, name: "Sonnon", description: "Test", type: "sonnon"))
    }
}
