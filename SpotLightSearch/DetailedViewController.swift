//
//  DetailedViewController.swift
//  SpotLightSearch
//
//  Created by jyoti shankar sahoo on 4/6/17.
//  Copyright © 2017 jyoti shankar sahoo. All rights reserved.
//

import UIKit

class DetailedViewController: UIViewController {

    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var categoryLabel : UILabel!
    @IBOutlet weak var descriptionLabel : UILabel!
    @IBOutlet weak var directorLabel : UILabel!
    @IBOutlet weak var starsLabel : UILabel!
    @IBOutlet weak var releasedateLabel : UILabel!
    @IBOutlet weak var posterImageView : UIImageView!

    
    var movieTitle : String!
    var detailedMovieUrlString = "https://www.omdbapi.com/?t=%@&y=&plot=short&r=json"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.fetchMovieDetails(title: movieTitle)
    }
    
    func fetchMovieDetails(title : String){
        
        let urlString = String(format: detailedMovieUrlString, movieTitle)
        let detailedMovieURL = URL(string: urlString.replacingOccurrences(of: " ", with: "+"))
        
        let task = URLSession.shared.dataTask(with: detailedMovieURL!) { (data, response, error) in
            guard error == nil && data != nil else{
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return
            }
            
            let responseStatus = response as? HTTPURLResponse
            if responseStatus?.statusCode == 200{
                if data?.count != 0{
                    do{
                        let detailedMovieJson = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String : AnyObject]
                        
                        if let detailedMovieModel = MovieDetails(json: detailedMovieJson!){
                            print("\(detailedMovieModel)")
                            DispatchQueue.main.async {
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false

                                self.updateMovieDetails(model: detailedMovieModel)
                            }
                        }
                        
                    }catch {
                        print("\(error.localizedDescription)")
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false

                    }
                    
                }else{
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    print("No data received from URL")
                }
                
            }else
            {
                print("HTTP response code \(responseStatus?.statusCode)")
            }
        }
        task.resume()
    }
    
    func updateMovieDetails(model : MovieDetails){
        self.titleLabel.text = "Title : \(model.title)"
        self.descriptionLabel.text = model.plot
        self.categoryLabel.text = "Category : \(model.genre)"
        self.directorLabel.text = "Director : \(model.director)"
        self.starsLabel.text = "IMDB Rating : \(model.imdbRating)"
        self.releasedateLabel.text = "Release Date : \(model.released)"
        
        let imagedata = try?  Data(contentsOf: URL(string: model.poster)!)
        if let image = imagedata{
            self.posterImageView.image = UIImage(data: image)
        }
        
    }

}
