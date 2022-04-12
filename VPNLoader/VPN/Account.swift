//
//  Account.swift
//  VPNLoader
//
//  Created by Dumitru on 27.03.2022.//

import Foundation

public struct Account {
    
    var serverAddress: String
    var sharedSecret: String
    
    public init(serverAddress: String, sharedSecret: String) {
        self.serverAddress = serverAddress
        self.sharedSecret = sharedSecret
    }
}
