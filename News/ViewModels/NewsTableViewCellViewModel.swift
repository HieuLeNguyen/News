//
//  NewsTableViewCellViewModel.swift
//  News
//
//  Created by Nguyễn Văn Hiếu on 12/12/24.
//

import UIKit

class NewsTableViewCellViewModel {
    let title: String
    let subtitle: String?
    let imageURL: URL?
    var imageData: Data? = nil
    
    init(title: String, subtitle: String?, imageURL: URL?) {
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
    }
}

