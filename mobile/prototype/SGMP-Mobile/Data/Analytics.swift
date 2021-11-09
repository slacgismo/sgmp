//
//  Analytics.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/29/21.
//

import Foundation

// MARK: - Analytics Network
struct ListAnalyticsRequest : Codable {
    var house_id : UInt64
}

struct ListAnalyticsResponse : Codable {
    var message : String?
    var status : String
    var analytics : [DefinedAnalytics]?
}

// MARK: - Analytics Model
struct DefinedAnalytics : Codable, Identifiable {
    var id : UInt64 {
        return analytics_id
    }
    var analytics_id : UInt64
    var continuous_aggregation : Bool
    var description : String
    var formula : String
    var name : String
}

// MARK: - Analytics UI
// MARK: - Device UI
extension DefinedAnalytics {
    var sfSymbolName : String {
        switch name {
        case "battery": return "battery.100.bolt"
        case "battery_charging": return "battery.100"
        case "battery_discharging": return "battery.0"
        case "ev": return "car.fill"
        case "ev_charge_duration": return "clock.fill"
        case "ev_charge_energy": return "bolt.car"
        case "ev_event_count": return "clock.arrow.2.circlepath"
        case "gridpower": return "powerplug.fill"
        case "l1_frequency": return "timelapse"
        case "l1_voltage": return "bolt.fill"
        case "l2_frequency": return "timelapse"
        case "l2_voltage": return "bolt.fill"
        case "load": return "speedometer"
        case "soc": return "bolt.batteryblock.fill"
        case "solar": return "sun.min.fill"
        case "solar_ratio": return "sun.and.horizon.fill"
        default: return "chart.bar.fill"
        }
    }
}
