//
//  DeviceManager.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/12/21.
//

import Foundation

class DeviceManager : BaseManager {
    static let instance = DeviceManager()
    
    override class var shared : DeviceManager {
        return instance
    }
    
    // MARK: - Device Detail
    func getDeviceDetail(deviceId : Int64, callback: @escaping ((DeviceDetail?, Error?) -> Void)) -> Void {
        var request = URLRequest(url: SgmpHostUrl.appendingPathComponent("api/device/details"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        do {
            request.httpBody = try JSONEncoder().encode(DeviceDetailRequest(device_id: deviceId))
        } catch (let err) {
            callback(nil, err)
            return
        }
        URLSession.shared.dataTask(with: request) { data, response, err in
            if let err = err {
                callback(nil, err)
            } else if let data = data {
                do {
                    let deviceDetailResponse = try JSONDecoder().decode(DeviceDetailResponse.self, from: data)
                    let detail = deviceDetailResponse.device
                    callback(detail ?? nil, nil)
                } catch (let err) {
                    callback(nil, err)
                }
            }
        }.resume()
    }
}
