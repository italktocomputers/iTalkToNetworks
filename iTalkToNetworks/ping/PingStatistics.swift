//
//  PingStatistics.swift
//  DomainMaster
//
//  Created by Andrew Schools on 1/30/22.
//  Copyright © 2022 Andrew Schools. All rights reserved.
//

import Foundation

struct PingStatistics {
    var transmitted: Int
    var received: Int
    var lossed: Double
    var min: Double
    var max: Double
    var average: Double
    var stddev: Double
}
