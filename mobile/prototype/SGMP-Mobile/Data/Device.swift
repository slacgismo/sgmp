//
//  DeviceModel.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/29/21.
//

import Foundation

// MARK: - Device Network
struct ListDevicesRequest : Codable {
    var house_id : UInt64
}

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

// MARK: - Device UI
extension Device {
    var sfSymbolName : String {
        switch type {
        case "sonnen": return "minus.plus.batteryblock.fill"
        case "egauge": return "waveform.path.ecg.rectangle.fill"
        case "powerflex": return "memorychip.fill"
        default: return "bolt.horizontal.fill"
        }
    }
}
