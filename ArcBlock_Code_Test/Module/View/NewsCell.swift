//
//  UserCell.swift
//  ArcBlock_Code_Test
//
//  Created by HanLiu on 2021/2/27.
//

import UIKit

class NewsCell: UITableViewCell {
    
    struct Style {
        static let space: CGFloat = 8.0
        static let contentLabelMinHeight: CGFloat = 30.0
        static let imageSize: CGFloat = 64
    }
    
    static let reuseIdentifier = "NewsCell"
    fileprivate var imageUrls = [String]()
    private var layout: UICollectionViewFlowLayout!

    private lazy var containerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Style.space
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var imagesCollectionView: UICollectionView = {
        layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.size.width - Style.space * 6) / 3.0, height: Style.imageSize)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .white
        collection.dataSource = self
        collection.delegate = self
        collection.showsVerticalScrollIndicator = false
        collection.register(NewsImageCell.self, forCellWithReuseIdentifier: NewsImageCell.identifier)
        return collection
    }()
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupView()
        updateLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("nib")
    }
    
    func applyData(_ news: News) {
        let noImage = (news.imgUrls == nil) || (news.imgUrls?.count == 0)
        imagesCollectionView.isHidden = noImage
        contentLabel.text = (news.content ?? "") + ((news.link != nil) ? "\n" : "") + (news.link ?? "")

        if !noImage {
            buildImageStacks(news: news)
        }
    }
    
    private func setupView() {
        contentView.addSubview(containerStack)
        containerStack.addArrangedSubview(contentLabel)
        containerStack.addArrangedSubview(imagesCollectionView)
    }
    
    private func updateLayout() {
        containerStack.constraint(in: contentView, top: Style.space, bottom: -Style.space)
    }
    
    private func buildImageStacks(news: News) {
        if let imagesUrls = news.imgUrls {
            self.imageUrls = imagesUrls
            var rows = 0
            if imagesUrls.count <= 3 {
                rows = 1
                imagesCollectionView.heightAnchor.constraint(equalToConstant: Style.imageSize).isActive = true
            } else {
                rows = (imagesUrls.count % 3) == 0 ? imagesUrls.count % 3 : (imagesUrls.count / 3 + 1)
                let height = Style.imageSize * CGFloat(rows) + CGFloat(layout.minimumLineSpacing) * CGFloat(rows - 1)
                imagesCollectionView.heightAnchor.constraint(equalToConstant: height).isActive = true
            }
            
            imagesCollectionView.reloadData()
        }
    }
}

extension NewsCell : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsImageCell.identifier, for: indexPath) as! NewsImageCell
        cell.setImage(imageUrls[indexPath.row])
        return cell
    }

}

class NewsImageCell: UICollectionViewCell {
    static let identifier = "NewsImageCell"
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.constraint(in: contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(_ url: String) {
        imageView.hl_setImage(url: url, completion: nil)
    }
}
