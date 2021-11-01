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
    var value : Double
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
    var formula : String
    var agg_function : AggregateFunction
}

struct AnalyticsAggregatedResponse : Codable {
    var status : String
    var value : Double?
}
