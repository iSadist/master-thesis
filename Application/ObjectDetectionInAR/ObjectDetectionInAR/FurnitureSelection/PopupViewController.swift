/*
 The popup view is a generic view with an image, text and two buttons.
 */

import UIKit

class PopupViewController: UIViewController
{
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var primaryButton: UIButton!
    @IBOutlet weak var secondaryButton: UIButton!
    
    var image : UIImage?
    var primaryButtonText : String?
    var secondaryButtonText : String?
    var textViewText : String?
    
    @objc var completeFunction = {
        print("Complete function is not yet specified!")
        fatalError()
    }
    
    @objc var secondaryButtonHandler = {
        print("Secondary function is not yet specified!")
        fatalError()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        popupView.layer.cornerRadius = 25
        imageView.image = image
        imageView.layer.cornerRadius = 20
        primaryButton.setTitle(primaryButtonText, for: .normal)
        secondaryButton.setTitle(secondaryButtonText, for: .normal)
        textView.text = textViewText        
    }
    
    @IBAction func proceedButton(_ sender: Any)
    {
        complete()
    }
    
    @IBAction func secondaryButtonTapped(_ sender: UIButton)
    {
        secondaryButtonHandler()
    }
    
    func complete()
    {
        completeFunction()
    }
}
