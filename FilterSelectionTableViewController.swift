import UIKit
class FilterSelectionTableViewController: UITableViewController {
	var getFunc: (() -> [String: Bool])!
	var selectFunc: ((String, Bool) -> Bool)!
	var selectAllFunc: (() -> Bool)!
    var updateFacilities: (() -> Void)!
	var canSelectAll = true
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
		if navigationItem.title == "Alert Notifications" {
			return 2
		}
		return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section != 0 {
			return 1
		}
		if canSelectAll {
			return 1 + getFunc().count
		}
		return getFunc().count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section != 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "filterSelection", for: indexPath)
			cell.accessoryType = .disclosureIndicator
			cell.textLabel?.text = "Open Notifications Settings"
			return cell
		}
		let cell = tableView.dequeueReusableCell(withIdentifier: "filterSelection", for: indexPath)
		let values = getFunc()
		if(indexPath.row == 0 && canSelectAll) {
			cell.textLabel?.text = "Select All/None"
			cell.accessoryType = .none
		}
		else {
			var i: Int
			if canSelectAll {
				i = 1
			}
			else {
				i = 0
			}
			for v in values {
				if i == indexPath.row {
					cell.textLabel?.text = v.key.capitalized
					if(v.value == true) {
						cell.accessoryType = .checkmark
					}
					else {
						cell.accessoryType = .none
					}
					break
				}
				i += 1
			}
		}
        return cell
    }
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		if section != 0 && navigationItem.title == "Alert Notifications" {
			return "The above settings will only apply if you have notifications enabled for GMU's Open in Settings.\n\nBackground App Refresh is required in order to recieve notifications."
		}
		if navigationItem.title == "Show Alerts" {
			return "Emergency Alerts are always enabled in the app for your safety. We will never send a notification to your device without your consent."
		}
		else if navigationItem.title == "Select Maps App" {
			return "The app selected here will be used when opening a map from a facility's detail page."
		}
		return nil
	}
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section != 0 {
			UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, completionHandler: nil)
			let tableCell = tableView.cellForRow(at: indexPath)
			tableCell?.isSelected = false
			return
		}
		if(indexPath.row == 0) {
			_ = selectAllFunc()
			tableView.reloadData()
		}
		else {
			let tableCell = tableView.cellForRow(at: indexPath)
			var res: Bool
			if(tableCell?.accessoryType == UITableViewCell.AccessoryType.none) {
				res = true
			}
			else {
				res = false
			}
			_ = selectFunc((tableCell?.textLabel?.text)!.lowercased(), res)
			tableView.reloadData()
		}
        updateFacilities()
	}
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if(segue.identifier == "toSelection") {
			let destination = segue.destination as! FiltersTableViewController
			destination.tableView.reloadData()
		}
    }
}
