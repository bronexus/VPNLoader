//
//  VPNViewModel.swift
//  VPNLoader
//
//  Created by Dumitru on 27.03.2022.
//

import Combine
import Foundation

class VPNViewModel: ObservableObject {
	
	@Published var vpnUrl = ""
	@Published var login = ""
	@Published var password = ""
	@Published var isLoading = false
	@Published var vpnList: [VPNServerElement]?
	@Published var selectedVPN: VPNServerElement?
	
	@Published var vpnStatus: VpnStatus?
	
	@Published var wasPermitted: Bool = false
	@Published var wasEnabled: Bool = false
	
	@Published var showRequest: Bool = false
	@Published var alertType: VPNAlertype?
	@Published var showAlert: Bool = false
	
	
	
	var canLoad: Bool {
		!login.isEmpty && !password.isEmpty && !vpnUrl.isEmpty
	}
	
	lazy var vpn: VPN = {
		let _vpn = VPN(delegate: self)
		return _vpn
	}()
	
	
	
	init() {
		wasPermitted = VPNState.shared.wasPermitted
		
		loadServers()
		
		if wasPermitted {
			loadFromPreferences()
		}
		
		if let userSelectedServer = UserDefaults.standard.object(forKey: UserDefaults.Keys.selectedVPN) as? Data {
			selectedVPN = try? PropertyListDecoder().decode(VPNServerElement.self, from: userSelectedServer)
		}
	}
	
	
	
	func requestPermission() {
		vpn.requestPermision(account: Account(serverAddress: selectedVPN!.hostname, sharedSecret: selectedVPN!.psk))
	}
	
	func toggleVPN() {
		vpn.toggleVpn()
	}
	
	func connectVPN() {
		vpn.connect()
	}
	
	func disconnectVPN() {
		vpn.disconnect()
	}
	
	func loadFromPreferences() {
		vpn.loadFromPreferences {
			print("Status laod from pref: \(self.vpn.status().description)")
		}
	}
	
	func remove() {
		vpn.removeFromPreferences()
	}
	
	func printStatus() {
		print("Status: \(vpn.status().description)")
	}
	
	
	
	func loadServers() {
		guard !login.isEmpty && !password.isEmpty && !vpnUrl.isEmpty else {
			return
		}
		
		var request = URLRequest(url: URL(string: vpnUrl)!)
		
		request.httpMethod = "GET"
		
		let authData = (login + ":" + password).data(using: .utf8)!.base64EncodedString()
		request.addValue("Basic \(authData)", forHTTPHeaderField: "Authorization")
		
		isLoading = true
		
		URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
			DispatchQueue.main.async {
				if error != nil || (response as! HTTPURLResponse).statusCode != 200 {
					self?.alertType = .loadError
					self?.showAlert = true
				} else if let data = data {
					do {
						let vpns = try JSONDecoder().decode([VPNServerElement].self, from: data)
						
//						print(vpns)
						
						self?.vpnList = vpns
						
						if vpns.filter({ $0.isFree == true }).count < 1 {
							if self?.selectedVPN == nil {
								self?.alertType = .noFreeAvailable
								self?.showAlert = true
							}
						}
						
					} catch {
						print("Unable to Decode Response \(error)")
					}
				}
				
				self?.isLoading = false
			}
		}.resume()
	}
	
	func selectVPN(vpn: VPNServerElement) {
		selectedVPN = vpn
		UserDefaults.standard.set(try? PropertyListEncoder().encode(vpn), forKey: UserDefaults.Keys.selectedVPN)
	}
	
}

extension VPNViewModel: VPNDelegate {
	func vpn(_ vpn: VPN, statusDidChange status: VpnStatus) {
		print("status did change: \(status.description)")
		vpnStatus = status
	}
	
	func vpn(_ vpn: VPN, didRequestPermission status: ConnectStatus) {
		print(status.description)
		if status == .success {
			VPNState.shared.wasPermitted = true
			wasPermitted = true
			showRequest = false
		} else {
			VPNState.shared.wasPermitted = false
			wasPermitted = false
		}
		
	}
	
	func vpn(_ vpn: VPN, didConnectWithError error: String?) {
		print(error ?? "")
	}
	
	func vpnDidDisconnect(_ vpn: VPN) {
		print("delegated disconnect")
	}
}

enum VPNAlertype {
	case loadError, noFreeAvailable
}
