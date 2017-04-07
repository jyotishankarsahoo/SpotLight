//
//  ViewController.swift
//  SpotLightSearch
//
//  Created by jyoti shankar sahoo on 4/6/17.
//  Copyright © 2017 jyoti shankar sahoo. All rights reserved.
//

import UIKit
import CoreSpotlight
import MobileCoreServices

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    @IBOutlet weak var searchTextField : UITextField!
    @IBOutlet weak var resultsTableView : UITableView!
    
    var moviesList : Array<Movie>!
    var selectedMovieTitle : String = ""
    //"https://www.omdbapi.com/?t=%@&y=&plot=short&r=json
    var imdbURLString : String = "http://www.omdbapi.com/?s=%@&plot=short&r=json"
    
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       // self.setUpSearchableItem()
    }
    
    //MARK: Textfield Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if let enteredText = self.searchTextField.text{
            UIApplication.shared.isNetworkActivityIndicatorVisible = true;
            self.fetchJsonData(searchText: enteredText.replacingOccurrences(of: " ", with: "+"))
        }
        self.searchTextField.text = ""
        self.searchTextField.resignFirstResponder()
        
        return true
    }
    
    //MARK: Tableview Delegete
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.moviesList != nil ? self.moviesList.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultsCell", for: indexPath)
        cell.textLabel?.text = self.moviesList[indexPath.row].title
        cell.detailTextLabel?.text = self.moviesList[indexPath.row].year
        return cell
    }
    
    //MARK: Utility Method
    func setUpView()
    {
        self.resultsTableView.delegate = self
        self.resultsTableView.isHidden = true
        self.searchTextField.delegate = self
    }
    
    func fetchJsonData(searchText : String)
    {
        let urlString = String(format: imdbURLString, searchText)
        
        let finalURL = URL(string: urlString)!
        
        let task = URLSession.shared.dataTask(with: finalURL) { (data, response, error) in
            guard error == nil && data != nil else{
                print("\(error?.localizedDescription)")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false;

                return
            }
            
            let responseStatus = response as! HTTPURLResponse
            if responseStatus.statusCode == 200
            {
                if data?.count != 0
                {
                    do{
                        let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? Dictionary<String,AnyObject>
                        
                        let movieFound = jsonResponse?["Response"] as? String
                        
                        guard movieFound == "True" else{
                            print("\(jsonResponse?["Error"])")
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false;
                            return
                        }
                        
                        let movies = jsonResponse?["Search"] as? Array<AnyObject>
                        self.moviesList = NSArray() as! Array<Movie>
                        for movie in movies!{
                            if let movieModel = Movie(json: movie as! Dictionary<String, AnyObject>){
                                self.moviesList.append(movieModel)
                            }
                        }
                      
                        DispatchQueue.main.async {
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false;
                            self.resultsTableView.isHidden = false
                            self.resultsTableView.reloadData()
                            self.setUpSearchableItem()
                        }

                    }catch{
                        print(error.localizedDescription)
                    }
                }else
                {
                    print("No Data recevied from URL")
                }
            }else
            {
                print("Status Code : \(responseStatus.statusCode)")
            }
        }
        task.resume()
    }
    
    //MARK: Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let detailedViewcontroller = segue.destination as! DetailedViewController
        let selectedMovieIndex = self.resultsTableView.indexPathForSelectedRow?.row
        
        self.selectedMovieTitle = self.moviesList != nil ? self.moviesList[selectedMovieIndex!].title : self.selectedMovieTitle
        detailedViewcontroller.movieTitle = self.selectedMovieTitle

    }
    
    //MARK: Core Spot light 
    func setUpSearchableItem(){
        var selectedItems = [CSSearchableItem]()
        var keywords = [String]()

        if self.moviesList != nil {
            
            for i in 0 ... (self.moviesList.count - 1 ){
                let movieModel = self.moviesList[i]
                
                let searchableItemAttributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
                searchableItemAttributeSet.title = movieModel.title
                
                keywords.append(movieModel.title)
                searchableItemAttributeSet.keywords = keywords
                
                let searchableItem = CSSearchableItem(uniqueIdentifier: "com.imdb.\(i)", domainIdentifier: "imdb", attributeSet: searchableItemAttributeSet)
                
                selectedItems.append(searchableItem)
            }
            
            CSSearchableIndex.default().indexSearchableItems(selectedItems) { (error) -> Void in
                if error != nil {
                    print(error?.localizedDescription as Any)
                }
            }
        }
        
    }
    
    override func restoreUserActivityState(_ activity: NSUserActivity) {
        if activity.activityType == CSSearchableItemActionType {
            if let userInfo = activity.userInfo{
                let selectedMovie = userInfo[CSSearchableItemActivityIdentifier] as! String
                let selctedMovieIndex = Int(selectedMovie.components(separatedBy: ".").last!)
                self.selectedMovieTitle = self.moviesList[selctedMovieIndex!].title
                performSegue(withIdentifier: "detailedMovieSegue", sender: self)
            }
        }
    }

}

