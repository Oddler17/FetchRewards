//
//  DetailedEventViewModel.swift
//  FetchRewards
//
//  Created by Arseniy Oddler on 1/20/21.
//

import UIKit

class DetailedEventViewModel {
    
    private struct Constants {
        static let noResultsMessage = "No results found"
        static let heartImageName = "heart"
        static let emptyHeartImageName = "emptyHeart"
    }
    
    // MARK: - Properties
    private let fileService: FileSavingProtocol
    private let showAlertClosure: (()->())?
    private let reloadContent: ((String, String, String, String)->())?
    private var eventToShow: Event?
    
    // MARK: - Initializaton
    init(fileService: FileSavingProtocol = FileSavingService(),
         eventToShow: Event? = nil,
         showAlert: (()->())? = nil,
         reloadContent: ((String, String, String, String)->())? = nil) {

        self.showAlertClosure = showAlert
        self.fileService = fileService
        self.eventToShow = eventToShow
        self.reloadContent = reloadContent
        
        reloadUI()
    }

    var alertMessage: String? {
        didSet {
            showAlertClosure?()
        }
    }
    
    // MARK: - Public
    func isEventFavorite() -> Bool {
        guard let event = eventToShow else {
            return false
        }
        return fileService.isEventFavorite(with: event.id)
    }
    
    func favoritePressed() {
        isEventFavorite() ? removeFromFavorites() : addToFavorite()
    }
    
    private func addToFavorite() {
        guard let event = eventToShow else {
            return
        }
        fileService.addEventToFavorites(with: event.id)
        reloadUI()
    }
    
    private func removeFromFavorites() {
        guard let event = eventToShow else {
            return
        }
        fileService.removeEventFromFavorites(with: event.id)
        reloadUI()
    }
    
    private func reloadUI() {
        guard let event = eventToShow else {
            return
        }
        let imageUrl = event.performers.first?.imageUrl ?? ""
        let buttonImageName = isEventFavorite() ? Constants.heartImageName : Constants.emptyHeartImageName
        reloadContent?(imageUrl, event.title, createCorrectDateString(from: event.localDateTime), buttonImageName)
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
}
