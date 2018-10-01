import UIKit

class FurnitureSelectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate
{
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var collection: [Furniture]?
    var filteredCollection: [Furniture]?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        searchBar.delegate = self
        
        let nolmyra = Furniture(name: "Nolmyra", id: "102.335.32", description: "Fåtöljen är lätt och därför enkel att flytta när du vill tvätta golvet eller möblera om.", icon: UIImage(named: "nolmyra")!)
        collection = [nolmyra]
        filteredCollection = collection
    }
    
    // MARK: Collection View Delegate
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return filteredCollection!.count
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
            filteredCollection = collection?.filter({ (item) in
                return item.name.range(of: searchText!) != nil
            })
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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let detailViewController = segue.destination as? FurnitureDetailViewController
        {
            detailViewController.furniture = collection?.first
        }
    }
    
    @IBAction func unwindToFurnitureSelection(segue: UIStoryboardSegue)
    {
        if let previousViewController = segue.source as? BarcodeScannerViewController
        {
            searchBar.text = previousViewController.payloadString
        }
    }

}
