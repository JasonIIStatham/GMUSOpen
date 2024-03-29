import UIKit
import NotificationCenter
import GMUOpenKit
import RealmSwift
class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {
	let realm = try! Realm(configuration: WOPDatabaseController.getConfig())
	var facilitiesArray = List<WOPFacility>()
	@IBOutlet var tableView: UITableView!
	override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		let results = realm.objects(WOPFacilitiesModel.self)
		if results.count > 0 {
			let model = results[0]
			let facilities = model.facilities
			for facility in facilities {
				if WOPUtilities.isFavoriteFacility(facility) {
					facilitiesArray.append(facility)
				}
			}
		}
		tableView.reloadData()
		extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
	func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
		if activeDisplayMode == .expanded {
			self.preferredContentSize = tableView.contentSize
		} else {
			self.preferredContentSize = maxSize
		}
	}
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
		let results = realm.objects(WOPFacilitiesModel.self)
		if results.count > 0 {
			let model = results[0]
			let facilities = model.facilities
			for facility in facilities {
				if WOPUtilities.isFavoriteFacility(facility) {
					facilitiesArray.append(facility)
				}
			}
		}
		tableView.reloadData()
        completionHandler(NCUpdateResult.newData)
    }
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return facilitiesArray.count
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "todayWidgetCell", for: indexPath)
		let facility = facilitiesArray[indexPath.row]
		cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
		cell.textLabel!.text = facility.facilityName
		cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .body)
		let isopen = WOPUtilities.isOpen(facility: facility)
		if isopen {
			cell.detailTextLabel!.text = "Open"
		} else {
			cell.detailTextLabel!.text = "Closed"
		}
		return cell
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let facilityName = tableView.cellForRow(at: indexPath)?.textLabel?.text!
		let encodedName = facilityName!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
		let url = URL(string: "whatsopen://open/?facility=\(encodedName)")
		extensionContext?.open(url ?? URL(string: "whatsopen://")!, completionHandler: nil)
	}
}
