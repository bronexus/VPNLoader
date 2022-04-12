//
//  ConnectStatus.swift
//  VPNLoader
//
//  Created by Dumitru on 27.03.2022.
//

import Foundation

public enum ConnectStatus {
    case success
    case failure
    
    public var description: String {
        switch self {
        case .success:
            return "success"
        case .failure:
            return "failure"
        }
    }
}
