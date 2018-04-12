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
	func didFoundUser(userID: MCPeerID, userName: String?)
	func didLostUser(userID: String)
	
	//errors
	func failedToStartBrowsingForUser(error: Error)
	func failedToStartAdvertising(error: Error)
	
	//messages
	func didReceiveMessage(text: String, fromUser: String, toUser: String)
}

protocol Communicator {
	func sendMessage(string: String, to userID: MCPeerID, completionHandler: ((_ success: Bool, _ error: Error?) -> ())?)
	var delegate : CommunicatorDelegate? {get set}
	var online : Bool? {get set}
}


class MultipeerCommunicator: NSObject, Communicator {
	
	var online: Bool?
	
	let serviceType = "tinkoff-chat"
	
    let myPeerId = MCPeerID(displayName: (UIDevice.current.identifierForVendor?.uuidString)!)
	let serviceAdvertiser : MCNearbyServiceAdvertiser
	let serviceBrowser : MCNearbyServiceBrowser
	
	weak var delegate : CommunicatorDelegate?

    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
	override init() {
        
        var userName : String!
        // Чтение с помощью GCD
        let queue = DispatchQueue.global(qos: .utility)
        queue.sync {
            let readerWriterGCD = GCDDataManager()
            let outputModel : DataModelOfUser = readerWriterGCD.readFiles()
            userName = outputModel.textName
        }
        
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: ["userName" : userName!], serviceType: serviceType)
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
	
    
    func sendMessage(string: String, to userID: MCPeerID, completionHandler:((Bool, Error?) -> ())?) {
        
        NSLog("%@", "send: \(string) to \(userID) peers")
        
        let messageId = self.generateMess()
        
        let json = ["eventType":"TextMessage","text":string,"messageId":messageId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(jsonData!, toPeers: [userID], with: .reliable)
                completionHandler!(true, nil)
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
                completionHandler!(true, error)
            }
        }
    }
    
    private func generateMess() -> String {
        return "\(arc4random_uniform(UINT32_MAX))+\(Date.timeIntervalSinceReferenceDate)".data(using: .utf8)!.base64EncodedString()
    }
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
		self.delegate?.didFoundUser(userID: peerID, userName: info?["userName"])
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
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        }
	}
	
	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {

		let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
        let dictionaryFromJson = responseJSON as! Dictionary<String, String>
        let textFromDictionary = dictionaryFromJson["text"]
        
        self.delegate?.didReceiveMessage(text: textFromDictionary!, fromUser: peerID.displayName, toUser: myPeerId.displayName)

	}
	
}
