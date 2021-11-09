//
//  DeviceConfigView.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/28/21.
//

import SwiftUI

protocol DeviceConfigViewProtocol : View {
    var detail : DeviceDetail { get set }
}

// MARK: - Default
struct DeviceConfigDefault : DeviceConfigProtocol, Codable {
    
}

struct DeviceConfigDefaultView: DeviceConfigViewProtocol {
    var detail: DeviceDetail
    
    var body: some View {
        Group {
            TitleDescCellView(title: "Data", content: "Format not supported")
        }
    }
}


// MARK: - Sonnen

// {"device":{"config":{"ip":"198.129.119.220","serial":"66352","token":"5db92cf858eebce34af146974f49f4d40ec699b99372546c0af628fb48133f61"},"description":"Sonnen Controller","name":"sonnen","type":"sonnen"},"status":"ok"}
struct DeviceConfigSonnen : DeviceConfigProtocol, Codable {
    var ip : String?
    var serial : String?
    var token : String?
}

struct DeviceConfigSonnenView: DeviceConfigViewProtocol {
    var detail: DeviceDetail
    var config : DeviceConfigSonnen? {
        detail.config as? DeviceConfigSonnen
    }
    
    var body: some View {
        Group {
            TitleDescCellView(title: "IP", content: config?.ip)
            TitleDescCellView(title: "Serial", content: config?.serial)
            TitleDescCellView(title: "Token", content: config?.token)
        }
    }
}

// MARK: - Powerflex

// {"device":{"config":{"acc_id":"03","acs_id":"01","password":"wjKlamp7FXsrdpi","url":"https://slac.powerflex.com:9443","username":"gcezar@stanford.edu"},"description":"Powerflex 03,01","name":"pf_01","type":"powerflex"},"status":"ok"}
struct DeviceConfigPowerflex : DeviceConfigProtocol, Codable {
    var acc_id : String?
    var acs_id : String?
    var username : String?
    var password : String?
    var url : String?
}

struct DeviceConfigPowerflexView: DeviceConfigViewProtocol {
    var detail: DeviceDetail
    var config : DeviceConfigPowerflex? {
        detail.config as? DeviceConfigPowerflex
    }
    
    var body: some View {
        Group {
            TitleDescCellView(title: "ID", content: "ACC \(config?.acc_id ?? "-") / ACS \(config?.acs_id ?? "-")")
            TitleDescCellView(title: "Username", content: config?.username)
            TitleDescCellView(title: "Password", content: config?.password)
            TitleDescCellView(title: "URL", content: config?.url)
        }
    }
}


// MARK: - Egauge

// {"device":{"config":{"ip":"198.129.116.113","keys":["A.Battery","A.SubPanel","A.GridPower","A.Solar","A.EV","A.L1_Voltage","A.L2_Voltage","A.L1_Frequency","A.L2_Frequency","A.Load","ts"]},"description":"eGauge Controller","name":"egauge","type":"egauge"},"status":"ok"}
struct DeviceConfigEgauge : DeviceConfigProtocol, Codable {
    var ip : String?
    var keys : [String]?
}

struct DeviceConfigEgaugeView: DeviceConfigViewProtocol {
    var detail: DeviceDetail
    var config : DeviceConfigEgauge? {
        detail.config as? DeviceConfigEgauge
    }
    
    var body: some View {
        Group {
            TitleDescCellView(title: "IP", content: config?.ip)
            ForEach(config?.keys ?? [], id: \.self) { key in
                if key.starts(with: "A.") {
                    ExpandableView(title: {
                        TitleDescCellView(title: "KEY", content: "\(key)")
                    }, expandable: {
                        NavigationLink {
                            DeviceFormulaView(device: detail, formula: "\(detail.name).\(key)")
                        } label: {
                            DeviceFormulaAnalyticsChartView(device: detail, formula: "\(detail.name).\(key)")
                        }
                    }).frame(maxHeight: .infinity)
                } else {
                    TitleDescCellView(title: "KEY", content: "\(key)")
                }
                
            }
        }
    }
}
