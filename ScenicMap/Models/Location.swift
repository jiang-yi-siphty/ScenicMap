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
    var comment : String? = nil


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
		comment <- map["comment"]
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
        comment = aDecoder.decodeObject(forKey: "comment") as? String
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
        if comment != nil{
            aCoder.encode(comment, forKey: "comment")
        }

	}
    
    override var hashValue : Int {
        var hashValueString = "\(lat ?? 0)"
        hashValueString += "\(lng ?? 0)"
        hashValueString += name ?? ""
        return hashValueString.hashValue
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? Location {
            return self.hashValue == other.hashValue
        } else {
            return false
        }
    }
    
    
}
