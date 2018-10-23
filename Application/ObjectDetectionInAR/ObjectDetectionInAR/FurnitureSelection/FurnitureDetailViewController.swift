import UIKit

class FurnitureDetailViewController: UIViewController
{
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var assembleButton: UIButton!
    
    var furniture: Furniture?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        iconView.image = furniture?.icon
        idLabel.text = furniture?.id
        descriptionTextView.text = furniture?.description
        self.navigationItem.title = furniture?.name
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        let database = Database()
        furniture?.instructions = database.getInstructions(for: furniture!)
        
        // Don't allow the user to navigate further if no instructions exist
        if furniture?.instructions == nil
        {
            assembleButton.isEnabled = false
            assembleButton.setTitle("No available instructions", for: .normal)
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let inspectionViewController = segue.destination as? FurnitureInspecterViewController
        {
            inspectionViewController.furniture = furniture
        }
        
        if let assembleViewController = segue.destination as? AssemblerViewController
        {
            assembleViewController.furniture = furniture
        }
    }
}
