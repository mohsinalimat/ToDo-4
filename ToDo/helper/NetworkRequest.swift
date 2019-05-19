//
//  NetworkRequest.swift
//  ToDo
//
//  Created by Tuyen Le on 19.05.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

final class Network {
    /// this api is coming from https://quotes.rest/#!/qod/get_qod
    static func getQuoteOfDay(completion: @escaping (String) -> Void) {
        Alamofire.request("https://quotes.rest/qod", method: .get, parameters: ["category": "love"]).responseJSON { response in
            do {
                let json = try JSON(data: response.data!)
                let quote = json["contents"]["quotes"][0]["quote"].string!
                completion(quote)
            } catch {
                print("JSONSerialization error:", error)
            }
        }
    }
}
