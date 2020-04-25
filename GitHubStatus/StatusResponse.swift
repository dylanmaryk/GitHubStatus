//
//  StatusResponse.swift
//  GitHubStatus
//
//  Created by Dylan Maryk on 25/04/2020.
//  Copyright © 2020 Dylan Maryk. All rights reserved.
//

import Foundation

enum Indicator: String, Decodable {
    case none
    case minor
    case major
    case critical
}

struct StatusResponse: Decodable {
    let page: Page
    let status: Status
}

struct Page: Decodable {
    let url: URL
}

struct Status: Decodable {
    let indicator: Indicator
    let description: String
}
