import UIKit
import MapKit
import GMUOpenKit
import Intents
import IntentsUI
class DetailViewButtonsViewController: UIViewController, INUIAddVoiceShortcutViewControllerDelegate {
	@IBOutlet var facilityDetailView: UIView!
	var detailViewController: WOPFacilityDetailViewController?
	var facility: WOPFacility!
	@IBOutlet var favoritesButton: UIButton!
	@IBOutlet var shareButton: UIButton!
	@IBOutlet var addToSiriButton: UIButton!
	let activity = NSUserActivity(activityType: "facility")
	let feedback = UISelectionFeedbackGenerator()
	@IBAction func setFavButton(_ sender: Any) {
		feedback.selectionChanged()
		if(WOPUtilities.isFavoriteFacility(facility)) { 
			_ = WOPUtilities.removeFavoriteFacility(facility) 
		}
		else { 
			_ = WOPUtilities.addFavoriteFacility(facility)
		}
		setFavoriteButtonText()		
	}
	func getDirections(_ sender: Any) {
		let appToUse = WOPDatabaseController.getDefaults().value(forKey: "mapsApp") as? String
		if appToUse == "Google Maps" && UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
			if let url = URL(string: "comgooglemaps://?q=\((facility.facilityLocation?.coordinates?.coords?.last)!)),\((facility.facilityLocation?.coordinates?.coords?.first)!)") {
				UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
			}
		}
		else if appToUse == "Waze" && UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
			if let url = URL(string: "https://waze.com/ul?ll=\((facility.facilityLocation?.coordinates?.coords?.last)!)),\((facility.facilityLocation?.coordinates?.coords?.first)!))") {
				UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
			}
		}
		else {
			let regionDistance:CLLocationDistance = 100
			let coordinates = CLLocationCoordinate2DMake((facility.facilityLocation?.coordinates?.coords?.last)!, (facility.facilityLocation?.coordinates?.coords?.first)!)
			dump(coordinates)
			let regionSpan = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
			let options = [
				MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
				MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
			]
			let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
			let mapItem = MKMapItem(placemark: placemark)
			mapItem.name = facility.facilityName
			mapItem.openInMaps(launchOptions: options)
		}
	}
	@IBAction func shareFacility(_ sender: Any) {
		feedback.selectionChanged()
		let str = "\(facility.facilityName) is \(WOPUtilities.openOrClosedUntil(facility)!.lowercased())"
		let shareSheet = UIActivityViewController(activityItems: [str, (URL(string: "itms-apps://itunes.apple.com/us/app/GMU's-Open/id1479272727?action=write-review") ?? nil), facility], applicationActivities: [ViewInMapsActionActivity()])
		shareSheet.excludedActivityTypes = [.print, .openInIBooks, .addToReadingList] 
		present(shareSheet, animated: true, completion: nil)
	}
	func setFavoriteButtonText() {
		if(WOPUtilities.isFavoriteFacility(facility)) {
			favoritesButton.accessibilityLabel = "Remove from Favorites"
			favoritesButton.titleLabel?.text = ""
			favoritesButton.setImage(UIImage(named: "heart_filled"), for: .normal)
		}
		else {
			favoritesButton.accessibilityLabel = "Add to Favorites"
			favoritesButton.titleLabel?.text = ""
			favoritesButton.setImage(UIImage(named: "heart_empty"), for: .normal)
		}
	}
	override func viewDidLoad() {
		self.detailViewController!.view.translatesAutoresizingMaskIntoConstraints = false
		self.addChild(self.detailViewController!)
		self.addSubview(self.detailViewController!.view, toView: self.facilityDetailView)
        super.viewDidLoad()
		setFavoriteButtonText()
		favoritesButton.tintColor = UIColor.white
		favoritesButton.backgroundColor = UIColor(red:0.12, green:0.51, blue:0.81, alpha:1.0)
		favoritesButton.layer.cornerRadius = 10
		shareButton.tintColor = UIColor.white
		shareButton.backgroundColor = UIColor.orange
		shareButton.layer.cornerRadius = 10
		shareButton.setImage(#imageLiteral(resourceName: "shareIcon"), for: .normal)
		shareButton.setTitle("", for: .normal)
		shareButton.accessibilityLabel = "Share"
		setActivityUp()
		addToSiriButton.tintColor = UIColor.white
		addToSiriButton.backgroundColor = UIColor.black
		addToSiriButton.layer.cornerRadius = 10
		addToSiriButton.accessibilityLabel = "Add to Siri"
		let interaction = INInteraction(intent: facility.createIntent(), response: WOPViewFacilityIntentUtils.getIntentResponse(facility, userActivity: activity))
		interaction.donate(completion: nil)
    }
	func setActivityUp() {
		activity.isEligibleForHandoff = true
		activity.isEligibleForSearch = true
		activity.addUserInfoEntries(from: ["facility": facility.slug])
		activity.title = facility.facilityName
		activity.keywords = Set<String>(arrayLiteral: facility.facilityName, facility.facilityLocation!.building)
		activity.webpageURL = URL(string: "https://whatsopen.gmu.edu")
		activity.becomeCurrent()
	}
    @available(iOS 12.0, *)
    @IBAction func addToSiri(_ sender: Any) {
		feedback.selectionChanged()
		let intent = facility.createIntent()
		let shortcuts = INVoiceShortcutCenter.shared
		if let shortcut = INShortcut(intent: intent) {
			let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
			viewController.modalPresentationStyle = .formSheet
			viewController.delegate = self 
			present(viewController, animated: true, completion: nil)
		}
	}
	func addSubview(_ subView: UIView, toView parentView: UIView) {
		parentView.addSubview(subView)
		var viewBindingsDict = [String: AnyObject]()
		viewBindingsDict["subView"] = subView
		parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subView]|",
																 options: [], metrics: nil, views: viewBindingsDict))
		parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|",
																 options: [], metrics: nil, views: viewBindingsDict))
	}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @available(iOS 12.0, *)
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
		controller.dismiss(animated: true, completion: nil)
	}
    @available(iOS 12.0, *)
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
		controller.dismiss(animated: true, completion: nil)
	}
}
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
