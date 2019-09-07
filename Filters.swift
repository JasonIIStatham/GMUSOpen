import Foundation
import RealmSwift
@available(iOSApplicationExtension 12.0, *)
public class WOPFilters {
    public var showOpen = true
    public var showClosed = true
	public var sortBy = WOPSortMethod.alphabetical
    public var openFirst = true
	public var showAlerts = ["Informational":true, "Minor Alerts":true, "Major Alerts":true]
    public var onlyFromLocations = [String: Bool]() 
    public var onlyFromCategories = [String: Bool]() 
	public var onlyFromCampuses = [String: Bool]() 
    public init() {
    }
    public func applyFiltersOnFacilities(_ facilities: List<WOPFacility>) -> List<WOPFacility> {
		let specifiedFacilities = List<WOPFacility>()
        for f in facilities {
            if  onlyFromLocations[(f.facilityLocation?.building)!.lowercased()] == true && onlyFromCategories[(f.category?.categoryName)!.lowercased()] == true {
                specifiedFacilities.append(f)
            }
        }
        let (open, closed) = separateOpenAndClosed(specifiedFacilities)
        switch sortBy {
        case .alphabetical:
            if(openFirst) {
				let returning = List<WOPFacility>()
                if(showOpen) {
                    returning.append(objectsIn: sortAlphabetically(open))
                }
                if(showClosed) {
                    returning.append(objectsIn: sortAlphabetically(closed))
                }
                return returning
            }
            else {
                if(showOpen && showClosed) {
                    return sortAlphabetically(facilities)
                }
                else if(showOpen) {
                    return sortAlphabetically(open)
                }
                else if(showClosed) {
                    return sortAlphabetically(closed)
                }
                else {
                    return List<WOPFacility>()
                }
            }
        case .reverseAlphabetical:
            if(openFirst) {
				let returning = List<WOPFacility>()
                if(showOpen) {
                    returning.append(objectsIn: sortAlphabetically(open, reverse: true))
                }
                if(showClosed) {
                    returning.append(objectsIn: sortAlphabetically(closed, reverse: true))
                }
                return returning
            }
            else {
                if(showOpen && showClosed) {
                    return sortAlphabetically(facilities, reverse: true)
                }
                else if(showOpen) {
                    return sortAlphabetically(open, reverse: true)
                }
                else if(showClosed) {
                    return sortAlphabetically(closed, reverse: true)
                }
                else {
                    return List<WOPFacility>()
                }
            }
        case .byLocation:
            if(openFirst) {
				let returning = List<WOPFacility>()
                if(showOpen) {
                    returning.append(objectsIn: sortByLocation(open))
                }
                if(showClosed) {
                    returning.append(objectsIn: sortByLocation(closed))
                }
                return returning
            }
            else {
                if(showOpen && showClosed) {
                    return sortByLocation(facilities)
                }
                else if(showOpen) {
                    return sortByLocation(open)
                }
                else if(showClosed) {
                    return sortByLocation(closed)
                }
                else {
                    return List<WOPFacility>()
                }
            }
        }
    }
    private func separateOpenAndClosed(_ facilities: List<WOPFacility>) -> (open: List<WOPFacility>, closed: List<WOPFacility>) {
        let open = List<WOPFacility>()
        let closed = List<WOPFacility>()
		for facility in facilities {
			if WOPUtilities.isOpen(facility: facility) {
				open.append(facility)
			}
			else {
				closed.append(facility)
			}
		}
        return (open, closed)
    }
    private func sortAlphabetically(_ facilities: List<WOPFacility>, reverse: Bool = false) -> List<WOPFacility> {
        var facilitiesArray = facilities.asArray()
		if !reverse {
			facilitiesArray.sort { $0.facilityName < $1.facilityName }
		}
		else {
			facilitiesArray.sort { $0.facilityName > $1.facilityName }
		}
        return facilitiesArray.asRealmList()
    }
    private func sortByLocation(_ facilities: List<WOPFacility>) -> List<WOPFacility> {
        var facilitiesArray = facilities.asArray()
        facilitiesArray.sort { (facility, nextFacility) in
            guard let location = facility.facilityLocation else { return true }
            guard let nextLocation = nextFacility.facilityLocation else { return false }
            return location.building < nextLocation.building
        }
        return facilitiesArray.asRealmList()
    }
    public func setShowOpen(_ to: Bool) -> Bool {
        showOpen = to
        return true
    }
    public func setShowClosed(_ to: Bool) -> Bool {
        showClosed = to
        return true
    }
    public func setOpenFirst(_ to: Bool) -> Bool {
        openFirst = to
        return true
    }
    public func setCategory(_ category: String?, to: Bool) -> Bool{
        if(category != nil) {
            onlyFromCategories[category!] = to
            return true
        }
        else {
            return false
        }
    }
    public func setLocation(_ location: String?, to: Bool) -> Bool{
        if(location != nil) {
            onlyFromLocations[location!] = to
            return true
        }
        else {
            return false
        }
    }
}
public enum WOPSortMethod {
	case alphabetical 
	case reverseAlphabetical 
	case byLocation 
    public static var count = 3 
}
public extension Array where Element: RealmCollectionValue {
    func asRealmList() -> List<Element> {
        return self.reduce(into: List<Element>()) { (list, element) in
            list.append(element)
        }
    }
}
public extension List {
    func asArray() -> [Element] {
        return self.reduce(into: [Element]()) { (array, element) in
            array.append(element)
        }
    }
}
@available(iOSApplicationExtension 12.0, *)
func filterByLocation(_ facilities: [WOPFacility], filters: WOPFilters) -> [WOPFacility] {
	return facilities.filter { filters.onlyFromLocations[($0.facilityLocation?.building)!.lowercased()] ?? false }
}
