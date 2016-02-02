//
//  DetailViewController.swift
//  MovieViewer
//
//  Created by Fer on 2/1/16.
//  Copyright © 2016 Fernando Mendoza. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var movie: NSDictionary!
    var refreshControl: UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let title       =   movie["title"] as! String
        titleLabel.text =   title
        
        let overview    =   movie["overview"] as! String
        overviewLabel.text  =   overview
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
        if let posterPath  = movie["poster_path"] as? String{
            let imageUrl    = NSURL(string: baseUrl + posterPath)
            posterImageView.setImageWithURL(imageUrl!)
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
