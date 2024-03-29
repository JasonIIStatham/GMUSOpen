//
//  SRCTNetworkController.swift
//  WhatsOpen
//
//  Created by Patrick Murray on 26/10/2016.
//  Copyright © 2016 SRCT. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
import ObjectMapper

@available(iOSApplicationExtension 12.0, *)
public class WOPDownloadController: NSObject {
    //https://api.srct.gmu.edu/whatsopen/v2/facilities/?format=json
    public static func performDownload(completion: @escaping (_ result: List<WOPFacility>?) -> Void) {

    	let requestURL: NSURL = NSURL(string: "https://api.srct.gmu.edu/whatsopen/v2/facilities/?format=json")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL as URL)
        let session = URLSession.shared

		let task = session.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
			
			if(error != nil) {
				completion(nil)
				return
			}
			else {
				let httpResponse = response as! HTTPURLResponse
				let statusCode = httpResponse.statusCode
				if (statusCode == 200) {
                    networkCheck.network = true
					if let dataN = data {
						if let json = try? JSONSerialization.jsonObject(with: dataN, options: []) as? [[String: Any]] {
							// Map function to iterate through each JSON tree
							let facilities = json!.map({ (json) -> WOPFacility in
								let facility = WOPFacility()
								let map = Map(mappingType: .fromJSON, JSON: json, toObject: true, context: facility, shouldIncludeNilValues: true)
								facility.mapping(map: map)
								return facility
							})
							// This is where completion is called
							// Right after the array is done mapping all facility objects
							let list = List<WOPFacility>()
							list.append(objectsIn: facilities)
							completion(list)
						}
					}
				}
			}

    }
    task.resume()

    }
	
	public static func performAlertsDownload(completion: @escaping (_ result: List<WOPAlert>?) -> Void) {
		
		let requestURL: NSURL = NSURL(string: "https://api.srct.gmu.edu/whatsopen/v2/alerts/?format=json")!
		let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL as URL)
		let session = URLSession.shared
		
		let task = session.dataTask(with: urlRequest as URLRequest) {
			(data, response, error) -> Void in
			
			if(error != nil) {
				completion(nil)
				return
			}
			else {
				let httpResponse = response as! HTTPURLResponse
				let statusCode = httpResponse.statusCode
				if (statusCode == 200) {
					if let dataN = data {
						if let json = try? JSONSerialization.jsonObject(with: dataN, options: []) as? [[String: Any]] {
							// Map function to iterate through each JSON tree
							let alerts = json!.map({ (json) -> WOPAlert in
								let alert = WOPAlert()
								let map = Map(mappingType: .fromJSON, JSON: json, toObject: true, context: alert, shouldIncludeNilValues: true)
								alert.mapping(map: map)
								return alert
							})
							// This is where completion is called
							// Right after the array is done mapping all facility objects
							let list = List<WOPAlert>()
							list.append(objectsIn: alerts)
							completion(list)
						}
					}
				}
			}
			
		}
		task.resume()
		
	}

}
