//
//  NetworkManager.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/28/21.
//

import Foundation
import Defaults
import Alamofire
import Toast

class NetworkManager : BaseManager {
    static let instance = NetworkManager()
    
    override class var shared : NetworkManager {
        return instance
    }
    
    // MARK: - House
    func getHouses(callback: (@escaping ([House], Error?) -> Void)) -> Void {
        if let user = Defaults[.userProfile] {
            AF.request("\(SgmpHostString)api/house/list", headers: .init(["Authorization": "Bearer \(user.accessToken)"]))
                .responseDecodable(of: ListHousesResponse.self) { response in
                    debugPrint(response)
                    callback(response.value?.houses ?? [], response.error)
                    self.responsePostHandlerForExpiredToken(response: response)
                }
        } else {
            callback([], nil)
        }
    }

    
    // MARK: - Device
    func getDevices(houseId : Int64, callback : (@escaping ([Device]?, Error?) -> Void)) -> Void {
        if let user = Defaults[.userProfile] {
            let parameters = ListDevicesRequest(house_id: houseId)
            AF.request("\(SgmpHostString)api/device/list", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: .init(["Authorization": "Bearer \(user.accessToken)"]))
                .responseDecodable(of: ListDevicesResponse.self) { response in
                    debugPrint(response)
                    callback(response.value?.devices ?? [], response.error)
                    self.responsePostHandlerForExpiredToken(response: response)
                }
        } else {
            callback([], nil)
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
    
    
    // MARK: - Misc
    private func responsePostHandlerForExpiredToken<T>(response : DataResponse<T, AFError>) {
        if (response.response?.statusCode == 401 && Defaults[.userProfile] != nil) {
            Defaults[.userProfile] = nil
        }
    }
}
