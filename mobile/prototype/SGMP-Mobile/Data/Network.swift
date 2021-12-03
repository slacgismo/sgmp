//
//  NetworkModel.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/12/21.
//

import Foundation
import Defaults

/// SGMP default root url, acts as the actual root url when `SgmpHostString` is set to not use custom end point
let SgmpHostStringDefault = "https://api.sgmp.slacgismo.io/"

/// A computed property that returns end point string (`SgmpHostStringDefault` or `Defaults.Keys.customEndpointUrl` in `UserDefaults`) based on `Defaults.Keys.customEndpoint` in `UserDefaults`
var SgmpHostString : String {
    return Defaults[.customEndpoint] ? Defaults[.customEndpointUrl] : SgmpHostStringDefault
}

/// A computed property that wrap a URL class around `SgmpHostString`
var SgmpHostUrl : URL {
    return URL(string: SgmpHostString)!
}

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
    var house_id : UInt64
    var name : String
    
    var id: UInt64 {
        return house_id
    }
}

// MARK: - Analytics Time Series
struct AnalyticsTimeSeriesRequest : Codable {
    var start_time : UInt64
    var end_time : UInt64
    var house_id : UInt64
    var fine : Bool?
    var average : Double?
    var type : String = "analytics"
    var formula : String?
    var analytics_name : String?
}

struct AnalyticsTimeSeriesResponse : Codable {
    var message : String?
    var status : String
    var data : [AnalyticsTimeSeriesFrame]?
}

struct AnalyticsTimeSeriesFrame : Codable, Identifiable {
    var id : UInt64 {
        return timestamp
    }
    var timestamp : UInt64
    var value : Double?
}

// MARK: - Analytics Aggregate
enum AggregateFunction: String, CaseIterable, Codable {
    case min = "min";
    case max = "max";
    case avg = "avg";
}

struct AnalyticsAggregatedRequest : Codable {
    var start_time : UInt64
    var end_time : UInt64
    var type : String = "analytics"
    var formula : String?
    var analytics_name : String?
    var agg_function : AggregateFunction
    var fine : Bool = true
    var house_id : UInt64
}

struct AnalyticsAggregatedResponse : Codable {
    var status : String
    var value : Double?
}
