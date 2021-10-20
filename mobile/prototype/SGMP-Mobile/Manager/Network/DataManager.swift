//
//  DataManager.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/19/21.
//

import Foundation

class DataManager : BaseManager {
    static let instance = DataManager()
    
    override class var shared : DataManager {
        return instance
    }
    
    func getAnalyticsAggregated(deviceName: String, key: String, aggregateFunction : AggregateFunction, startDate: Date, endDate: Date, callback: @escaping ((Double?, Error?) -> Void)) -> Void {
        let requestData = AnalyticsAggregatedRequest(start_time: Int64(startDate.timeIntervalSince1970 * 1000), end_time: Int64(endDate.timeIntervalSince1970 * 1000), formula: "\(deviceName).\(key)", agg_function: aggregateFunction)
        var request = URLRequest(url: SgmpHostUrl.appendingPathComponent("api/data/read"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        do {
            request.httpBody = try JSONEncoder().encode(requestData)
        } catch (let err) {
            callback(nil, err)
            return
        }
        URLSession.shared.dataTask(with: request) { data, response, err in
            if let err = err {
                callback(nil, err)
            } else if let data = data {
                do {
                    let deviceAggregatedResponse = try JSONDecoder().decode(AnalyticsAggregatedResponse.self, from: data)
                    let value = deviceAggregatedResponse.value
                    callback(value, nil)
                } catch (let err) {
                    callback(nil, err)
                }
            }
        }.resume()
    }
    
    func getAnalyticsTimeSeries(deviceName: String, key: String, startDate: Date, endDate: Date, callback: @escaping (([AnalyticsTimeSeriesFrame]?, Error?) -> Void)) -> Void {
        let requestData = AnalyticsTimeSeriesRequest(start_time: Int64(startDate.timeIntervalSince1970 * 1000), end_time: Int64(endDate.timeIntervalSince1970 * 1000), formula: "\(deviceName).\(key)")
        var request = URLRequest(url: SgmpHostUrl.appendingPathComponent("api/data/read"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        do {
            request.httpBody = try JSONEncoder().encode(requestData)
        } catch (let err) {
            callback(nil, err)
            return
        }
        URLSession.shared.dataTask(with: request) { data, response, err in
            if let err = err {
                callback(nil, err)
            } else if let data = data {
                do {
                    let deviceKeyAnalyticsResponse = try JSONDecoder().decode(AnalyticsTimeSeriesResponse.self, from: data)
                    let frames = deviceKeyAnalyticsResponse.data
                    callback(frames ?? nil, nil)
                } catch (let err) {
                    callback(nil, err)
                }
            }
        }.resume()
    }
}
