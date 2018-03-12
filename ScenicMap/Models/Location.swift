//
//	Location.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport
//
//  Created by Yi JIANG on 12/3/18.
//  Copyright © 2018 Siphty. All rights reserved.
//

import Foundation 
import ObjectMapper


class Location : NSObject, NSCoding, Mappable {

	var lat : Float?
	var lng : Float?
	var name : String?


	class func newInstance(map: Map) -> Mappable?{
		return Location()
	}
	required init?(map: Map){}
	private override init(){}

	func mapping(map: Map)
	{
		lat <- map["lat"]
		lng <- map["lng"]
		name <- map["name"]
		
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         lat = aDecoder.decodeObject(forKey: "lat") as? Float
         lng = aDecoder.decodeObject(forKey: "lng") as? Float
         name = aDecoder.decodeObject(forKey: "name") as? String

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
	{
		if lat != nil{
			aCoder.encode(lat, forKey: "lat")
		}
		if lng != nil{
			aCoder.encode(lng, forKey: "lng")
		}
		if name != nil{
			aCoder.encode(name, forKey: "name")
		}

	}
    
    static func ==(lhs: Location, rhs: Location) -> Bool {
        guard lhs.lat == rhs.lat else { return false }
        guard lhs.lng == rhs.lng else { return false }
        guard lhs.name == rhs.name else { return false }
        return true
    }
    
}
