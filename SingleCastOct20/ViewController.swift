//
//  ViewController.swift
//  SingleCastOct20
//
//  Created by David Lam on 20/10/14.
//  Copyright (c) 2014 David Lam. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var podcast : NSDictionary?
    private var episodes : NSMutableArray?
    private var feedParser : MWFeedParser?
    private var progressBuffer = [String : NSNumber]()
    
    private var session : NSURLSession?
    
    @IBOutlet weak var tableView: UITableView!

    // MARK: application lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
        self.setupView()
        
        self.session = self.backgroundSession()
        
        self.loadPodcast()
        
        NSUserDefaults.standardUserDefaults().addObserver(self, forKeyPath: "MTPodcast", options: NSKeyValueObservingOptions.New, context: nil)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.loadPodcast()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if(keyPath == "MTPodcast"){
            self.setPodcastDictionaryTo(object.objectForKey("MTPodcast") as NSDictionary)
        }
    }
    
    //deinit is called when dealloc is called
    deinit{
        NSUserDefaults.standardUserDefaults().removeObserver(self, forKeyPath: "MTPodcast")
    }
    
    func playThatFunkyMusic(){
        println("play that funky music whiteboy")
    }
    
    func setBackgroundSessionCompletionHandler(){
        let applicationDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        applicationDelegate.backgroundSessionCompletionHandler = playThatFunkyMusic
    }

    func invokeBackgroundSessionCompletionHandler(){
        self.session?.getTasksWithCompletionHandler({ (dataTasks, uploadTasks, downloadTasks) -> Void in
            let totalCountOfTasks = dataTasks.count + uploadTasks.count + downloadTasks.count as NSInteger?
            if totalCountOfTasks? == nil || totalCountOfTasks == 0 {
                let applicationDelegate = UIApplication.sharedApplication().delegate as AppDelegate
//                let localBackgroungSessionCompletionHandler : ()->() = applicationDelegate.backgroundSessionCompletionHandler!
//                if let isNotEmpty: ()? = localBackgroungSessionCompletionHandler{
//                    applicationDelegate.backgroundSessionCompletionHandler = nil
//                    localBackgroungSessionCompletionHandler()
//                }
                //applicationDelegate.backgroundSessionCompletionHandler()
            }
            return
        })
    }
    
    // MARK: Setup view
    
    func setupView(){
        self.setupTableView()
    }
    
    func setupTableView(){
        self.tableView.registerClass(MTEpisodeTableViewCell.classForCoder(), forCellReuseIdentifier: "EpisodeCell")
    }
    
    // MARK: load and stuff
    func loadPodcast(){
        let ud = NSUserDefaults.standardUserDefaults()
        let dict = ud.objectForKey("MTPodcast") as? NSDictionary
        if let tempVar = dict{
            self.setPodcastDictionaryTo(dict!)
        }
    }
    
    func setPodcastDictionaryTo(podcastDictionary: NSDictionary){
        self.podcast = podcastDictionary
        self.updateView()
        self.fetchAndParseFeed()
    }
    
    func updateView(){
        self.title = self.podcast!.objectForKey("collectionName") as? String
    }
    
    func fetchAndParseFeed(){
        if (self.podcast? == nil){ return }
        let url = NSURL(string: self.podcast!.objectForKey("feedUrl") as String)
        
        if(url == nil){
            return
        }
        
        if let tempVar = self.feedParser {
            self.feedParser?.stopParsing()
            self.feedParser?.delegate = nil
            self.feedParser = nil
        }
        
        if let tempVar = self.episodes {
            self.episodes = nil
        }
        
        self.feedParser = MWFeedParser(feedURL: url)
        
        self.feedParser?.feedParseType = ParseTypeFull
        self.feedParser?.delegate = self
        
        SVProgressHUD.showWithMaskType(UInt(SVProgressHUDMaskTypeGradient))
        
        let success = self.feedParser?.parse()
    }
    
    
    func downloadEpisodeWithFeedItem(feedItem: MWFeedItem){
        self.setBackgroundSessionCompletionHandler()
        // extract remove url for feed item
        let URLforEpisode = self.urlForFeedItem(feedItem) as NSURL?
        if let tempVar = URLforEpisode{
            //schedule download task
            self.session?.downloadTaskWithURL(URLforEpisode!).resume()
            
            //update progress buffer
            self.progressBuffer[URLforEpisode!.absoluteString!] = NSNumber(double: 0.0)
        }
    }
    
}

// MARK: TableView
extension ViewController:UITableViewDataSource, UITableViewDelegate{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let feedItem = self.episodes?.objectAtIndex(indexPath.row) as MWFeedItem
        let webURL = self.urlForFeedItem(feedItem)
        let webURLString = webURL?.absoluteString!
        
        let wasDownloaded = self.progressBuffer[webURLString!] as NSNumber?
        
        if wasDownloaded == nil{
            self.downloadEpisodeWithFeedItem(feedItem)
        }
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.episodes != nil ? 1: 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if (self.episodes != nil){
            return self.episodes!.count
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell = tableView.dequeueReusableCellWithIdentifier("EpisodeCell", forIndexPath: indexPath) as MTEpisodeTableViewCell

        let feedItem = self.episodes?.objectAtIndex(indexPath.row) as MWFeedItem
        let webURL = self.urlForFeedItem(feedItem)
        cell.textLabel.text = feedItem.title
        cell.detailTextLabel?.text = "\(feedItem.date)"
        
        var progress = self.progressBuffer[webURL!.absoluteString!] as NSNumber?
        
        if progress == nil{
            progress = NSNumber(double: 0.0)
        }
        
        cell.progress = progress!.floatValue
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool{
        return false
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool{
        return false
    }
    
    func cellForDownloadTask(downloadTask: NSURLSessionDownloadTask)->MTEpisodeTableViewCell?{
        let URLforDownloadTask = downloadTask.originalRequest.URL
        let count = self.episodes!.count as Int
        var urlForEpisode : NSURL?
        for index in 0...count{
            urlForEpisode = self.urlForFeedItem(self.episodes?[index] as MWFeedItem)
            if urlForEpisode == URLforDownloadTask{
                return self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as? MTEpisodeTableViewCell
            }
        }
        
        return nil

    }
}

// MARK: Parsely
extension ViewController: MWFeedParserDelegate{

    func feedParser(parser: MWFeedParser,didParseFeedItem item: MWFeedItem){
        if (self.episodes == nil){
            self.episodes = NSMutableArray()
        }
        self.episodes?.addObject(item)
        
        //Update Progress Buffer
        let webURL = self.urlForFeedItem(item)
        let localURL = self.URLForEpisodeWithName(webURL?.lastPathComponent)
        
        if(NSFileManager.defaultManager().fileExistsAtPath(localURL!.path!))
        {
            println(webURL)
            println(webURL!.absoluteString!)
            self.progressBuffer[webURL!.absoluteString!] = NSNumber(double: 1.0)
        }
    }
    
    func feedParserDidFinish(parser: MWFeedParser){
        SVProgressHUD.dismiss()
        
        self.tableView.reloadData()
    }
    
    func urlForFeedItem(feedItem: MWFeedItem)->NSURL?{
        //extract enclosure
        let enclosures = feedItem.enclosures as NSArray?
        if let tempVar = enclosures {
            if (enclosures?.count>0){
                //do something
                let enclosure = enclosures?.objectAtIndex(0) as NSDictionary
                let urlString = enclosure.objectForKey("url") as NSString
                return NSURL(string: urlString)
            }
            return nil
        }
        return nil
        
    }
}
// MARK: Session stuff
extension ViewController: NSURLSessionDelegate, NSURLSessionDownloadDelegate{
    func backgroundSession()-> NSURLSession{
        
        var session : NSURLSession! = nil
        
        var  onceToken : dispatch_once_t = 0
        
        dispatch_once(&onceToken){
            let sessionConfig = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("com.mobiletuts.Singlecast.BackgroundSession")
            session = NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        }
        
        return session
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL){
        //Write File to Disk
        self.moveFileWithURL(location, downloadTask: downloadTask)
        
        //update progress buffer
        let webURLString = downloadTask.originalRequest.URL.absoluteString!
        self.progressBuffer[webURLString] = NSNumber(double: 1.0)
        self.invokeBackgroundSessionCompletionHandler()
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        
        let cell = self.cellForDownloadTask(downloadTask) as MTEpisodeTableViewCell?
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            cell?.progress = Float(progress)
            return
        })
    }
    
    func moveFileWithURL(URL: NSURL, downloadTask: NSURLSessionDownloadTask){
        let fileName = downloadTask.originalRequest.URL.lastPathComponent
        //local url
        let localURL = self.URLForEpisodeWithName(fileName)
        
        let fm = NSFileManager.defaultManager()
        
        if(fm.fileExistsAtPath(URL.path!)){
            var error : NSError?
            
            fm.moveItemAtURL(URL, toURL: localURL!, error: &error)
            
            if let tempVar = error{
             NSLog("unable to move temp file to destination %@, %@", error!, error!.userInfo!)
            }
             NSLog("temp location %@, final location%@", URL, localURL!)
        }
        
    }
    
    func URLForEpisodeWithName(name: String?) -> NSURL?{
        if (name? == nil){ return nil}
        return self.episodeDirectory().URLByAppendingPathComponent(name!)
    }
    func episodeDirectory() -> NSURL{
        let fm = NSFileManager.defaultManager()
        let documents = fm.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as NSURL
        let episodes = documents.URLByAppendingPathComponent("Episodes", isDirectory: true)
        
        var error : NSError?
        if(!fm.fileExistsAtPath(episodes.path!)){
            
            fm.createDirectoryAtURL(episodes, withIntermediateDirectories: true, attributes: nil, error: &error)
        }
        if let tempVar = error{
            NSLog("unable to create episodes directory %@, %@", error!, error!.userInfo!)
        }
        
        
        return episodes
    }
    
}
