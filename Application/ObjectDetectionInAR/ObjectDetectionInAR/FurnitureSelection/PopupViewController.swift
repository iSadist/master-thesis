
import UIKit

class PopupViewController: UIViewController
{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var button: UIButton!
    
    var image : UIImage?
    var buttonText : String?
    var textViewText : String?
    
    @objc var completeFunction = {
        print("Complete function is not yet specified!")
        fatalError()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        imageView.image = image
        button.setTitle(buttonText, for: .normal)
        textView.text = textViewText        
    }
    
    @IBAction func proceedButton(_ sender: Any)
    {
        complete()
    }
    
    func complete()
    {
        completeFunction()
    }
}
