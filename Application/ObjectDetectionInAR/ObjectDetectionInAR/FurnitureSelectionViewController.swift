//
//  FurnitureSelectionViewController.swift
//  ObjectDetectionInAR
//
//  Created by Jan Svensson on 2018-09-28.
//  Copyright © 2018 Jan Svensson. All rights reserved.
//

import UIKit

class FurnitureSelectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource
{
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var collection: [Furniture]?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let nolmyra = Furniture(name: "Nolmyra", id: "102.335.32", description: "Fåtöljen är lätt och därför enkel att flytta när du vill tvätta golvet eller möblera om.", icon: UIImage(named: "nolmyra")!)
        collection = [nolmyra]
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return collection!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FurnitureCell", for: indexPath)
        
        if let furnitureCell = cell as? FurnitureCollectionViewCell
        {
            furnitureCell.title.text = collection![indexPath.row].name
            furnitureCell.icon.image = collection![indexPath.row].icon
            cell = furnitureCell
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: "ShowFurnitureDetailSegue", sender: nil)
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

}
