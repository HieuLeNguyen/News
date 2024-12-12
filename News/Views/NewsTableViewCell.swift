//
//  NewsTableViewCell.swift
//  News
//
//  Created by Nguyễn Văn Hiếu on 12/12/24.
//
/**
 Tạo một cell custom - Bằng việc ghi đè lại mã và layout default
 
 + identifier
 + init cell
 + layout Subviews
 + prepare Subviews
 + configure
 */

import UIKit

class NewsTableViewCell: UITableViewCell {
    
    // MARK: - Variables
    static let identifier: String = "NewsTableViewCell"
    
    // MARK: - UI Componnets In View
    private let newsTitleLabel: UILabel = {
        let _label = UILabel()
        _label.font = .systemFont(ofSize: 24, weight: .medium)
        _label.numberOfLines = 0
        return _label
    }()
    
    private let subTitleLabel: UILabel = {
        let _label = UILabel()
        _label.font = .systemFont(ofSize: 16, weight: .regular)
        _label.numberOfLines = 0
        return _label
    }()
    
    private let newsImageView: UIImageView = {
        let _imageView = UIImageView()
        _imageView.contentMode = .scaleAspectFill
        _imageView.clipsToBounds = true
        _imageView.backgroundColor = .secondarySystemBackground
        return _imageView
    }()
    
    
    // MARK: - Overrides
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(newsTitleLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(newsImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // TODO: - Lấy ra size ngay khi khởi tạo theo màn hình
        newsTitleLabel.frame = CGRect(x: 10,
                                      y: 0,
                                      width: contentView.frame.width - 170,
                                      height:contentView.frame.height / 2)
        
        subTitleLabel.frame = CGRect(x: 10,
                                     y: 70,
                                     width: contentView.frame.width - 170,
                                     height:contentView.frame.height / 2)
        
        newsImageView.frame = CGRect(x: contentView.frame.width - 150,
                                     y: 5,
                                     width: 160,
                                     height:contentView.frame.height - 10)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        newsTitleLabel.text = nil
        subTitleLabel.text = nil
        newsImageView.image = nil
    }
    
    // MARK: - Configuration
    func configure(with viewModel: NewsTableViewCellViewModel) {
        newsTitleLabel.text = viewModel.title
        subTitleLabel.text = viewModel.subtitle
        // Image
        if let data = viewModel.imageData {
            newsImageView.image = UIImage(data: data)
        } else if let url = viewModel.imageURL {
            /// featch image or Kingfisher
            // TODO: - Use Pod Kingfisher
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let data = data, error == nil else { return }
                viewModel.imageData = data
                DispatchQueue.main.async {
                    self?.newsImageView.image = UIImage(data: data)
                }
            }.resume()
        }
    }
}


