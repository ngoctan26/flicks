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
    
    // Properties
    var movieService = MovieService()
    var movies = [NSDictionary]()
    var selectedIndext = 0
    var isNowPlayingTab = true
    

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
            if let titleStr = ((movies[indexPath.row]))["title"] {
                cell.movieNameLabel.text = (titleStr as! String)
            }
            if let overViewStr = ((movies[indexPath.row]))["overview"] {
                cell.movieOverView.text = (overViewStr as! String)
            }
            if let imageUrlAsStr = ((movies[indexPath.row]))["poster_path"] {
                let imageUrlFullPath = MovieService.POSTER_URL_DOMAIN + (imageUrlAsStr as! String)
                cell.movieImage.setImageWith(URL(string: imageUrlFullPath)!)
            } else {
                cell.movieImage = nil
            }

        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndext = indexPath.row
        performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let destinationVC = segue.destination as? MovieDetailViewController
            if let destinationVC = destinationVC {
                if let imageUrlAsStr = ((movies[selectedIndext]))["poster_path"] {
                    let imageUrlFullPath = MovieService.ORIGINAL_POSTER_URL_DOMAIN + (imageUrlAsStr as! String)
                    destinationVC.movieImageUrl = imageUrlFullPath
                }
                if let overviewInfo = ((movies[selectedIndext]))["overview"] {
                    destinationVC.overviewInfo = (overviewInfo as? String)!
                }
            }
        }
    }

    func initView() {
        movieTableView.delegate = self
        movieTableView.dataSource = self
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
            setView(view: networkErrorLabel, hidden: false)
        }
    }
    
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {() -> Void in
            view.isHidden = hidden
        }, completion: { _ in })
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
