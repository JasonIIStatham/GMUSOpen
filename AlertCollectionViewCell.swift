import UIKit
import GMUOpenKit
class AlertCollectionViewCell: UICollectionViewCell {
	@IBOutlet var imageView: UIImageView!
	@IBOutlet var messageLabel: UILabel!
	var alert: WOPAlert!
	internal let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
	var viewWidth: CGFloat!
	override func awakeFromNib() {
		super.awakeFromNib()
		isAccessibilityElement = true
		shouldGroupAccessibilityChildren = true
		setNeedsLayout()
	}
}
