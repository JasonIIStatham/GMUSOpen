import UIKit
class SetIconTableViewController: UITableViewController {
	var secretCount = 0
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "setIcon", for: indexPath) as! IconSelectionTableViewCell
		switch indexPath.row {
		case 0:
			setCellInfo(nil, display: "Default", cell: cell)
		case 1:
			setCellInfo("srct", display: "SRCT Logo", cell: cell)
		case 2:
			setCellInfo("1009", display: "Morning", cell: cell)
		case 3:
			setCellInfo("420", display: "Afternoon", cell: cell)
		case 4:
			setCellInfo("730", display: "Meeting Time", cell: cell)
		case 5:
			setCellInfo("opensign", display: "Come On In", cell: cell)
		case 6:
			setCellInfo("closedsign", display: "Sorry, We're Closed", cell: cell)
		case 7:
			setCellInfo("pride", display: "Pride Rainbow", cell: cell)
		case 8:
			setCellInfo("sixcolors", display: "Six Colors", cell: cell)
		default:
			setCellInfo(nil, display: "Default", cell: cell)
		}
        return cell
    }
	func setCellInfo(_ name: String?, display: String, cell: IconSelectionTableViewCell) {
		if(name == nil) {
			cell.iconThumbnail.image = UIImage(named: "appicon-thumbnail")
		}
		else {
			cell.iconThumbnail.image = UIImage(named: "\(name!)-thumbnail")
		}
		cell.iconName.text = display
		if UIApplication.shared.alternateIconName == name {
			cell.accessoryType = .checkmark
		}
		else {
			cell.accessoryType = .none
		}
	}
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.row {
		case 0:
			if secretCount < 4 {
				setIcon(nil)
				secretCount += 1
			}
			else if secretCount == 4{
				setIcon("pizza")
				secretCount += 1
			}
			else {
				setIcon("dhaynes")
				secretCount = 0
			}
		case 1:
			setIcon("srct")
		case 2:
			setIcon("1009")
		case 3:
			setIcon("420")
		case 4:
			setIcon("730")
		case 5:
			setIcon("opensign")
		case 6:
			setIcon("closedsign")
		case 7:
			setIcon("pride")
		case 8:
			setIcon("sixcolors")
		case 9:
			setIcon("pizza")
		default:
			setIcon(nil)
		}
		tableView.reloadData()
	}
	func setIcon(_ name: String?) {
		UIApplication.shared.setAlternateIconName(name) { (error) in
			if let error = error {
				print("err: \(error)")
			}
		}
	}
}
