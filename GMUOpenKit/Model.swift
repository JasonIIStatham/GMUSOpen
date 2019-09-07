// This file was generated by json2swift. https://github.com/ijoshsmith/json2swift

import Foundation
import RealmSwift
import ObjectMapper
import ObjectMapper_Realm
import Intents
//
// MARK: - Data Model
//

public enum WOPDay: Int {
    case Monday = 0
    case Tuesday = 1
    case Wednesday = 2
    case Thursday = 3
    case Friday = 4
    case Saturday = 5
    case Sunday = 6

    // Add functions here later if we need them
}

public struct networkCheck {
	public static var network = true
}

@available(iOSApplicationExtension 12.0, *)
public class WOPFacility: Object, MapContext, Mappable {
    @objc public dynamic var slug = ""
    @objc public dynamic var facilityName = ""
    @objc public dynamic var facilityLocation: WOPLocations? = WOPLocations()
    @objc public dynamic var category: WOPCategories? = WOPCategories()
	public var facilityTags: List<WOPFacilityTag>?  = List<WOPFacilityTag>()
    @objc public dynamic var mainSchedule: WOPSchedule? = WOPSchedule()
	public var specialSchedules: List<WOPSchedule>? = List<WOPSchedule>()
	public var labels: List<WOPFacilityTag>? = List<WOPFacilityTag>()
	@objc public dynamic var tapingoURL = ""
	@objc public dynamic var note = ""
	@objc public dynamic var logoURL = ""
	
	required convenience public init?(map: Map) {
        self.init()
    }
	public func mapping(map: Map){
        slug <- map["slug"]
        facilityName <- map["facility_name"]
        facilityLocation <- map["facility_location"]
        category <- map["facility_category"]
        facilityTags <- (map["facility_product_tags"], TagTransform())
        mainSchedule <- map["main_schedule"]
        specialSchedules <- (map["special_schedules"], ListTransform<WOPSchedule>())
		labels <- (map["facility_labels"], TagTransform())
		tapingoURL <- map["tapingo_url"]
		note <- map["note"]
		logoURL <- map["logo"]
		
		
    }
	
	public func createIntent() -> WOPViewFacilityIntent {
		let viewFacilityIntent = WOPViewFacilityIntent()
		viewFacilityIntent.facility = INObject(identifier: self.slug, display: self.facilityName)
		viewFacilityIntent.name = self.facilityName
		viewFacilityIntent.suggestedInvocationPhrase = "Is \(facilityName) open?"
		
		return viewFacilityIntent
	}

}

public class WOPLocations: Object, Mappable {
    @objc public dynamic var id = 0
    @objc public dynamic var created = ""
    @objc public dynamic var lastmodified = ""
    @objc public dynamic var building = ""
    @objc public dynamic var address = ""
    @objc public dynamic var campus = ""
    @objc public dynamic var onCampus = false
    @objc public dynamic var abbreviation = ""
	@objc public dynamic var coordinates: WOPCoordinates? = WOPCoordinates()

	required convenience public init?(map: Map){
		self.init()
    }
	
	public func mapping(map: Map){
        id <- map["id"]
        created <- map["created"]
        lastmodified <- map["modified"]
        building <- map["building"]
        address <- map["address"]
        campus <- map["campus_region"]
        onCampus <- map["on_campus"]
        abbreviation <- map["friendly_building"]
		coordinates <- map["coordinate_location"]
    }
	
	func equals(_ another: WOPLocations) -> Bool {
		if  self.building == another.building &&
		    self.address == another.address &&
		    self.campus == another.campus &&
			self.onCampus == another.onCampus {
			return true
		}
		else {
			return false
		}
	}

}

public class WOPCoordinates: Object, Mappable {
	public var coords: List<Double>? = List<Double>()
	@objc public dynamic var type = ""
	
	required convenience public init?(map: Map){
		self.init()
	}
	
	public func mapping(map: Map) {
		coords <- (map["coordinates"], CoordTransform())
		type <- map["type"]
	}
}

public class WOPCategories: Object, Mappable {
    @objc public dynamic var id = 0
    @objc public dynamic var created = ""
    @objc public dynamic var modified = ""
    @objc public dynamic var categoryName = ""

	required convenience public init?(map: Map){
        self.init()
    }
	public func mapping(map: Map){
        id <- map["id"]
        created <- map["created"]
        modified <- map["modified"]
        categoryName <- map["name"]
    }
	
	func equals(_ another: WOPCategories) -> Bool {
		return another.categoryName == self.categoryName
	}

}

public class WOPFacilityTag: Object, Mappable {
    @objc public dynamic var tag = ""
	
	
	required convenience public init?(map: Map){
		self.init()
	}
	
	public func mapping(map: Map) {
		tag <- map["facility_product_tags"]
		tag <- map["facility_labels"]
	}

	
}

public class WOPSchedule: Object, Mappable {
    @objc public dynamic var id = 0
    public var openTimes = List<WOPOpenTimes>()
    @objc public dynamic var lastModified = ""
    @objc public dynamic var name = ""
    @objc public dynamic var validStart = ""
    @objc public dynamic var validEnd = ""
    @objc public dynamic var twentyFourHours = false


	required convenience public init?(map: Map){
        self.init()
    }

	public func mapping(map: Map){
        id <- map["id"]
        // This is a way around mapping to a list object
        var openTimesList: [WOPOpenTimes]?
        openTimesList <- map["open_times"]
        if let openTimesList = openTimesList {
            for openTime in openTimesList {
                self.openTimes.append(openTime)
            }
        }
        lastModified <- map["modified"]
        name <- map["name"]
        validStart <- map["valid_start"]
        validEnd <- map["valid_end"]
        twentyFourHours <- map["twenty_four_hours"]
    }
}

public class WOPSpecialSchedule: Object, Mappable {

	convenience required public init?(map: Map) {
        self.init()
    }

    @objc public dynamic var id = 0
    public var openTimes = List<WOPOpenTimes>()
    @objc public dynamic var lastModified = ""
    @objc public dynamic var name = ""
    @objc public dynamic var validStart = ""
    @objc public dynamic var validEnd = ""
    @objc public dynamic var twentyFourHours = false

	public func mapping(map: Map){
        id <- map["id"]
        // This is a way around mapping to a list object
        var openTimesList: [WOPOpenTimes]?
        openTimesList <- map["open_times"]
        if let openTimesList = openTimesList {
            for openTime in openTimesList {
                self.openTimes.append(openTime)
            }
        }
        lastModified <- map["modified"]
        name <- map["name"]
        validStart <- map["valid_start"]
        validEnd <- map["valid_end"]
        twentyFourHours <- map["twenty_four_hours"]
    }

}


public class WOPOpenTimes: Object, Mappable {
    @objc public dynamic var schedule = 0
    @objc public dynamic var lastModified = ""
    @objc public dynamic var startDay = 0
    @objc public dynamic var endDay = 0
    @objc public dynamic var startTime = ""
    @objc public dynamic var endTime = ""

	convenience required public init?(map: Map) {
        self.init()
    }

	public func mapping(map: Map){
        schedule <- map["schedule"]
        lastModified <- map["modified"]
        startDay <- map["start_day"]
        endDay <- map["end_day"]
        startTime <- map["start_time"]
        endTime <- map["end_time"]
    }

}

public class WOPAlert: Object, MapContext, Mappable {
	@objc public dynamic var id = 0
	@objc public dynamic var created = ""
	@objc public dynamic var lastModified = ""
	@objc public dynamic var urgency = ""
	@objc public dynamic var subject = ""
	@objc public dynamic var body = ""
	@objc public dynamic var url = ""
	@objc public dynamic var message = ""
	@objc public dynamic var startDate = ""
	@objc public dynamic var endDate = ""
	
	convenience required public init?(map: Map) {
		self.init()
	}
	
	public func mapping(map: Map){
		id <- map["id"]
		created <- map["created"]
		lastModified <- map["modified"]
		urgency <- map["urgency_tag"]
		subject <- map["subject"]
		body <- map["body"]
		message <- map["url"]
		message <- map["message"]
		startDate <- map["start_datetime"]
		endDate <- map["end_datetime"]
	}
    
    public func noNetwork(){
        urgency = "emergency"
        message = "No Internet Connection"
    }
    
}


// Updated for Swift 4, based on https://gist.github.com/Jerrot/fe233a94c5427a4ec29b but I removed the generics sorry code reuse
class TagTransform : TransformType {
	typealias Object = List<WOPFacilityTag>
	typealias JSON = [String]
	
	func transformFromJSON(_ value: Any?) -> List<WOPFacilityTag>? {
		let result = List<WOPFacilityTag>()
		if let tempArr = value as! [String]? {
			for entry in tempArr {
				let tag = WOPFacilityTag()
				tag.tag = entry
				result.append(tag)
			}
		}
		return result
	}
	
	func transformToJSON(_ value: List<WOPFacilityTag>?) -> [String]? {
		if (value!.count > 0) {
			var result = [String]()
			for entry in value! {
				result.append(entry.tag)
			}
			return result
		}
		return nil
	}
}

class CoordTransform: TransformType {
	typealias Object = List<Double>
	typealias JSON = [String]
	
	func transformFromJSON(_ value: Any?) -> List<Double>? {
		let result = List<Double>()
		if let tempArr = value as! [Double]? {
			var count = 0
			for entry in tempArr {
				result.insert(entry, at: count)
				count += 1
			}
		}
		return result
	}
	
	func transformToJSON(_ value: List<Double>?) -> [String]? {
		if (value!.count > 0) {
			var result = [String]()
			for entry in value! {
				result.append("\(entry)")
			}
			return result
		}
		return nil
	}
	
}

//
// MARK: - JSON Utilities
//
/// Adopted by a type that can be instantiated from JSON data.
protocol CreatableFromJSON {
    /// Attempts to configure a new instance of the conforming type with values from a JSON dictionary.
    init?(json: [String: Any])
}

extension CreatableFromJSON {
    /// Attempts to configure a new instance using a JSON dictionary selected by the `key` argument.
    init?(json: [String: Any], key: String) {
        guard let jsonDictionary = json[key] as? [String: Any] else { return nil }
        self.init(json: jsonDictionary)
    }

    /// Attempts to produce an array of instances of the conforming type based on an array in the JSON dictionary.
    /// - Returns: `nil` if the JSON array is missing or if there is an invalid/null element in the JSON array.
    static func createRequiredInstances(from json: [String: Any], arrayKey: String) -> [Self]? {
        guard let jsonDictionaries = json[arrayKey] as? [[String: Any]] else { return nil }
        return createRequiredInstances(from: jsonDictionaries)
    }

    /// Attempts to produce an array of instances of the conforming type based on an array of JSON dictionaries.
    /// - Returns: `nil` if there is an invalid/null element in the JSON array.
    static func createRequiredInstances(from jsonDictionaries: [[String: Any]]) -> [Self]? {
        var array = [Self]()
        for jsonDictionary in jsonDictionaries {
            guard let instance = Self.init(json: jsonDictionary) else { return nil }
            array.append(instance)
        }
        return array
    }

    /// Attempts to produce an array of instances of the conforming type, or `nil`, based on an array in the JSON dictionary.
    /// - Returns: `nil` if the JSON array is missing, or an array with `nil` for each invalid/null element in the JSON array.
    static func createOptionalInstances(from json: [String: Any], arrayKey: String) -> [Self?]? {
        guard let array = json[arrayKey] as? [Any] else { return nil }
        return createOptionalInstances(from: array)
    }

    /// Attempts to produce an array of instances of the conforming type, or `nil`, based on an array.
    /// - Returns: An array of instances of the conforming type and `nil` for each invalid/null element in the source array.
    static func createOptionalInstances(from array: [Any]) -> [Self?] {
        return array.map { item in
            if let jsonDictionary = item as? [String: Any] {
                return Self.init(json: jsonDictionary)
            }
            else {
                return nil
            }
        }
    }
}

public extension Date {
    // Date formatters are cached because they are expensive to create. All cache access is performed on a serial queue.
    private static let cacheQueue = DispatchQueue(label: "DateFormatterCacheQueue")
    private static var formatterCache = [String: DateFormatter]()
    private static func dateFormatter(with format: String) -> DateFormatter {
        if let formatter = formatterCache[format] { return formatter }
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: NSTimeZone.local.secondsFromGMT())! // changed to be the user's local time.
        formatterCache[format] = formatter
        return formatter
    }

    static func parse(string: String, format: String) -> Date? {
        var formatter: DateFormatter!
        cacheQueue.sync { formatter = dateFormatter(with: format) }
        return formatter.date(from: string)
    }

    init?(json: [String: Any], key: String, format: String) {
        guard let string = json[key] as? String else { return nil }
        guard let date = Date.parse(string: string, format: format) else { return nil }
        self.init(timeIntervalSinceReferenceDate: date.timeIntervalSinceReferenceDate)
    }
}

public extension URL {
    init?(json: [String: Any], key: String) {
        guard let string = json[key] as? String else { return nil }
        self.init(string: string)
    }
}

extension Double {
    init?(json: [String: Any], key: String) {
        // Explicitly unboxing the number allows an integer to be converted to a double,
        // which is needed when a JSON attribute value can have either representation.
        guard let nsNumber = json[key] as? NSNumber else { return nil }
        self.init(_: nsNumber.doubleValue)
    }
}

extension Array where Element: NSNumber {
    // Convert integers to doubles, for example [1, 2.0] becomes [1.0, 2.0]
    // This is necessary because ([1, 2.0] as? [Double]) yields nil.
    func toDoubleArray() -> [Double] {
        return map { $0.doubleValue }
    }
}

extension Array where Element: CustomStringConvertible {
    func toDateArray(withFormat format: String) -> [Date]? {
        var dateArray = [Date]()
        for string in self {
            guard let date = Date.parse(string: String(describing: string), format: format) else { return nil }
            dateArray.append(date)
        }
        return dateArray
    }

    func toURLArray() -> [URL]? {
        var urlArray = [URL]()
        for string in self {
            guard let url = URL(string: String(describing: string)) else { return nil }
            urlArray.append(url)
        }
        return urlArray
    }
}

extension Array where Element: Any {
    func toOptionalValueArray<Value>() -> [Value?] {
        return map { ($0 is NSNull) ? nil : ($0 as? Value) }
    }

    func toOptionalDateArray(withFormat format: String) -> [Date?] {
        return map { item in
            guard let string = item as? String else { return nil }
            return Date.parse(string: string, format: format)
        }
    }

    func toOptionalDoubleArray() -> [Double?] {
        return map { item in
            guard let nsNumber = item as? NSNumber else { return nil }
            return nsNumber.doubleValue
        }
    }

    func toOptionalURLArray() -> [URL?] {
        return map { item in
            guard let string = item as? String else { return nil }
            return URL(string: string)
        }
    }
}
