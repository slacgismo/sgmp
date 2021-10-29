//
//  NetworkModel.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/12/21.
//

import Foundation

let SgmpHostString = "http://54.176.249.126/"
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
struct DeviceDetailResponse : Decodable {
    var status : String
    var message : String?
    var device : DeviceDetail?
}

protocol DeviceConfigProtocol : Codable {
    
}

struct DeviceDetail : Decodable {
    enum CodingKeys: String, CodingKey {
        case config, name, description, type
    }

    var config : DeviceConfigProtocol
    var name : String
    var description : String
    var type : String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.type = try container.decode(String.self, forKey: .type)
        switch self.type {
        case "sonnen":
            self.config = try container.decode(DeviceConfigSonnen.self, forKey: .config)
            break
        case "powerflex":
            self.config = try container.decode(DeviceConfigPowerflex.self, forKey: .config)
            break
        case "egauge":
            self.config = try container.decode(DeviceConfigEgauge.self, forKey: .config)
            break
        default:
            self.config = try container.decode(DeviceConfigDefault.self, forKey: .config)
            break
        }
    }
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

// MARK: - User
struct ProfileResponse : Codable {
    var email : String
    var name : String
    var roles : [String]
}

struct UserLoginRequest : Codable {
    var email : String
    var password : String

}

struct UserLoginResponse : Codable {
    var status : String
    var message : String?
    var accesstoken : String?
    var profile : ProfileResponse?
}
