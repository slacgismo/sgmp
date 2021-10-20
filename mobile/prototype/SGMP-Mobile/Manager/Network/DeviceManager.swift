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
    
    // MARK: - Device
    func getDevices(houseId : Int64, callback : (@escaping ([Device]?, Error?) -> Void)) -> Void {
        var request = URLRequest(url: SgmpHostUrl.appendingPathComponent("api/device/list"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        do {
            request.httpBody = try JSONEncoder().encode(ListDevicesRequest(house_id: houseId))
        } catch (let err) {
            callback(nil, err)
            return
        }
        URLSession.shared.dataTask(with: request) { data, response, err in
            if let err = err {
                callback(nil, err)
            } else if let data = data {
                do {
                    let listDeviceReponse = try JSONDecoder().decode(ListDevicesResponse.self, from: data)
                    let devices = listDeviceReponse.devices
                    callback(devices ?? nil, nil)
                } catch (let err) {
                    callback(nil, err)
                }
            }
        }.resume()
    }
    
    // deprecated, fall back only
    func getDevices(callback : (@escaping ([Device], Error?) -> Void)) -> Void {
        URLSession.shared.dataTask(with: SgmpHostUrl.appendingPathComponent("api/device/list")) { data, response, err in
            if let err = err {
                callback([], err)
            } else if let data = data {
                do {
                    let listDeviceResponse = try JSONDecoder().decode(ListDevicesResponse.self, from: data)
                    let devices = listDeviceResponse.devices
                    callback(devices ?? [], nil)
                } catch (let err) {
                    callback([], err)
                }
            }
        }.resume()
    }
    
    func refreshEnvDevices(callback: @escaping ([Device], Error?) -> Void) -> Void {
        getDevices { (devices, err) in
            if let err = err {
                print(err)
            }
            DispatchQueue.main.async {
                EnvironmentManager.shared.env.devices = devices
                callback(devices, err)
            }
        }
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
