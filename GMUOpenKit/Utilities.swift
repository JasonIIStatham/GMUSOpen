//
//  SRCTUtilities.swift
//  WhatsOpen
//
//  Created by Patrick Murray on 20/11/2016.
//  Copyright © 2016 SRCT. Some rights reserved.
//

import Foundation
import UserNotifications

@available(iOSApplicationExtension 12.0, *)
public class WOPUtilities: NSObject {

    public static func isOpen(facility: WOPFacility) -> Bool {
        var open = false
		let current = getCurrentSchedule(facility)
		if current!.twentyFourHours {
		  	return true
	  	}
	  	if !(current!.openTimes.isEmpty) {
			if today(facility: facility) != nil {
				open = time(facility)
			}
	  	}
		else {
			open = false
		}

        return open
    }

    public static func getDayOfWeek(_ day: WOPDay, small: Bool = false) -> String? {
        if !small {
            switch day {
            case .Monday:
                return "Monday"
            case .Tuesday:
                return "Tuesday"
            case .Wednesday:
                return "Wednesday"
            case .Thursday:
                return "Thursday"
            case .Friday:
                return "Friday"
            case .Saturday:
                return "Saturday"
            case .Sunday:
                return "Sunday"
            }
        }
        else {
            switch day {
            case .Monday:
                return "Mon"
            case .Tuesday:
                return "Tue"
            case .Wednesday:
                return "Wed"
            case .Thursday:
                return "Thu"
            case .Friday:
                return "Fri"
            case .Saturday:
                return "Sat"
            case .Sunday:
                return "Sun"
            }
        }

    }
    
    public static func getCurrentDayOfWeek() -> Int? {
        let todayDate    = NSDate()
        let myCalendar   = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let myComponents = myCalendar?.components(.weekday, from: todayDate as Date)
        let weekDay      = myComponents?.weekday
        let pyweekDay    = (5 + weekDay!) % 7
        return pyweekDay
    }

    public static func getCurrentTime() -> Date {
        let currentDate   = Date()

        let dateFormatter = DateFormatter.easternCoastTimeFormat

        let stringDate    = dateFormatter.string(from: currentDate)
        let formattedDate = dateFormatter.date(from: stringDate)

        return formattedDate!
    }

    //Gets the current day of the week.
    public static func today(facility: WOPFacility, special: Bool = false) -> WOPOpenTimes? {
        let scheduleOpenTimes = getCurrentSchedule(facility)?.openTimes

        let currentDay = getCurrentDayOfWeek()
		for openTime in scheduleOpenTimes! {
			if(currentDay! >= openTime.startDay && currentDay! <= openTime.endDay) {
				return openTime
			}
		}
        return nil
    }

    public static func getStartEndDates(_ facility: WOPFacility) -> (startTime: Date, endTime: Date)? {
        let dateFormatter = DateFormatter.easternCoastTimeFormat
        // 24 Hour Case
        if self.isMainSchedule(facility: facility) && facility.mainSchedule!.twentyFourHours {
            let startDate = Date.startOfCurrentDay()
            let endDate   = Date.endOfCurrentDay()
            return (startDate, endDate)
        }
        if let today = self.today(facility: facility) {
            let startTime = today.startTime
            let endTime   = today.endTime

            let formattedStartTime     = dateFormatter.date(from: startTime)
            let formattedEndTimeDate   = dateFormatter.date(from: endTime)

            guard let startTimeDate = formattedStartTime, let endTimeDate = formattedEndTimeDate else { return nil }
            return (startTimeDate, endTimeDate)
        }
        return nil
    }

    public static func time(_ facility: WOPFacility) -> Bool {
        let nowTime        = getCurrentTime()
        guard let startEnd = getStartEndDates(facility) else { return false }
        let startTime      = startEnd.startTime
        var endTime        = startEnd.endTime
        if endTime < startTime {
            endTime = Date.endOfCurrentDay()
            if nowTime > Date.startOfCurrentDay() && nowTime < startEnd.endTime {
                endTime = startEnd.endTime
            }
        }
        // Check if the current time is
        // In between the start & end time of the facility
        return (nowTime >= startTime) && nowTime <= (endTime)
    }

    public static func timeUntilFacility(_ facility: WOPFacility) -> String? {
        //var currentTime = getCurrentTime()
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.allowedUnits = [.year,.month,.weekOfYear,.day,.hour,.minute,.second]
        dateComponentsFormatter.maximumUnitCount = 1
        dateComponentsFormatter.unitsStyle = .full
        let startEnd = getStartEndDates(facility)
		let current = getCurrentSchedule(facility)
		if current!.twentyFourHours {
            return "Open all day"
        }
		if(WOPUtilities.isOpen(facility: facility)) {
            // Might be a better way of doing this, but for now, this works.
            if(isMainSchedule(facility: facility)) {
                if(!current!.openTimes.isEmpty) {
                    if startEnd != nil {
                        let time = dateComponentsFormatter.string(from: getCurrentTime(), to: (startEnd!.endTime))
                        return "Closes in \(time!)"
                    }
            	}
			//Eventually add more detailled text here, allowing for more custom
			//messages as it gets closer to closing time
        } else {
                if startEnd != nil {
                    let time = dateComponentsFormatter.string(from: getCurrentTime(), to: (startEnd!.startTime)) //This line doesn't work pls fix
                    return "Opens in \(time!)."
                }

        }

        } else {
            return "Closed"
        }
        return nil
    }
	
	public static func openOrClosedUntil(_ facility: WOPFacility, includePreamble: Bool = true) -> String? {
        let viewingFormatter = DateFormatter.easternCoastTimeFormatForViewing

        let startEnd = getStartEndDates(facility)
		let current = getCurrentSchedule(facility)
        if current!.twentyFourHours {
			if includePreamble {
				return "Open all day"
			} else {
				return nil
			}
        }
        if(WOPUtilities.isOpen(facility: facility)) {
            // Might be a better way of doing this, but for now, this works.
			if(!current!.openTimes.isEmpty) {
				if startEnd != nil {
					let time = viewingFormatter.string(from: startEnd!.endTime)
					if includePreamble {
						return "Open until \(time)"
					} else {
						return time
					}
					
				}
			}
			//Eventually add more detailled text here, allowing for more custom
			//messages as it gets closer to closing time
        } else {
			if startEnd != nil {
				let time = viewingFormatter.string(from: startEnd!.startTime)
				if includePreamble {
					return "Closed until \(time)"
				} else {
					return time
				}
				
			} else {
				if includePreamble {
					return "Closed"
				} else {
					return nil
				}
				
			}
        }
        return nil
    }
    
    public static func getFormattedStartandEnd(_ openTime: WOPOpenTimes) -> String? {
        //Is it inelegant to go from string to date to string? maybe.
        //Does it work? absolutely.
        
        let dateFormatter = DateFormatter.easternCoastTimeFormat
        let startTime = dateFormatter.date(from: openTime.startTime)
        let endTime = dateFormatter.date(from: openTime.endTime)
        
        let viewingFormatter = DateFormatter.easternCoastTimeFormatForViewing
        var returning = viewingFormatter.string(from: startTime!) + " - "
        
        if(openTime.startDay != openTime.endDay) {
            returning += getDayOfWeek((WOPDay(rawValue: openTime.endDay))!, small: true)! + " "
        }
        
        returning += viewingFormatter.string(from: endTime!)
        
        return returning
    }

	/*
    static func isSpecialSchedule(_ facility: Facility) -> Bool {
		let special = facility.specialSchedule
		return !(special!.lastModified.isEmpty && special!.name.isEmpty && special!.validEnd.isEmpty && special!.validStart.isEmpty)
    }
	*/
	
	public static func getCurrentSchedule(_ facility: WOPFacility) -> WOPSchedule? {
		let formatter = ISO8601DateFormatter()
		let now = Date()
		if(facility.specialSchedules != nil) {
			for schedule in facility.specialSchedules! {
				if schedule.validStart == "" {
					dump(schedule)
				}
				let start = formatter.date(from: schedule.validStart)
				let end = formatter.date(from: schedule.validEnd)

				if start! < now && end! > now {
					return schedule
				}
			}
		}
		return facility.mainSchedule
	}

    public static func isMainSchedule(facility: WOPFacility) -> Bool {
        return facility.mainSchedule != nil
    }
    
    //MARK - Favorite facilities
    
    /**
     Checks if a facility is a favorite.
     
     - returns:
        true if the facility is a favorite, false if it isn't
     */
    public static func isFavoriteFacility(_ facility: WOPFacility) -> Bool {
		let defaults = WOPDatabaseController.getDefaults()
        let favoriteStrings = defaults.array(forKey: "favorites") as! [String]?
		if( favoriteStrings == nil ) {
			return false
		}
        // return if the facility's name is in the list of favorites
        return favoriteStrings!.contains { (favorite: String) -> Bool in
            return facility.facilityName == favorite
        }
    }
	
    /**
     Adds a facility to the UserDefault's favorites list.
     
     - returns:
        true if the facility was added correctly, false if the facility is already a favorite.
     */
    public static func addFavoriteFacility(_ facility: WOPFacility) -> Bool {
		if(isFavoriteFacility(facility)) {
			return false
		}
		else {
		  let defaults = WOPDatabaseController.getDefaults()
		  var favoriteStrings = defaults.array(forKey: "favorites") as! [String]?
		  if(favoriteStrings == nil) {
			  favoriteStrings = []
		  }
		  favoriteStrings?.append(facility.facilityName)
		  defaults.set(favoriteStrings, forKey: "favorites")
		  return true
		}
    }
    
    /**
     Removes a facility from the UserDefault's favorites list.
     
     - returns:
        true if the facility was removed correctly, false if the facility is not a favorite.
     */
    public static func removeFavoriteFacility(_ facility: WOPFacility) -> Bool {
        if(isFavoriteFacility(facility)) {
			let defaults = WOPDatabaseController.getDefaults()
            var favoriteStrings = defaults.array(forKey: "favorites") as! [String]
            let removing = favoriteStrings.index(of: facility.facilityName)
            favoriteStrings.remove(at: removing!)
            defaults.set(favoriteStrings, forKey: "favorites")
			return true
        }
        else {
            return false
        }
    }
	
	// MARK - Persistent Alerts
	
	/**
	Sets alerts settings in User Defaults
	
	- returns:
	true if the alerts was added correctly.
	*/
	public static func setAlertDefaults(_ key: String, value: Bool) -> Bool {
		let defaults = WOPDatabaseController.getDefaults()
		var alerts = defaults.dictionary(forKey: "alerts") as! [String: Bool]?
		if alerts != nil {
			alerts!.updateValue(value, forKey: key)
			defaults.set(alerts, forKey: "alerts")
			return true
		}
		else {
			return false
		}
	}
	
	/**
	Sets all alerts settings in User Defaults to true
	
	- returns:
	true if the alerts was changed correctly, false if nil was retrieved from User Defaults.
	*/
	public static func setAllAlertDefaults() -> Bool {
		let defaults = WOPDatabaseController.getDefaults()
		var alerts = defaults.dictionary(forKey: "alerts") as! [String: Bool]?

		if alerts != nil {
			var foundFalse = false
			for a in alerts! {
				if a.value == false {
					foundFalse = true
					break
				}
			}
			for alert in alerts! {
				alerts!.updateValue(foundFalse, forKey: alert.key)
			}
			defaults.set(alerts, forKey: "alerts")
			return true
		}
		else {
			return false
		}
	}
	
	/**
	Gets alerts settings in User Defaults
	
	- returns:
	item stored in User Defaults for key 'alerts'
	*/
	public static func getAlertDefaults() -> [String: Bool] {
		let defaults = WOPDatabaseController.getDefaults()
		let returning = defaults.dictionary(forKey: "alerts") as! [String: Bool]?
		if returning == nil {
			return [:]
		}
		else {
			return returning!
		}
	}
	
	// MARK - Persistent Campuses
	// Maybe we should have thought about code reuse when we made those alerts functions up there, hmm...
	
	/**
	Sets campus settings in User Defaults
	
	- returns:
	true if the campus was added correctly.
	*/
	public static func setCampusDefaults(_ key: String, value: Bool) -> Bool {
		let defaults = WOPDatabaseController.getDefaults()
		var campuses = defaults.dictionary(forKey: "campuses") as! [String: Bool]?
		if campuses != nil {
			campuses!.updateValue(value, forKey: key)
			defaults.set(campuses, forKey: "campuses")
			return true
		}
		else {
			return false
		}
	}
	
	/**
	Sets all campus settings in User Defaults to true
	
	- returns:
	true if the campuses were changed correctly, false if nil was retrieved from User Defaults.
	*/
	public static func setAllCampusDefaults() -> Bool {
		let defaults = WOPDatabaseController.getDefaults()
		var campuses = defaults.dictionary(forKey: "campuses") as! [String: Bool]?
		
		if campuses != nil {
			var foundFalse = false
			for a in campuses! {
				if a.value == false {
					foundFalse = true
					break
				}
			}
			for campus in campuses! {
				campuses!.updateValue(foundFalse, forKey: campus.key)
			}
			defaults.set(campuses, forKey: "campuses")
			return true
		}
		else {
			return false
		}
	}
	
	/**
	Gets alerts settings in User Defaults
	
	- returns:
	item stored in User Defaults for key 'campuses'
	*/
	public static func getCampusDefaults() -> [String: Bool] {
		let defaults = WOPDatabaseController.getDefaults()
		let returning = defaults.dictionary(forKey: "campuses") as! [String: Bool]?
		if returning == nil {
			return [:]
		}
		else {
			return returning!
		}
	}
	
	// MARK - Alert Notifications
	
	/**
	Sets alert notification settings in User Defaults
	
	- returns:
	true if the option was changed correctly.
	*/
	public static func setAlertNotificationDefaults(_ key: String, value: Bool) -> Bool {
		var returning = false
		let defaults = WOPDatabaseController.getDefaults()
		var alerts = defaults.dictionary(forKey: "notificationDefaults") as! [String: Bool]?
		if alerts != nil {
			alerts!.updateValue(value, forKey: key)
			defaults.set(alerts, forKey: "notificationDefaults")
			returning = true
		}
		
		return returning
	}
	
	/**
	Sets all alert notification settings in User Defaults to true
	
	- returns:
	true if the alerts was changed correctly, false if nil was retrieved from User Defaults.
	*/
	public static func setAllAlertNotificationDefaults() -> Bool {
		let defaults = WOPDatabaseController.getDefaults()
		var alerts = defaults.dictionary(forKey: "notificationDefaults") as! [String: Bool]?
		
		if alerts != nil {
			var foundFalse = false
			for a in alerts! {
				if a.value == false {
					foundFalse = true
					break
				}
			}
			for alert in alerts! {
				alerts!.updateValue(foundFalse, forKey: alert.key)
			}
			defaults.set(alerts, forKey: "notificationDefaults")
			return true
		}
		else {
			return false
		}
	}
	
	/**
	Gets alerts settings in User Defaults
	
	- returns:
	item stored in User Defaults for key 'notificationDefaults'
	*/
	public static func getAlertNotificationDefaults() -> [String: Bool] {
		let defaults = WOPDatabaseController.getDefaults()
		let returning = defaults.dictionary(forKey: "notificationDefaults") as! [String: Bool]?
		if returning == nil {
			return [:]
		}
		else {
			return returning!
		}
	}
	
}

extension DateFormatter {
    
    public static var easternCoastTimeFormat: DateFormatter {
        let dateFormatter        = DateFormatter()
        dateFormatter.timeZone   = TimeZone.current
        dateFormatter.locale     = Locale.current
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter
    }
    
    public static var easternCoastTimeFormatForViewing: DateFormatter {
        let dateFormatter        = DateFormatter()
        dateFormatter.timeZone   = TimeZone.current
        dateFormatter.locale     = Locale.current
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "hh:mm a", options: 0, locale: Locale.current)
        return dateFormatter
    }

}

public extension Date {
    public static func endOfCurrentDay() -> Date {
        let dateFormatter = DateFormatter.easternCoastTimeFormat
        let endDate = dateFormatter.date(from: "23:59:59")
        return endDate!
    }

    public static func startOfCurrentDay() -> Date {
        let dateFormatter = DateFormatter.easternCoastTimeFormat
        let startDate = dateFormatter.date(from: "00:00:00")
        return startDate!
    }
}
