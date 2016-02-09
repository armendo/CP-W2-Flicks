//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Fer on 1/24/16.
//  Copyright © 2016 Fernando Mendoza. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorView: UIView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movies: [NSDictionary]?
    var filteredData: [NSDictionary]?
    var endpoint: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting ScrollView
        
        
        //Setting Delegate Methods
        tableView.delegate      =   self
        tableView.dataSource    =   self
        searchBar.delegate      =   self
        
        //Hiding Error View
        errorView.hidden        =   true

        loadDataFromNetwork()
        
        settingUIRefreshControl()

    }
    
    //MARK: - Methods used to implement UIRefreshControl
    
    func settingUIRefreshControl(){
        // Initialize a UIRefreshControl
        let refreshControl  =   UIRefreshControl()
        //Binding refreshControlAction selector to UIRefreshControl so that something when happen when pull to refresh
        refreshControl.addTarget(
            self,
            action: "refreshControlAction:",
            forControlEvents: UIControlEvents.ValueChanged)
        //UIRefreshControl adding to the list view
        //UIRefreshControl is a subclass of the UIVIew.
        tableView.insertSubview(
            refreshControl,
            atIndex: 0)
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl){
        let apiKey  = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url     = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue())
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            self.movies  =   responseDictionary["results"] as! [NSDictionary]
                            self.tableView.reloadData()
                            
                            //Stop spinning refreshControl
                            refreshControl.endRefreshing()
                    }
                }
        })
        task.resume()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Helper Methods
    func loadDataFromNetwork(){
        
        // ... Create the NSURLRequest (myRequest) ...
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let myRequest = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        // Display HUD right before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(myRequest,
            completionHandler: { (data, response, error) in
                
                // Hide HUD once the network request comes back (must be done on main UI thread)
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
                // ... Remainder of response handling code ...
                if let data = data {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            self.movies         =   responseDictionary["results"] as! [NSDictionary]
                            self.filteredData        =   self.movies
                            self.tableView.reloadData()
                    }
                }
                
        });
        task.resume()
    }
    
    //MARK: - UITableViewDataSource Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if let movies = filteredData{
            errorView.hidden    =   true
            return movies.count
        }else{
            errorView.hidden    =   false
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell    =   tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieTableViewCell
        let movie   =   filteredData![indexPath.row]
        let title   =   movie["title"] as! String
        let overview   =   movie["overview"] as! String
        let baseUrl = "http://image.tmdb.org/t/p/w342"

        if let posterPath  = movie["poster_path"] as? String{
            let imageUrl    = NSURL(string: baseUrl + posterPath)
            cell.movieImage.setImageWithURL(imageUrl!)
        }
        
        cell.overviewLabel.text =   overview
        cell.titleLabel.text    =   title
        return cell
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell        =   sender as! UITableViewCell
        let indexPath   =   tableView.indexPathForCell(cell)
        let movie       =   filteredData![indexPath!.row]
        
        let detailViewController    =   segue.destinationViewController as! DetailViewController
        detailViewController.movie  =   movie
        
    }
    
    //MARK: - UISearchBarDelegate Methods
    
    // called when text changes (including clear)
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String){
        if searchText.isEmpty{
            filteredData = movies
        }else{
            filteredData = []
//            var index    = 0
            for movie in movies!{
                let movieName   =   movie["title"] as! String
                if movieName.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    filteredData?.append(movie)
                }
                
            }
        }

        self.tableView.reloadData()
    }
  
  func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    let selectedCell = tableView.cellForRowAtIndexPath(indexPath)!
    selectedCell.contentView.backgroundColor = UIColor.grayColor()

  }
  
}
