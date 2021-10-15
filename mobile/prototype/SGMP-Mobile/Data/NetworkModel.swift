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


struct DeviceKeyAnalyticsFrame : Codable, Identifiable {
    var id : Int64 {
        return timestamp
    }
    var timestamp : Int64
    var value : Double
}
struct DeviceKeyAnalyticsRequest : Codable {
    var start_time : Int64
    var end_time : Int64
    var type : String = "analytics"
    var formula : String
}
struct DeviceKeyAnalyticsResponse : Codable {
    var message : String?
    var status : String
    var data : [DeviceKeyAnalyticsFrame]?
}
