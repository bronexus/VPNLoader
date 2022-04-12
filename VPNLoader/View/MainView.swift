//
//  ContentView.swift
//  VPNLoader
//
//  Created by Dumitru on 27.03.2022.
//

import SwiftUI

struct MainView: View {
	
	@StateObject var vm = VPNViewModel()
	
//	@State var showRequest: Bool = false
	
	var body: some View {
		VStack {
			GroupBox {
				VStack(alignment: .leading) {
					Text("VPN List API")
					TextField("URL", text: $vm.vpnUrl)
						.keyboardType(.URL)
						.autocapitalization(.none)
						.disableAutocorrection(true)
					Text("Login")
					TextField("Login", text: $vm.login)
						.autocapitalization(.none)
						.disableAutocorrection(true)
					Text("Password")
					SecureField("Password", text: $vm.password)
				}
				.textFieldStyle(.roundedBorder)
				.disabled(vm.isLoading)

				if vm.isLoading {
					ProgressView()
						.progressViewStyle(.circular)
				} else {
					Button {
						vm.loadServers()
					} label: {
						Text("Load")
							.foregroundColor(Color.white)
							.padding(.horizontal, 16)
							.padding(.vertical, 8)
							.background(Color.blue.opacity(!vm.canLoad ? 0.5 : 1))
							.clipShape(Capsule())
					}
					.disabled(!vm.canLoad)
				}
			}
			.padding()
			
				
			GroupBox {
				HStack {
					Text("Selected VPN server")
					
					Spacer()
					
					Button {
						vm.selectedVPN = nil
						UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.selectedVPN)
						vm.remove()
					} label: {
						Image(systemName: "arrow.counterclockwise")
					}
				}
				
				if let selectedVPN = vm.selectedVPN {
					ServerListCell(vpn: selectedVPN)
					
					HStack {
						Button {
							if vm.wasPermitted {
								vm.toggleVPN()
							} else {
								vm.showRequest.toggle()
							}
						} label: {
							ButtonText(title: vm.vpnStatus != .connected ? "Connect" : "Disconnect")
						}
					}
				}
				
			}
			.padding()
			
			
			
			Spacer()
			
			if let vpnList = vm.vpnList {
				List {
					Section(header: Text("Free servers")) {
						if (vpnList).filter({ $0.isFree == true }).isEmpty {
							Text("No free servers available")
								.opacity(0.5)
						} else {
							ForEach((vpnList).filter({ $0.isFree == true }), id: \.serverID) { vpn in
								ServerListCell(vpn: vpn)
									.onTapGesture {
										vm.selectVPN(vpn: vpn)
									}
							}
						}
					}
					
					Section(header: Text("Premium servers")) {
						if (vpnList).filter({ $0.isFree == false }).isEmpty {
							Text("No premium servers available")
								.opacity(0.5)
						} else {
							ForEach((vpnList).filter({ $0.isFree == false }), id: \.serverID) { vpn in
								ServerListCell(vpn: vpn)
									.onTapGesture {
										vm.selectVPN(vpn: vpn)
									}
							}
						}
					}
				}
			}
		}
		.sheet(isPresented: $vm.showRequest, content: {
			VStack {
				Text("VPN requires configuration in device settings. Press button bellow to request modifications and click ”Allow” to add VPN configurations")
					.font(.system(.caption))
					.multilineTextAlignment(.center)
					.frame(maxWidth: 200)
				
				Button {
					vm.requestPermission()
				} label: {
					ButtonText(title: "Request")
				}
			}
		})
		.onTapGesture {
			UIApplication.shared.endEditing()
		}
		.alert(isPresented: $vm.showAlert) {
			switch vm.alertType {
			case .loadError:
				return Alert(
					title: Text("Load failed"),
					message: Text("Please contact support")
				)
			case .noFreeAvailable:
				return Alert(
					title: Text("No free server available"),
					message: Text("Please select a vpn server from premium list")
				)
			default:
				return Alert(
					title: Text("Sometrhing went wrong"),
					message: Text("An unexpected error happened, please contact support")
				)
			}
		}
	}
}

struct MainView_Previews: PreviewProvider {
	static var previews: some View {
		MainView().previewDevice(.init(stringLiteral: "iPhone X"))
	}
}

struct ServerListCell: View {
	var vpn: VPNServerElement
	
	var body: some View {
		HStack {
			VStack {
				HStack {
					Text(vpn.hostname)
					Spacer()
					Text(vpn.country)
				}
				HStack {
					Text(vpn.psk)
						.font(.system(.caption))
					Spacer()
					Text(vpn.location)
				}
			}
			
			Spacer()
			
			Image(vpn.countryCode)
				.resizable()
				.scaledToFill()
				.frame(width: 32, height: 32, alignment: .center)
				.clipShape(Circle())
				.overlay(
					Circle()
						.stroke(Color.blue, lineWidth: 1)
				)
		}
	}
}

struct ButtonText: View {
	var title: String
	
	var body: some View {
		Text(title)
			.font(.system(.footnote))
			.foregroundColor(Color.white)
			.padding(.horizontal, 12)
			.padding(.vertical, 6)
			.background(Color.blue)
			.clipShape(Capsule())
	}
}

