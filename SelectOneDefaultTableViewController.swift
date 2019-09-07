import UIKit
import GMUOpenKit
class SelectOneDefaultTableViewController: UITableViewController {
	var options: [String]!
	var defaultKey: String!
	let defaults = WOPDatabaseController.getDefaults()
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
		return options.count
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "thereCanOnlyBeOne", for: indexPath)
		cell.textLabel?.text = options[indexPath.row]
		if defaults.value(forKey: defaultKey) as! String == options[indexPath.row] {
			cell.accessoryType = .checkmark
		}
		else {
			cell.accessoryType = .none
		}
		return cell
	}
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		if navigationItem.title == "Select Maps App" {
			return "The app selected here will be used when opening a map from a facility's detail page."
		}
		return nil
	}
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		defaults.set(tableView.cellForRow(at: indexPath)?.textLabel?.text, forKey: defaultKey)
		tableView.reloadData()
	}
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if(segue.identifier == "toSelection") {
			let destination = segue.destination as! FiltersTableViewController
			destination.tableView.reloadData()
		}
	}
}
