//
//  NetworkModel.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/12/21.
//

import Foundation

let SgmpHostString = "http://ec2-54-176-53-197.us-west-1.compute.amazonaws.com:5000"
let SgmpHostUrl : URL = URL(string: SgmpHostString)!

struct Response : Codable {
    var status : String
}

struct ResponseWithData<T> : Codable where T : Codable {
    var status : String
    var data : T
}

// MARK: - House
struct ListHousesResponse : Codable {
    var status : String
    var houses : [House]?
}

struct House : Codable, Identifiable {
    var description : String
    var house_id : Int64
    var name : String
    
    var id: Int64 {
        return house_id
    }
}

// MARK: - Device
struct ListDevicesRequest : Codable {
    var house_id : Int64
}

struct ListDevicesResponse : Codable {
    var status : String
    var devices : [Device]?
}

struct Device : Codable, Identifiable {
    var id : Int64 {
        return device_id
    }
    
    var device_id : Int64
    var name : String
    var description : String
    var type : String
}

struct DeviceDetailRequest : Codable {
    var device_id : Int64
}
struct DeviceDetailResponse : Codable {
    var status : String
    var message : String?
    var device : DeviceDetail?
}

struct DeviceConfig : Codable {
    var ip : String
    var keys : [String]?
}

struct DeviceDetail : Codable {
    var config : DeviceConfig
    var name : String
    var description : String
    var type : String
}


// MARK: - Analytics Time Series
struct AnalyticsTimeSeriesRequest : Codable {
    var start_time : Int64
    var end_time : Int64
    var type : String = "analytics"
    var formula : String
}

struct AnalyticsTimeSeriesResponse : Codable {
    var message : String?
    var status : String
    var data : [AnalyticsTimeSeriesFrame]?
}

struct AnalyticsTimeSeriesFrame : Codable, Identifiable {
    var id : Int64 {
        return timestamp
    }
    var timestamp : Int64
    var value : Double
}

// MARK: - Analytics Aggregate
enum AggregateFunction: String, CaseIterable, Codable {
    case min = "min";
    case max = "max";
    case avg = "avg";
}

struct AnalyticsAggregatedRequest : Codable {
    var start_time : Int64
    var end_time : Int64
    var type : String = "analytics"
    var formula : String
    var agg_function : AggregateFunction
}

struct AnalyticsAggregatedResponse : Codable {
    var status : String
    var value : Double
}
