//
//  ResponseModel.swift
//  Nature-Remo-Widget
//
//  Created by Rei Nakaoka on 2021/12/02.
//

import Foundation

struct ResponseModel: Codable {
    var newest_events: newest_events

    struct newest_events: Codable {
        var te: te
    }

    struct te: Codable {
        var val: Double
        var created_at: String
    }
}
