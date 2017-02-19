//
//  MovieDetailViewController.swift
//  Flicks
//
//  Created by Nguyen Quang Ngoc Tan on 2/17/17.
//  Copyright © 2017 Nguyen Quang Ngoc Tan. All rights reserved.
//

import UIKit
import AFNetworking

class MovieDetailViewController: UIViewController {
    //View references
    @IBOutlet weak var movieDetailImage: UIImageView!
    @IBOutlet weak var overViewInfoLabel: UILabel!
    
    
    // Properties
    var movieImageHighUrl = ""
    var movieImageLowUrl = ""
    var overviewInfo = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //movieDetailImage.setImageWith(URL(string: movieImageUrl)!)
        ImageUtils.loadImageFromLowToHighResolotion(imageView: movieDetailImage, highUrl: movieImageHighUrl, lowUrl: movieImageLowUrl)
        overViewInfoLabel.layer.cornerRadius = 5
        overViewInfoLabel.text = overviewInfo
        overViewInfoLabel.sizeToFit()
//        let overViewLabelHeight = self.view.bounds.size.height - overViewInfoLabel.frame.size.height
//        let tabBarHeight = self.tabBarController?.tabBar.frame.height
//        overViewInfoLabel.frame = CGRect(x: 0, y: (tabBarHeight! + overViewLabelHeight), width: overViewInfoLabel.frame.size.width, height: overViewInfoLabel.frame.size.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
