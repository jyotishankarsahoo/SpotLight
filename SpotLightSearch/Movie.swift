//
//  Movie.swift
//  SpotLightSearch
//
//  Created by jyoti shankar sahoo on 4/6/17.
//  Copyright © 2017 jyoti shankar sahoo. All rights reserved.
//

import Foundation

struct Movie {
    
    var title : String
    var imdbID : String
    var type : String
    var year : String
    var imageUrl : String
    
    init?(json : Dictionary<String,AnyObject>)
    {
        guard let title = json["Title"] as? String,
                    let imdbID = json["imdbID"] as? String,
                    let type = json["Type"] as? String,
                    let year = json["Year"] as? String,
                    let imageUrl = json["Poster"] as? String else
        {
         return nil
        }
        
        self.title = title
        self.imdbID = imdbID
        self.type = type
        self.year = year
        self.imageUrl = imageUrl
    }
    
}

struct MovieDetails {
    
    var title : String
    var year : String
    var rated : String
    var released : String
    var runtime : String
    var genre : String
    var director : String
    var writer : String
    var actors : String
    var language : String
    var country : String
    var poster : String
    var production : String
    var website : String
    var plot : String
    var imdbRating : String
    
    init?(json : Dictionary<String,AnyObject>) {
        guard let title = json["Title"] as? String,
        let year = json["Year"] as? String,
        let actors = json["Actors"] as? String,
        let rated = json["Rated"] as? String,
        let released = json["Released"] as? String,
        let runtime = json["Runtime"] as? String,
        let genre = json["Genre"] as? String,
        let director = json["Director"] as? String,
        let writer = json["Writer"] as? String,
        let language = json["Language"] as? String,
        let country = json["Country"] as? String,
        let poster = json["Poster"] as? String,
        let production = json["Production"] as? String,
        let website = json["Website"] as? String,
        let plot = json["Plot"] as? String,
        let imdbRating = json["imdbRating"] as? String

        else{
            return nil
        }
        self.title = title
        self.year = year
        self.actors = actors
        self.rated = rated
        self.released = released
        self.runtime = runtime
        self.genre = genre
        self.director = director
        self.writer = writer
        self.language = language
        self.country = country
        self.poster = poster
        self.production = production
        self.website = website
        self.plot = plot
        self.imdbRating = imdbRating
    }
    
    
}
