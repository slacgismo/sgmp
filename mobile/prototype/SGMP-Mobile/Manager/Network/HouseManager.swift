//
//  HouseManager.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/19/21.
//

import Foundation

class HouseManager : BaseManager {
    static let instance = HouseManager()
    
    override class var shared : HouseManager {
        return instance
    }
    
    override func setup() {
    }
    
    // MARK: - House
    func getHouses(callback: (@escaping ([House], Error?) -> Void)) -> Void {
        URLSession.shared.dataTask(with: SgmpHostUrl.appendingPathComponent("api/house/list")) { data, response, err in
            if let err = err {
                callback([], err)
            } else if let data = data {
                do {
                    let listHousesResponse = try JSONDecoder().decode(ListHousesResponse.self, from: data)
                    let houses = listHousesResponse.houses
                    callback(houses ?? [], nil)
                } catch (let err) {
                    callback([], err)
                }
            }
        }.resume()
    }
    
    func refreshEnvHouses(callback: @escaping ([House], Error?) -> Void) -> Void {
        getHouses { houses, err in
            if let err = err {
                print(err)
            }
            DispatchQueue.main.async {
                EnvironmentManager.shared.env.houses = houses
                callback(houses, err)
            }
        }
    }
}

