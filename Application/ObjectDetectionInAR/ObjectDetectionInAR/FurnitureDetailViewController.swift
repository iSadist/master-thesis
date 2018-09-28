//
//  FurnitureDetailViewController.swift
//  ObjectDetectionInAR
//
//  Created by Jan Svensson on 2018-09-28.
//  Copyright © 2018 Jan Svensson. All rights reserved.
//

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
    }

    @IBAction func assembleButtonTapped(_ sender: UIButton)
    {
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
