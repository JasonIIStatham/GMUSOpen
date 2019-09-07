import UIKit
import SafariServices
import MessageUI
import StoreKit
import UserNotifications
import GMUOpenKit
class SettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .default
	}
	@IBAction func doneButton(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	override func viewWillAppear(_ animated: Bool) {
		tableView.reloadData()
	}
	@objc func toNotifications(_ notification: Notification?) {
		let destination = self.storyboard?.instantiateViewController(withIdentifier: "filtersVC") as! FilterSelectionTableViewController
		destination.navigationItem.title = "Alert Notifications"
		destination.getFunc = WOPUtilities.getAlertNotificationDefaults
		destination.selectFunc = WOPUtilities.setAlertNotificationDefaults
		destination.selectAllFunc = WOPUtilities.setAllAlertNotificationDefaults
		destination.updateFacilities = updateFacilities
		self.show(destination, sender: self)
	}
    override func viewDidLoad() {
        super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(toNotifications(_:)), name: NSNotification.Name(rawValue: "openNotificationsPane"), object: nil)
		tableView.estimatedRowHeight = 44.0
		tableView.rowHeight = UITableView.automaticDimension
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if(section == 0) {
			return 1
		}
		else if(section == 1) {
			return 1
		}
		else if(section == 2) {
			return 2
		}
		else if(section == 3) {
			return 1
		}
		else if(section == 4) {
			return 2
		}
		else {
			return 0
		}
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.section {
		case 0:
			let cell = tableView.dequeueReusableCell(withIdentifier: "Setting", for: indexPath) as! SettingTableViewCell
			cell.textLabel!.text = "Are Our Hours Wrong?"
			return cell
		case 1:
				let cell = tableView.dequeueReusableCell(withIdentifier: "settingDefaultCell", for: indexPath)
				cell.textLabel!.text = "Select Maps App"
				cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
				cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .footnote)
				cell.detailTextLabel?.text = WOPDatabaseController.getDefaults().value(forKey: "mapsApp") as? String
				cell.accessoryType = .disclosureIndicator
				return cell
		case 2:
			let cell = tableView.dequeueReusableCell(withIdentifier: "settingSelection", for: indexPath)
			cell.accessoryType = .disclosureIndicator
			switch indexPath.row {
			case 0:
				cell.textLabel?.text = "Show Alerts"
            	cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
            	cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .footnote)
				let alerts = WOPUtilities.getAlertDefaults()
				var i = 0
				for c in alerts {
					if(c.value == true) {
						i += 1
					}
				}
				var detail: String
				if(i == alerts.count) {
					detail = "All Selected"
				}
				else {
					detail = "\(i) Selected"
				}
				cell.detailTextLabel?.text = detail
				return cell
			case 1:
				cell.textLabel?.text = "Show Campuses"
				cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
            	cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .footnote)
				let campuses = WOPUtilities.getCampusDefaults()
				var i = 0
				for c in campuses {
					if(c.value == true) {
						i += 1
					}
				}
				var detail: String
				if(i == campuses.count) {
					detail = "All Selected"
				}
				else {
					detail = "\(i) Selected"
				}
				cell.detailTextLabel?.text = detail
				return cell
			default:
				return UITableViewCell() 
			}
		case 3:
			let cell = tableView.dequeueReusableCell(withIdentifier: "Setting", for: indexPath) as! SettingTableViewCell
			cell.textLabel!.text = "Alert Notifications"
			cell.accessoryType = .disclosureIndicator
			return cell
		case 4:
			let cell = tableView.dequeueReusableCell(withIdentifier: "Setting", for: indexPath) as! SettingTableViewCell
			switch indexPath.row {
			case 0:
				cell.textLabel!.text = "Review on the App Store"
			case 1:
				cell.textLabel!.text = "About GMU's Open"
			default:
				cell.textLabel!.text = "rip"
			}
			return cell
		default:
			break
		}
        return tableView.dequeueReusableCell(withIdentifier: "Setting", for: indexPath) as! SettingTableViewCell 
    }
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cell = self.tableView(tableView, cellForRowAt: indexPath)
		if let settingcell = cell as? SettingTableViewCell {
			if settingcell.linkURL != nil {
				self.showDetailViewController(SFSafariViewController(url: settingcell.linkURL!), sender: settingcell)
			}
			else if settingcell.textLabel!.text == "Are Our Hours Wrong?" {
				let mailvc = initMail(subject: "GMU's Open - Your Hours are Wrong", to: "ciji1220410@mail.ru")
				if !MFMailComposeViewController.canSendMail() {
				}
				else {
					present(mailvc, animated: true)
				}
			} else if settingcell.textLabel?.text == "Alert Notifications" {
				let nc = UNUserNotificationCenter.current()
                if #available(iOS 12.0, *) {
                    nc.requestAuthorization(options: [.badge, .sound, .alert, .providesAppNotificationSettings]) { (authorized, error) in
                        if authorized {
                            DispatchQueue.main.async {
                                self.toNotifications(nil)
                            }
                        } else {
                            let alert = UIAlertController(title: "Notifications Are Disabled", message: "You can manage your preferred notification options inside Settings", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Configure in Settings", style: .default, handler: { (action) in
                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, completionHandler: nil)
                                alert.dismiss(animated: true, completion: nil)
                            }))
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                alert.dismiss(animated: true, completion: nil)
                            }))
                            DispatchQueue.main.async {
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                } else {
                }
			}
			else if settingcell.textLabel?.text == "Review on the App Store" {
				let appId = "1479272727"
				let urlString = "itms-apps://itunes.apple.com/us/app/GMU's-Open/id\(appId)?action=write-review"
				if let url = URL(string: urlString) {
					UIApplication.shared.open((url), options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
				}
			}
			else if settingcell.textLabel!.text == "About GMU's Open" {
				let avc = self.storyboard?.instantiateViewController(withIdentifier: "about")
				self.show(avc!, sender: settingcell)
			}
		}
		else {
			return
		}
	}
	func initMail(subject: String, to: String) -> MFMailComposeViewController {
		let mailto = MFMailComposeViewController()
		mailto.mailComposeDelegate = self
		mailto.setSubject(subject)
		mailto.setToRecipients([to])
		let df = DateFormatter()
		let now = Date()
		mailto.setMessageBody("\n\n"+df.string(from: now), isHTML: false)
		return mailto
	}
	func mailComposeController(_ controller: MFMailComposeViewController,
							   didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true, completion: nil)
	}
	func updateFacilities() {
		return
	}
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "settingSelection" {
			if (sender as! UITableViewCell).textLabel?.text == "Show Alerts" {
				let destination = segue.destination as! FilterSelectionTableViewController
				destination.navigationItem.title = "Show Alerts"
				destination.getFunc = WOPUtilities.getAlertDefaults
				destination.selectFunc = WOPUtilities.setAlertDefaults
				destination.selectAllFunc = WOPUtilities.setAllAlertDefaults
				destination.updateFacilities = updateFacilities
			}
			else if (sender as! UITableViewCell).textLabel?.text == "Show Campuses" {
				let destination = segue.destination as! FilterSelectionTableViewController
				destination.navigationItem.title = "Show Campuses"
				destination.getFunc = WOPUtilities.getCampusDefaults
				destination.selectFunc = WOPUtilities.setCampusDefaults
				destination.selectAllFunc = WOPUtilities.setAllCampusDefaults
				destination.updateFacilities = updateFacilities
			}
		}
		else if segue.identifier == "settingDefault" {
			if (sender as! UITableViewCell).textLabel?.text == "Select Maps App" {
				let destination = segue.destination as! SelectOneDefaultTableViewController
				destination.navigationItem.title = "Select Maps App"
				destination.defaultKey = "mapsApp"
				var options = ["Apple Maps"]
				if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
					options.append("Google Maps")
				}
				if UIApplication.shared.canOpenURL(URL(string:"waze://")!) {
					options.append("Waze")
				}
				destination.options = options
			}
		}
    }
}
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
