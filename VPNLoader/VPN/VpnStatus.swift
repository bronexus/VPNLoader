//
//  VPNStatus.swift
//  VPNLoader
//
//  Created by Dumitru on 27.03.2022.
//

import Foundation

public enum VpnStatus {
    case connected
    case disconnected
    case connecting
    case reasserting
    case disconnecting
    case invalid
    
    public var description: String {
        switch self {
        case .connected:
            return "connected"
        case .disconnected:
            return "disconnected"
        case .connecting:
            return "connecting"
        case .reasserting:
            return "reasserting"
        case .disconnecting:
            return "disconnecting"
        case .invalid:
            return "invalid"
        }
    }
}

class VPNState {
	
	static var shared = VPNState()
	
	var wasPermitted: Bool {
		get { UserDefaults.standard.bool(forKey: UserDefaults.Keys.wasPermitted) }
		set { UserDefaults.standard.set(newValue, forKey: UserDefaults.Keys.wasPermitted) }
	}
}
