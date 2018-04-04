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
	
	var delegateList : [CallbackProtocol] {get set}
	
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
	func sendMessage(string: String, to userID: String, completionHandler: ((_ success: Bool, _ error: Error?) -> ())?)
	var delegate : CommunicatorDelegate? {get set}
	var online : Bool? {get set}
}


class MultipeerCommunicator: NSObject, Communicator {
	
	var online: Bool?
	
	let serviceType = "tinkoff-chat"
	
	let myPeerId = MCPeerID(displayName: "iphone8+")
	let serviceAdvertiser : MCNearbyServiceAdvertiser
	let serviceBrowser : MCNearbyServiceBrowser
	
	weak var delegate : CommunicatorDelegate?
	
	private func generateMess() -> String {
		return "\(arc4random_uniform(UINT32_MAX))+\(Date.timeIntervalSinceReferenceDate)".data(using: .utf8)!.base64EncodedString()
	}
	
	func sendMessage(string: String, to userID: String, completionHandler:((Bool, Error?) -> ())?) {
		
		NSLog("%@", "send: \(string) to \(session.connectedPeers.count) peers")
		
		let message = self.generateMess()
		
		let json = ["eventType":"TextMessage","text":string,"messageId":message]
		
		let jsonData = try? JSONSerialization.data(withJSONObject: json)
		
		if session.connectedPeers.count > 0 {
			do {
				try self.session.send(jsonData!, toPeers: session.connectedPeers, with: .reliable)
				completionHandler!(true, nil)
			}
			catch let error {
				NSLog("%@", "Error for sending: \(error)")
				completionHandler!(true, error)
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


extension MultipeerCommunicator : MCNearbyServiceAdvertiserDelegate {
	
	func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
		NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
		self.delegate?.failedToStartAdvertising(error: error)
	}
	
	
	func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
		NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
		invitationHandler(true, self.session)
	}
	
}

extension MultipeerCommunicator : MCNearbyServiceBrowserDelegate {
	
	func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
		NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
		self.delegate?.failedToStartBrowsingForUser(error: error)
	}
	
	func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
		NSLog("%@", "lostPeer: \(peerID)")
		self.delegate?.didLostUser(userID: peerID.displayName)
	}
	
	func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
		NSLog("%@", "foundPeer: \(peerID)")
		NSLog("%@", "invitePeer: \(peerID)")
		browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
		self.delegate?.didFoundUser(userID: peerID.displayName, userName: info?["userName"])
	}
	
}

extension MultipeerCommunicator : MCSessionDelegate {
	
	
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

		let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
		if let responseJSON = responseJSON as? [String: Any] {
			print(responseJSON)
		}
		
		self.delegate?.didReceiveMessage(text: "textMessage", fromUser: peerID.displayName, toUser: myPeerId.displayName)

	}
	
}
