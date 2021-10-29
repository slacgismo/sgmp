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
                VStack(alignment: .leading) {
                    Text("Device ID")
                        .font(.footnote.smallCaps())
                        .foregroundColor(.init(UIColor.secondaryLabel))
                    Text("\(device.device_id)")
                        .font(.subheadline)
                }
                VStack(alignment: .leading) {
                    Text("Description")
                        .font(.footnote.smallCaps())
                        .foregroundColor(.init(UIColor.secondaryLabel))
                    Text("\(deviceDetail?.description ?? device.description)")
                        .font(.subheadline)
                }
                VStack(alignment: .leading) {
                    Text("Type")
                        .font(.footnote.smallCaps())
                        .foregroundColor(.init(UIColor.secondaryLabel))
                    Text("\(deviceDetail?.type ?? device.type)")
                        .font(.subheadline)
                }
            } header: {
                Text("Info")
            }
            
            if loadingDeviceDetail {
                ProgressView().progressViewStyle(CircularProgressViewStyle())
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if let deviceDetail = deviceDetail {
                switch deviceDetail.type {
                case "sonnen":
                    DeviceConfigSonnenView(device: device, detail: deviceDetail)
                case "powerflex":
                    DeviceConfigPowerflexView(device: device, detail: deviceDetail)
                case "egauge":
                    DeviceConfigEgaugeView(device: device, detail: deviceDetail)
                default:
                    DeviceConfigDefaultView(device: device, detail: deviceDetail)
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
