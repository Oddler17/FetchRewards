//
//  EventsListCell.swift
//  FetchRewards
//
//  Created by Arseniy Oddler on 1/20/21.
//

import UIKit

class EventsListCell: UITableViewCell {
    
    // MARK: - Public
    static var identifier: String {
        return "EventsListCell"
    }

    func configure(with content: Event?, isFavorite: Bool = false) {
        self.isFavorite = isFavorite
        eventCellContent = content
    }
    
    private var isFavorite = false

    private var eventCellContent: Event? {
        didSet {
            /*
             Just take first picture here to show something.
             Of course everything depends on what exactly and how we need to show.
             I just want to show understanding of parsing and getting data from JSON here.
             */
            let imageUrl = eventCellContent?.performers.first?.imageUrl
            setMainImage(with: imageUrl)
            titleLabel.text = eventCellContent?.title
            dateLabel.text = createCorrectDateString(from: eventCellContent?.localDateTime)
            favoriteImageView.isHidden = !isFavorite
        }
    }
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.isUserInteractionEnabled = true
        backgroundColor = .secondaryBackground
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    private func setMainImage(with imageUrl: String?) {
        guard let imageUrl = imageUrl else {
            return
        }
        /*
          Ideally UI component should not download picture by itself. ViewModel should ask API service to do it.
          But I am using custom third-party component in this case because it will short the code significantly.
          Using SwiftUI, it's much easier to do it, but app should work at IOS 12, where SwiftUI is not allowed.
         */
        self.thumbnailImageView.loadImage(urlString: imageUrl)
    }
    
    // Ideally, Separate Service should be done for this
    private func createCorrectDateString(from dateString: String?) -> String {
        guard let dateString = dateString else {
            print("Error: There is not date provided for this event")
            return ""
        }
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let dateFormatterReturn = DateFormatter()
        dateFormatterReturn.dateFormat = "HH:mm, MMM dd, yyyy"

        if let date = dateFormatterGet.date(from: dateString) {
            return dateFormatterReturn.string(from: date)
        }
        print("Error: An error decoding the string to date")
        return ""
    }
    
    // MARK: - Private UI Elements
    private let cellView: UIView = {
        let view = UIView()
        view.backgroundColor = .primaryBackground
        view.layer.cornerRadius = .roundRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let thumbnailImageView: CachedImageView = {
        let imageView = CachedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = .roundRadius
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "defaultImage")
        return imageView
    }()
    
    private let favoriteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = .roundRadius
        imageView.clipsToBounds = true
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "heart")
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .title
        label.backgroundColor = .clear
        label.textColor = .brightRed
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .body
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
}

// MARK: - UI Layout
private extension EventsListCell {

    func setupView() {
        addSubview(cellView)
        
        // just some virtual size depends on current screen size.
        // This is an exception that I am using it - but requirements for layout are free
        let contentSize: CGFloat = (UIScreen.main.bounds.width - 3 * .spacing) / 3

        self.selectionStyle = .none
        
        // Content View
        NSLayoutConstraint.activate([
            cellView.topAnchor.constraint(equalTo: self.topAnchor),
            cellView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -.spacing),
            cellView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: .spacing),
            cellView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -.spacing)
        ])
        
        // Main Image View
        cellView.addSubview(thumbnailImageView)
        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: cellView.topAnchor, constant: .spacing),
            thumbnailImageView.leftAnchor.constraint(equalTo: cellView.leftAnchor, constant: .spacing),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: contentSize),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: contentSize),
            thumbnailImageView.bottomAnchor.constraint(lessThanOrEqualTo: cellView.bottomAnchor, constant: -.spacing)
        ])
        
        // Heart Image View
        cellView.addSubview(favoriteImageView)
        NSLayoutConstraint.activate([
            favoriteImageView.centerXAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor),
            favoriteImageView.centerYAnchor.constraint(equalTo: thumbnailImageView.topAnchor),
            favoriteImageView.widthAnchor.constraint(equalToConstant: contentSize / 4),
            favoriteImageView.heightAnchor.constraint(equalToConstant: contentSize / 4)
        ])


        // Title Label
        cellView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: cellView.topAnchor, constant: .spacing),
            titleLabel.rightAnchor.constraint(equalTo: cellView.rightAnchor, constant: -.spacing),
            titleLabel.leftAnchor.constraint(equalTo: thumbnailImageView.rightAnchor, constant: .spacing)
        ])
        
        // Date Label
        cellView.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: .labelsSpacing),
            dateLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),
            dateLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
            dateLabel.bottomAnchor.constraint(lessThanOrEqualTo: cellView.bottomAnchor, constant: -.spacing)
        ])
    }
}
