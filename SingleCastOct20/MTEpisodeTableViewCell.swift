//
//  MTEpisodeTableViewCell.swift
//  
//
//  Created by David Lam on 21/10/14.
//
//

import UIKit

class MTEpisodeTableViewCell: UITableViewCell {

    var progress : Float = 0.0{
    
        willSet{
            self.progress = newValue
            self.updateView()
        }
    
    }
    
    var progressView = UIView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: reuseIdentifier)
        let size = self.contentView.bounds.size
        self.textLabel.backgroundColor = UIColor.clearColor()
        self.detailTextLabel?.backgroundColor = UIColor.clearColor()
        
        self.progressView = UIView(frame: CGRectMake(0.0, 0.0, size.width, size.height))
        
        //Configure Progress View
        
        self.progressView.autoresizingMask = (UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight)
        self.progressView.backgroundColor = UIColor(red: 0.678, green: 0.886, blue: 0.557, alpha: 1.0)
        //self.progressView.backgroundColor = UIColor.blackColor()
        self.contentView.insertSubview(self.progressView, atIndex: 0)
        
        self.updateView()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateView(){
        let size = self.contentView.bounds.size
        
        var frame = self.progressView.frame
        frame.size.width = size.width * CGFloat(self.progress)
        self.progressView.frame = frame
    }
}
/*
*/