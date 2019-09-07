import UIKit
class PullingViewController: UIViewController {
	@IBOutlet var containerView: UIView!
	weak var currentViewController: UIViewController?
	@IBOutlet var pullDown: UIImageView!
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	override func viewDidAppear(_ animated: Bool) {
		if animated {
			let haptics = UIImpactFeedbackGenerator(style: .medium)
			haptics.impactOccurred()
		}
	}
	override func viewWillDisappear(_ animated: Bool) {
		if animated {
			let haptics = UIImpactFeedbackGenerator(style: .medium)
			haptics.impactOccurred()
		}
	}
	override func viewDidLoad() {
		modalPresentationCapturesStatusBarAppearance = true
		self.currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
		self.addChild(self.currentViewController!)
		self.addSubview(self.currentViewController!.view, toView: self.containerView)
		self.accessibilityCustomActions = [
			UIAccessibilityCustomAction(name: "Dismiss Detail View", target: self, selector: #selector(PullingViewController.willDismiss))
		]
		super.viewDidLoad()
    }
	@objc func willDismiss() {
		dismiss(animated: true, completion: nil)
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
}
