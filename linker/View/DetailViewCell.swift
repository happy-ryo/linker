//
//  DetailViewCell.swift
//  linker
//
//  Created by happy_ryo on 2016/05/03.
//  Copyright © 2016年 Citron Syrup. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class DetailViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!
    var contentRepository: ContentRepository?
    func loadContent(_ content: ContentRepository) {
        dateLabel.text = content.date
        postLabel.text = content.text
        contentRepository = content
    }
}

class ImageViewCell: DetailViewCell {
    @IBOutlet weak var contentImageView: UIImageView?

    override func loadContent(_ content: ContentRepository) {
        super.loadContent(content)        
        contentImageView?.sd_setImage(with: URL(string: content.imagePath))
    }
    
    @IBAction func openImageDetailView() {
        
    }
}
