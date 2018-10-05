import UIKit

class FurnitureDetailViewController: UIViewController
{
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var furniture: Furniture?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        iconView.image = furniture?.icon
        idLabel.text = furniture?.id
        descriptionTextView.text = furniture?.description
        self.navigationItem.title = furniture?.name
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let inspectionViewController = segue.destination as? FurnitureInspecterViewController
        {
            inspectionViewController.furniture = furniture
        }
    }
}
