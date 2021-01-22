//
//  DetailedEventView.swift
//  FetchRewards
//
//  Created by Arseniy Oddler on 1/20/21.
//

import UIKit

class DetailedEventView: UIViewController {
    
    private struct Constants {
        static let alertTitle = "Alert"
        static let closeAlertButtonTitle = "Ok"
        static let cancelButtonTitle = "Cancel"
    }
    
    private var eventToShow: Event?
    private var isFavorite: Bool {
        guard let vm = viewModel else {
            return false
        }
        return vm.isEventFavorite()
    }
    private var viewModel: DetailedEventViewModel?
    
    // MARK: - Initialization
    convenience init() {
        self.init(event: nil)
    }
    
    init(event: Event?) {
        if let event = event {
            self.eventToShow = event
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        initViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func initViewModel() {
        let reloadContentClosure = { [weak self] (imageUrlString: String, titleText: String, dateText: String, imageName: String) in
            DispatchQueue.main.async {
                self?.thumbnailImageView.loadImage(urlString: imageUrlString)
                self?.titleLabel.text = titleText
                self?.dateLabel.text = dateText
                self?.favoritesButton.setImage(UIImage(named: imageName), for: .normal)
            }
        }
        let showAlertClosure = { [weak self] () in
            DispatchQueue.main.async {
                if let message = self?.viewModel?.alertMessage {
                    self?.showAlert(message)
                }
            }
        }
        /* Dependency Injection */
        viewModel = DetailedEventViewModel(eventToShow: eventToShow, showAlert: showAlertClosure, reloadContent: reloadContentClosure)
    }
    
    // MARK: - Private - UI Setup
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.cancelButtonTitle, for: .normal)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let favoritesButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(addToFavorite(sender:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .title
        label.backgroundColor = .clear
        label.textColor = .brightRed
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let thumbnailImageView: CachedImageView = {
        let imageView = CachedImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = .roundRadius
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .body
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    @objc private func goBack() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func addToFavorite(sender: UIButton) {
        viewModel?.favoritePressed()
    }
    
    private func setupUI() {
        view.backgroundColor = .secondaryBackground
        
        // Cancel Button
        view.addSubview(cancelButton)
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            cancelButton.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: .buttonWidth),
            cancelButton.heightAnchor.constraint(equalToConstant: .buttonHeight)
        ])

        // Add to Favorites Button
        view.addSubview(favoritesButton)
        NSLayoutConstraint.activate([
            favoritesButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: .spacing),
            favoritesButton.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, constant: -.spacing),
            favoritesButton.widthAnchor.constraint(equalToConstant: .buttonHeight),
            favoritesButton.heightAnchor.constraint(equalToConstant: .buttonHeight)
        ])
        
        // Title Label
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: .spacing),
            titleLabel.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, constant: -.spacing),
            titleLabel.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, constant: .spacing)
        ])
        
        // Main Image View
        view.addSubview(thumbnailImageView)
        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: .spacing),
            thumbnailImageView.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),
            thumbnailImageView.leftAnchor.constraint(equalTo: titleLabel.leftAnchor)
        ])

        // Date Label
        view.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: .spacing),
            dateLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),
            dateLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor)
        ])
    }

    func showAlert( _ message: String ) {
        let alert = UIAlertController(title: Constants.alertTitle, message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: Constants.closeAlertButtonTitle, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
