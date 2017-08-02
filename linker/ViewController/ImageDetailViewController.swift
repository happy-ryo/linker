//
//  ImageDetailViewController.swift
//  linker
//
//  Created by happy_ryo on 2016/05/29.
//  Copyright © 2016年 Citron Syrup. All rights reserved.
//

import Foundation
import UIKit

class ImageDetailViewController: UIViewController {
	@IBOutlet weak var imageView: UIImageView!
	var contentRepository: ContentRepository?

	override func viewWillAppear(_ animated: Bool) {
		guard let contentRepository = contentRepository else {
			return
		}
		imageView.sd_setImage(with: URL(string: contentRepository.imagePath))
	}

	@IBAction func closeViewControllre() {
		self.dismiss(animated: true, completion: nil)
	}
    
}
