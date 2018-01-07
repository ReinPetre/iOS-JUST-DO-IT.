import UIKit

class RoundedButton: UIButton {

    required init() {
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.cornerRadius = self.frame.height / 2
        clipsToBounds = true
    }
}
