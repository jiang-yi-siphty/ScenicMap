//
//	SLResponse.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport
//
//  Created by Yi JIANG on 12/3/18.
//  Copyright © 2018 Siphty. All rights reserved.
//

import Foundation 
import ObjectMapper

//Scenic Location Response: SLResponse
class SLResponse : NSObject, NSCoding, Mappable{

	var locations : [Location]?
	var updated : String?


	class func newInstance(map: Map) -> Mappable?{
		return SLResponse()
	}
	required init?(map: Map){}
	private override init(){}

	func mapping(map: Map)
	{
		locations <- map["locations"]
		updated <- map["updated"]
		
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         locations = aDecoder.decodeObject(forKey: "locations") as? [Location]
         updated = aDecoder.decodeObject(forKey: "updated") as? String

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
	{
		if locations != nil{
			aCoder.encode(locations, forKey: "locations")
		}
		if updated != nil{
			aCoder.encode(updated, forKey: "updated")
		}

	}

}
