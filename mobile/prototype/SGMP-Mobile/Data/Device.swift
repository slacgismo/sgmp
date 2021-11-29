//
//  DeviceModel.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/29/21.
//

import Foundation

// MARK: - Device Network

/// Network data model for `POST` request to `/list/devices`
struct ListDevicesRequest : Codable {
    var house_id : UInt64
}

/// Network data model for response to `ListDevicesRequest`
struct ListDevicesResponse : Codable {
    var status : String
    var devices : [Device]?
}

// MARK: - Device Model
struct Device : Codable, Identifiable {
    var id : UInt64 {
        return device_id
    }
    
    var device_id : UInt64
    var name : String
    var description : String
    var type : String
}

// MARK: - Device Detail Network
struct DeviceDetailRequest : Codable {
    var device_id : UInt64
}
struct DeviceDetailResponse : Decodable {
    var status : String
    var message : String?
    var device : DeviceDetail?
}

// MARK: - Device Detail Model
protocol DeviceConfigProtocol : Codable {
    
}

struct DeviceDetail : Decodable {
    enum CodingKeys: String, CodingKey {
        case config, name, description, type, device_id, house_id
    }

    var config : DeviceConfigProtocol
    var name : String
    var description : String
    var house_id : UInt64
    var device_id : UInt64
    var type : String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.type = try container.decode(String.self, forKey: .type)
        self.house_id = try container.decode(UInt64.self, forKey: .house_id)
        self.device_id = try container.decode(UInt64.self, forKey: .device_id)
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

// MARK: - Device UI
extension Device {
    
    /// Return correct SF Symbol name based on the `Device.type` property
    /// For example,devices with type as `sonnen` will return a icon that stands for battery
    var sfSymbolName : String {
        switch type {
        case "sonnen": return "minus.plus.batteryblock.fill"
        case "egauge": return "waveform.path.ecg.rectangle.fill"
        case "powerflex": return "memorychip.fill"
        default: return "bolt.horizontal.fill"
        }
    }
}
