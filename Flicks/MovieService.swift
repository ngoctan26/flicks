//
//  MovieService.swift
//  Flicks
//
//  Created by Nguyen Quang Ngoc Tan on 2/16/17.
//  Copyright © 2017 Nguyen Quang Ngoc Tan. All rights reserved.
//

import Foundation

class MovieService {
    
    let API_MOVIE_DOMAIN = "https://api.themoviedb.org/3/movie/"
    let API_KEY = "?api_key=30a201b45f037ff468effa79fd6a92cc"
    let GET_NOW_PLAYING_URL_PATH = "now_playing"
    let GET_TOP_RATE_URL_PATH = "top_rated"
    static let POSTER_URL_DOMAIN = "https://image.tmdb.org/t/p/w45/"
    static let ORIGINAL_POSTER_URL_DOMAIN = "https://image.tmdb.org/t/p/original/"
    
    func getNowPlayingMovies(seviceDelegate: ServiceDelegate) {
        getMovies(seviceDelegate: seviceDelegate, apiTypePath: GET_NOW_PLAYING_URL_PATH)
    }
    
    func getTopRateMoviews(seviceDelegate: ServiceDelegate) {
        getMovies(seviceDelegate: seviceDelegate, apiTypePath: GET_TOP_RATE_URL_PATH)
    }
    
    private func getMovies(seviceDelegate: ServiceDelegate, apiTypePath: String) {
        let urlAsStr = API_MOVIE_DOMAIN + apiTypePath + API_KEY
        let url = URL(string: urlAsStr)
        
        if let url = url {
            let request = URLRequest(
                url: url,
                cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
                timeoutInterval: 10)
            let session = URLSession(
                configuration: URLSessionConfiguration.default,
                delegate: nil,
                delegateQueue: OperationQueue.main)
            let task = session.dataTask(
                with: request,
                completionHandler: { (dataOrNil, response, error) in
                    seviceDelegate.onLoadSuccess(response: dataOrNil)
                    seviceDelegate.onLoadError(error: error)
            })
            task.resume()
        }
    }
}
