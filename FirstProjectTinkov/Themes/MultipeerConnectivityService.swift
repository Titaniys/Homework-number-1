//
//  ServiceManager.swift
//  MultipeerConnectivityService
//
//  Created by Вадим Чистяков on 28.03.18.
//  Copyright © 2018 Вадим Чистяков. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol CommunicatorDelegate : class {
	//discovering
	func didFoundUser(userID: String, userName: String?)
	func didLostUser(userID: String)
	
	//errors
	func failedToStartBrowsingForUser(error: Error)
	func failedToStartAdvertising(error: Error)
	
	//messages
	func didReceiveMessage(text: String, fromUser: String, toUser: String)
	
}

protocol Communicator {
	func sendMessage(string: String, to useID: String, completionHandler: ((_ success: Bool, _ error: Error?) -> ())?)
	var delegate : CommunicatorDelegate? {get set}
	var online : Bool {get set}
}


class MultipeerConnectivityService: NSObject {

	
	private let serviceType = "tinkoff-chat"
	
	private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
	private let serviceAdvertiser : MCNearbyServiceAdvertiser
	private let serviceBrowser : MCNearbyServiceBrowser
	
	var delegate : CommunicatorDelegate?
	
	func generateMess() -> String {
		return "\(arc4random_uniform(UINT32_MAX))+\(Date.timeIntervalSinceReferenceDate)".data(using: .utf8)!.base64EncodedString()
	}
	
	func send(colorName : Any) {
		NSLog("%@", "sendName: \(colorName) to \(session.connectedPeers.count) peers")

		let message = self.generateMess()
		
		let json = ["eventType":"TextMessage","text":"Vadim Chistyakov","messageId":message]
		
		let jsonData = try? JSONSerialization.data(withJSONObject: json)
		
		if session.connectedPeers.count > 0 {
			do {
				try self.session.send(jsonData!, toPeers: session.connectedPeers, with: .reliable)
			}
			catch let error {
				NSLog("%@", "Error for sending: \(error)")
			}
		}
		
	}

	
	override init() {
		self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: ["userName" : "Vadim"], serviceType: serviceType)
		 self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
		super.init()
		
		self.serviceAdvertiser.delegate = self
		self.serviceAdvertiser.startAdvertisingPeer()
		
		self.serviceBrowser.delegate = self
		self.serviceBrowser.startBrowsingForPeers()
		
	}
	
	deinit {
		self.serviceAdvertiser.stopAdvertisingPeer()
		self.serviceBrowser.stopBrowsingForPeers()
	}
	
	lazy var session : MCSession = {
		let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
		session.delegate = self
		return session
	}()
	
}




extension MultipeerConnectivityService : MCNearbyServiceAdvertiserDelegate {
	
	func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
		NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
	}
	
	
	func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
		NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
		invitationHandler(true, self.session)
	}
	
}

extension MultipeerConnectivityService : MCNearbyServiceBrowserDelegate {
	
	func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
		NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
	}
	
	func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
		NSLog("%@", "lostPeer: \(peerID)")
	}
	
	func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
		NSLog("%@", "foundPeer: \(peerID)")
		NSLog("%@", "invitePeer: \(peerID)")
		browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
	}
	
}

extension MultipeerConnectivityService : MCSessionDelegate {
	
	
	func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
		NSLog("%@", "didReceiveStream")
	}
	
	func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
		NSLog("%@", "didStartReceivingResourceWithName")
	}
	
	func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
		NSLog("%@", "didFinishReceivingResourceWithName")
	}
	
	func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
		NSLog("%@", "peer \(peerID) didChangeState: ")
		//self.delegate?.connectedDevicesChanged(manager: self, connectedDevices:
			//session.connectedPeers.map{$0.displayName})
	}
	
	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
		NSLog("%@", "didReceiveData: \(data.count) bytes")
		let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
		if let responseJSON = responseJSON as? [String: Any] {
			print(responseJSON)
		}
		let str = String(data: data, encoding: .utf8)!
		//self.delegate?.colorChanged(manager: self, colorString: str)
	}
	
}
