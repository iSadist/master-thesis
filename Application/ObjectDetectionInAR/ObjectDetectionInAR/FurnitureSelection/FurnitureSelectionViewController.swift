import UIKit

class FurnitureSelectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate
{
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var emptyCollectionMessageLabel: UILabel!
    
    var collection: [Furniture]?
    var filteredCollection: [Furniture]?
    var selectedFurniture: Furniture?
    var database = Database()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        searchBar.delegate = self

        collection = database.getFurnitures()
        filteredCollection = collection
    }
    
    // MARK: Collection View Delegate
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        let amount = filteredCollection!.count
        emptyCollectionMessageLabel.isHidden = amount == 0
        return amount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FurnitureCell", for: indexPath)
        
        if let furnitureCell = cell as? FurnitureCollectionViewCell
        {
            furnitureCell.title.text = filteredCollection![indexPath.row].name
            furnitureCell.icon.image = filteredCollection![indexPath.row].icon
            cell = furnitureCell
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        selectedFurniture = filteredCollection![indexPath.row]
        performSegue(withIdentifier: "ShowFurnitureDetailSegue", sender: nil)
    }
    
    // MARK: - Search Bar Delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchBar.text
        
        if searchText!.isEmpty
        {
            filteredCollection = collection
        }
        else
        {
            filteredCollection = collection?.filter({ (item) in item.name.range(of: searchText!) != nil || searchText! == item.id })
        }
        
        collectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let detailViewController = segue.destination as? FurnitureDetailViewController
        {
            detailViewController.furniture = selectedFurniture
        }
    }
    
    @IBAction func unwindToFurnitureSelection(segue: UIStoryboardSegue)
    {
        if let previousViewController = segue.source as? BarcodeScannerViewController
        {
            guard var barcodeString = previousViewController.payloadString else { return }
            
            let lowerBound = String.Index.init(encodedOffset: 0)
            let upperBound = String.Index.init(encodedOffset: 10)
            
            barcodeString.insert(".", at: String.Index.init(encodedOffset: 3))
            barcodeString.insert(".", at: String.Index.init(encodedOffset: 7))
            searchBar.text = String(barcodeString[lowerBound..<upperBound])
            searchBar.delegate?.searchBar!(searchBar, textDidChange: searchBar.text!)
        }
    }
}
