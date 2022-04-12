//
//  VPNDelegate.swift
//  VPNLoader
//
//  Created by Dumitru on 27.03.2022.
//

import Foundation

public protocol VPNDelegate: class {
    func vpn(_ vpn: VPN, statusDidChange status: VpnStatus)
    func vpn(_ vpn: VPN, didRequestPermission status: ConnectStatus)
    func vpn(_ vpn: VPN, didConnectWithError error: String?)
    func vpnDidDisconnect(_ vpn: VPN)
}
