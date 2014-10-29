//
//  MTSearchViewController.swift
//  SingleCastOct20
//
//  Created by David Lam on 20/10/14.
//  Copyright (c) 2014 David Lam. All rights reserved.
//

import UIKit

class MTSearchViewController: UIViewController {

    private var podCasts: NSMutableArray?
    private let SearchCell = "SearchCell"
    
    private var session: NSURLSession?
    private var sessionDataTask: NSURLSessionTask?
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if self.session == nil{
            var sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
            sessionConfiguration.HTTPAdditionalHeaders = ["Accpet" : "application/json"]
            self.session = NSURLSession(configuration: sessionConfiguration)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.searchBar.becomeFirstResponder()
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

extension MTSearchViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(scrollView: UIScrollView){
        if(self.searchBar.isFirstResponder()){
            self.searchBar.resignFirstResponder()
        }
    }
}

extension MTSearchViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (self.podCasts != nil) ? 1:0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return (self.podCasts != nil) ? self.podCasts!.count :0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(SearchCell, forIndexPath: indexPath) as UITableViewCell
        
        //fetch podcast
        let podcast: NSDictionary = self.podCasts!.objectAtIndex(indexPath.row) as NSDictionary
        cell.textLabel.text = podcast.objectForKey("collectionName") as? String
        cell.detailTextLabel!.text = podcast.objectForKey("artistName") as? String
        
        return cell
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool{
        return false
    }

    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool{
        return false
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        //fetch podcast
        let podcastSelected = self.podCasts?.objectAtIndex(indexPath.row) as? NSDictionary
        //update user defaults
        let ud = NSUserDefaults.standardUserDefaults()
        
        ud.setObject(podcastSelected, forKey: "MTPodcast")
        ud.synchronize()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension MTSearchViewController: UISearchBarDelegate{
    // called when text changes (including clear)
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String){
        if(searchText == "") {
            return
        }
        if(countElements(searchText) <= 3) {
            self.resetSearch()
        }else{
            self.performSearch()
        }
        
    }
    
    func resetSearch(){
        self.podCasts?.removeAllObjects()
        self.tableView.reloadData()
    }
    
    func performSearch(){
        let query = self.searchBar.text
        
        if(self.sessionDataTask != nil){
            self.sessionDataTask?.cancel()
        }
        
        self.sessionDataTask = self.session?.dataTaskWithURL(self.urlForQuery(query), completionHandler: { (incomingData, response, error) -> Void in
            if(error != nil){
                if(error?.code != -999){
                    println(error)
                }
            }else{
                var errorPointer2:NSError?
                let result = NSJSONSerialization.JSONObjectWithData(incomingData, options: NSJSONReadingOptions.MutableLeaves, error: &errorPointer2) as NSDictionary
                var results = result.objectForKey("results") as? NSMutableArray
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if(results != nil){
                        self.processResults(results!)
                    }
                })
            }
        })
        
        if(self.sessionDataTask != nil){
            self.sessionDataTask?.resume()
        }
    }
    
    func urlForQuery(query: String)->NSURL{
        var query2 = query.stringByReplacingOccurrencesOfString(" ", withString: "+")
        if query2.hasSuffix("+"){
            query2 = query2.substringToIndex(query2.endIndex.predecessor())
        }
        query2 = "https://itunes.apple.com/search?media=podcast&entity=podcast&term=%40" + query2 as NSString
        //query2 = "https://itunes.apple.com/search?media=podcast&entity=podcast&term=%" + query as NSString

       //query2.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        println(query2)
        let myUrl = NSURL(string: query2)
        println(myUrl)
        return myUrl!
    }
    
    
    /*
    - (NSURL *)urlForQuery:(NSString *)query {
    query = [query stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/search?media=podcast&entity=podcast&term=%@", query]];
    }
    */
    func processResults(results: NSMutableArray) -> (){
        //update data source
        if(self.podCasts? != nil){
            self.podCasts!.removeAllObjects()
        }
        if(self.podCasts? == nil){
            self.podCasts = results as NSMutableArray
        }else{
            self.podCasts!.addObjectsFromArray(results)
        }
        //update tableview
        self.tableView.reloadData()
    }
}
