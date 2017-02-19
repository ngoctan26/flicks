//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Nguyen Quang Ngoc Tan on 2/16/17.
//  Copyright © 2017 Nguyen Quang Ngoc Tan. All rights reserved.
//

import UIKit
import MBProgressHUD
import AFNetworking
import SystemConfiguration

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ServiceDelegate {
    // Views references
    @IBOutlet weak var movieTableView: UITableView!
    var refreshController = UIRefreshControl()
    @IBOutlet weak var networkErrorLabel: UILabel!
    @IBOutlet weak var movieSearchBar: UISearchBar!
    
    
    // Properties
    let searchController = UISearchController(searchResultsController: nil)
    var movieService = MovieService()
    var movies = [NSDictionary]()
    var selectedIndex = 0
    var isNowPlayingTab = true
    var filterMovies = [NSDictionary]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        loadData(isPollToRefress: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filterMovies.count
        }
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieTableViewCell
        // Set custom selected view
//        cell.selectionStyle = .none
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.lightGray
        cell.selectedBackgroundView = backgroundView
        if movies.count > 0 {
            let handleMovie: NSDictionary
            if searchController.isActive && searchController.searchBar.text != "" {
                handleMovie = filterMovies[indexPath.row]
            } else {
                handleMovie = movies[indexPath.row]
            }
            if let titleStr = ((handleMovie))["title"] {
                cell.movieNameLabel.text = (titleStr as! String)
            }
            if let overViewStr = ((handleMovie))["overview"] {
                cell.movieOverView.text = (overViewStr as! String)
            }
            if let imageUrlAsStr = ((handleMovie))["poster_path"] {
                let imageUrlFullPath = MovieService.POSTER_URL_DOMAIN + (imageUrlAsStr as! String)
                //cell.movieImage.setImageWith(URL(string: imageUrlFullPath)!)
                ImageUtils.loadImageFromUrlWithAnimate(imageView: cell.movieImage, url: imageUrlFullPath)
            } else {
                cell.movieImage = nil
            }

        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let destinationVC = segue.destination as? MovieDetailViewController
            if let destinationVC = destinationVC {
                let handleMovie: NSDictionary
                if searchController.isActive && searchController.searchBar.text != "" {
                    handleMovie = filterMovies[selectedIndex]
                } else {
                    handleMovie = movies[selectedIndex]
                }

                if let imageUrlAsStr = handleMovie["poster_path"] {
                    let imageHighUrlFullPath = MovieService.ORIGINAL_POSTER_URL_DOMAIN + (imageUrlAsStr as! String)
                    let imageLowUrlFullPath = MovieService.POSTER_URL_DOMAIN + (imageUrlAsStr as! String)
                    destinationVC.movieImageHighUrl = imageHighUrlFullPath
                    destinationVC.movieImageLowUrl = imageLowUrlFullPath
                }
                if let overviewInfo = handleMovie["overview"] {
                    destinationVC.overviewInfo = (overviewInfo as? String)!
                }
            }
        }
    }

    func initView() {
        movieTableView.delegate = self
        movieTableView.dataSource = self
        // handle Search bar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        movieTableView.tableHeaderView = searchController.searchBar
        
        refreshController.addTarget(self, action: #selector(refreshAction), for: UIControlEvents.valueChanged)
        movieTableView.addSubview(refreshController)
        setView(view: networkErrorLabel, hidden: NetworkUtil.isConnectedToNetwork())
    }
    
    func refreshAction() {
        loadData(isPollToRefress: true)
    }
    
    func loadData(isPollToRefress: Bool) {
        if NetworkUtil.isConnectedToNetwork() {
            if !isPollToRefress {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            if isNowPlayingTab {
                movieService.getNowPlayingMovies(seviceDelegate: self)
            } else {
                movieService.getTopRateMoviews(seviceDelegate: self)
            }
        } else {
            // Stop refreshing progress bar when network is not available
            refreshController.endRefreshing()
            setView(view: networkErrorLabel, hidden: false)
        }
    }
    
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {() -> Void in
            view.isHidden = hidden
        }, completion: { _ in })
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filterMovies = movies.filter { movie in
            
            let titleStr = (movie["title"] as! String)
            return titleStr.range(of: searchText) != nil
        }
        
        movieTableView.reloadData()
    }
    
    func onLoadError(error: Error?) {
        setView(view: networkErrorLabel, hidden: NetworkUtil.isConnectedToNetwork())
        MBProgressHUD.hide(for: self.view, animated: true)
        refreshController.endRefreshing()
        if let error = error {
            print("Get movies failed: \(error)")
        }
    }
    
    func onLoadSuccess(response: Data?) {
        setView(view: networkErrorLabel, hidden: NetworkUtil.isConnectedToNetwork())
        if let data = response {
            if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                if let movieDatas = responseDictionary["results"] as? [NSDictionary] {
                    movies = movieDatas
                    movieTableView.reloadData()
                    refreshController.endRefreshing()
                }
            }
        }
        MBProgressHUD.hide(for: self.view, animated: true)
    }
}

extension MoviesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
