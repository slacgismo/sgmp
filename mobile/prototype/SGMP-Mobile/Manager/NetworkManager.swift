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

/**
 Singleton for network requests (actually a wrapper around `Alamofire` library)
 */
class NetworkManager : BaseManager {
    static let instance = NetworkManager()
    
    override class var shared : NetworkManager {
        return instance
    }
    
    // MARK: - House
    
    
    /// Get house list
    /// - Parameter callback: callback with the type of ((`[House]`, `Error?`) -> Void)
    /// - Returns: `Void`
    func getHouses(callback: (@escaping ([House], Error?) -> Void)) -> Void {
        if let profile = Defaults[.userProfile] {
            AF.request("\(SgmpHostString)api/house/list", headers: .init(["Authorization": "Bearer \(profile.accessToken)"]))
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
    
    /// Get device list from a particular house
    /// - Parameters:
    ///   - houseId: House ID
    ///   - callback: Callback, note the device list might be null
    /// - Returns: `Void`
    func getDevices(houseId : UInt64, callback : (@escaping ([Device]?, Error?) -> Void)) -> Void {
        if let profile = Defaults[.userProfile] {
            let parameters = ListDevicesRequest(house_id: houseId)
            AF.request("\(SgmpHostString)api/device/list", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: .init(["Authorization": "Bearer \(profile.accessToken)"]))
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
    
    /// Get details of a device
    /// - Parameters:
    ///   - deviceId: Device ID
    ///   - callback: Callback
    /// - Returns: `Void`
    func getDeviceDetail(deviceId : UInt64, callback: @escaping ((DeviceDetail?, Error?) -> Void)) -> Void {
        if let profile = Defaults[.userProfile] {
            let parameters = DeviceDetailRequest(device_id: deviceId)
            AF.request("\(SgmpHostString)api/device/details", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: .init(["Authorization": "Bearer \(profile.accessToken)"]))
                .responseDecodable(of: DeviceDetailResponse.self) { response in
                    debugPrint(response)
                    callback(response.value?.device, response.error)
                    self.responsePostHandlerForExpiredToken(response: response)
                }
        } else {
            callback(nil, nil)
        }
    }
    
    // MARK: - Analytics
    func getDefinedAnalytics(houseId : UInt64, callback: @escaping (([DefinedAnalytics]?, Error?) -> Void)) -> Void {
        if let profile = Defaults[.userProfile] {
            let parameters = ListAnalyticsRequest(house_id: houseId)
            AF.request("\(SgmpHostString)api/analytics/list", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: .init(["Authorization": "Bearer \(profile.accessToken)"]))
                .responseDecodable(of: ListAnalyticsResponse.self) { response in
                    debugPrint(response)
                    callback(response.value?.analytics, response.error)
                    self.responsePostHandlerForExpiredToken(response: response)
                }
        } else {
            callback(nil, nil)
        }
    }
    
    // MARK: - Analytics Timeseries
    func getAnalyticsTimeSeries(houseId : UInt64, startDate: Date, endDate: Date, forumla: String? = nil, analyticsName: String? = nil, interval: Double? = nil, callback: @escaping (([AnalyticsTimeSeriesFrame]?, Error?) -> Void)) -> Void {
        
        if let profile = Defaults[.userProfile],
            ( (forumla == nil && analyticsName != nil) || (forumla != nil && analyticsName == nil) ) // can only have one in the call
        {
            let parameters = AnalyticsTimeSeriesRequest(start_time: UInt64(startDate.timeIntervalSince1970 * 1000), end_time: UInt64(endDate.timeIntervalSince1970 * 1000), house_id: houseId, fine: false, average: interval, formula: forumla, analytics_name: analyticsName)
            AF.request("\(SgmpHostString)api/data/read", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: .init(["Authorization": "Bearer \(profile.accessToken)"]))
                .responseDecodable(of: AnalyticsTimeSeriesResponse.self) { response in
                    debugPrint(response)
                    callback(response.value?.data, response.error)
                    self.responsePostHandlerForExpiredToken(response: response)
                }
        } else {
            callback(nil, nil)
        }
    }
    
    func getAnalyticsOneshot(houseId : UInt64, startDate: Date, endDate: Date, forumla: String? = nil, analyticsName: String? = nil, callback: @escaping ((AnalyticsTimeSeriesFrame?, Error?) -> Void)) -> Void {
        if let profile = Defaults[.userProfile],
            ( (forumla == nil && analyticsName != nil) || (forumla != nil && analyticsName == nil) ) // can only have one in the call
        {
            let parameters = AnalyticsTimeSeriesRequest(start_time: UInt64(startDate.timeIntervalSince1970 * 1000), end_time: UInt64(endDate.timeIntervalSince1970 * 1000), house_id: houseId, formula: forumla, analytics_name: analyticsName)
            AF.request("\(SgmpHostString)api/data/read", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: .init(["Authorization": "Bearer \(profile.accessToken)"]))
                .responseDecodable(of: AnalyticsTimeSeriesResponse.self) { response in
                    debugPrint(response)
                    callback(response.value?.data?.last, response.error)
                    self.responsePostHandlerForExpiredToken(response: response)
                }
        } else {
            callback(nil, nil)
        }
    }
    
    // MARK: - Analytics Aggregated
    func getAnalyticsAggregated(formula: String, houseId : UInt64, aggregateFunction : AggregateFunction, startDate: Date, endDate: Date, callback: @escaping ((Double?, Error?) -> Void)) -> Void {
        if let profile = Defaults[.userProfile] {
            let parameters = AnalyticsAggregatedRequest(start_time: UInt64(startDate.timeIntervalSince1970 * 1000), end_time: UInt64(endDate.timeIntervalSince1970 * 1000), formula: formula, agg_function: aggregateFunction, house_id: houseId)
            AF.request("\(SgmpHostString)api/data/read", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: .init(["Authorization": "Bearer \(profile.accessToken)"]))
                .responseDecodable(of: AnalyticsAggregatedResponse.self) { response in
                    debugPrint(response)
                    callback(response.value?.value, response.error)
                    self.responsePostHandlerForExpiredToken(response: response)
                }
        } else {
            callback(nil, nil)
        }
    }
    
    func getAnalyticsAggregated(analyticsName: String, houseId : UInt64, aggregateFunction : AggregateFunction, startDate: Date, endDate: Date, callback: @escaping ((Double?, Error?) -> Void)) -> Void {
        if let profile = Defaults[.userProfile] {
            let parameters = AnalyticsAggregatedRequest(start_time: UInt64(startDate.timeIntervalSince1970 * 1000), end_time: UInt64(endDate.timeIntervalSince1970 * 1000), analytics_name: analyticsName, agg_function: aggregateFunction, house_id: houseId)
            AF.request("\(SgmpHostString)api/data/read", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: .init(["Authorization": "Bearer \(profile.accessToken)"]))
                .responseDecodable(of: AnalyticsAggregatedResponse.self) { response in
                    debugPrint(response)
                    callback(response.value?.value, response.error)
                    self.responsePostHandlerForExpiredToken(response: response)
                }
        } else {
            callback(nil, nil)
        }
    }
    
    
    // MARK: - User
    func login(email: String, password: String, callback: @escaping ((UserLoginResponse?, Error?) -> Void)) -> Void {
        let parameters = UserLoginRequest(email: email, password: password)
        AF.request("\(SgmpHostString)api/user/login", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default)
            .responseDecodable(of: UserLoginResponse.self) { response in
                debugPrint(response)
                callback(response.value, response.error)
            }
    }
    
    func refreshToken(callback: @escaping ((RefreshTokenResponse?, Error?) -> Void)) -> Void {
        if let profile = Defaults[.userProfile] {
            let parameters = RefreshTokenRequest(refresh_token: profile.refreshToken)
            AF.request("\(SgmpHostString)api/user/refreshToken", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default)
                .responseDecodable(of: RefreshTokenResponse.self) { response in
                    debugPrint(response)
                    callback(response.value, response.error)
                }
        } else {
            callback(nil, nil)
        }
    }
    
    // MARK: - Misc
    
    
    /// A handler to examine if the `response` has a 401 status code (which means user login expired), and invalidate the current user accordingly
    private func responsePostHandlerForExpiredToken<T>(response : DataResponse<T, AFError>) {
        if (response.response?.statusCode == 401 && Defaults[.userProfile] != nil) {
            Defaults[.userProfile] = nil
        }
    }
}
