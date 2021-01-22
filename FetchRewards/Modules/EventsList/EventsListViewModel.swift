//
//  EventsListViewModel.swift
//  FetchRewards
//
//  Created by Arseniy Oddler on 1/20/21.
//

import UIKit

class EventsListViewModel {
    
    private struct Constants {
        static let noResultsMessage = "No results found"
    }
    
    // MARK: - Closures for MVVM
    private let reloadTableViewClosure: (()->())?
    private let showAlertClosure: (()->())?
    private let apiService: APIServiceProtocol
    private let parsingService: ParsingProtocol
    private let fileService: FileSavingProtocol

    var alertMessage: String? {
        didSet {
            self.showAlertClosure?()
        }
    }

    // MARK: - Initializaton
    init(apiService: APIServiceProtocol = APIService(),
         parsingService: ParsingProtocol = ParsingService(),
         fileService: FileSavingProtocol = FileSavingService(),
         reloadTable: (()->())? = nil,
         showAlert: (()->())? = nil) {

        self.apiService = apiService
        self.parsingService = parsingService
        self.fileService = fileService
        self.reloadTableViewClosure = reloadTable
        self.showAlertClosure = showAlert
        
        // Start fetching from the very first page on start
        fetchMoreData()
    }

    // MARK: - Private
    private var lastDownloadedPageNumber = 0
    private var events: [Event] = [] {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
    private var filteredEvents: [Event] = [] {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
    private var numberOfEventsPerPage = 0
    private var isSearching = false

    private func fetchMoreData() {
        // prevents any downloading while searching
        guard filteredEvents.isEmpty else {
            return
        }
        apiService.loadNextPageData(currentLastPage: lastDownloadedPageNumber + 1) { [weak self] data in
            guard let page = self?.parsingService.parsePage(jsonData: data) else {
                return
            }
            self?.events += page.events
            self?.lastDownloadedPageNumber = page.meta.currentPage
            self?.numberOfEventsPerPage = page.meta.eventsPerPage
        }
    }

    // MARK: - Public - Info for the Cell
    var numberOfPackages: Int {
        return isSearching ? filteredEvents.count : events.count
    }
    
    func getEventForCell(at index: Int) -> Event? {
        return isSearching ? filteredEvents[index] : events[index]
    }
    
    func fetchMoreEventsIfNeeded(at index: Int) {
        let minIndexToStartDownloading = numberOfEventsPerPage * lastDownloadedPageNumber - numberOfEventsPerPage / 2
        if index > minIndexToStartDownloading {
            fetchMoreData()
        }
    }
    
    func performSearch(searchText: String) {
        isSearching = !searchText.isEmpty
        if searchText.isEmpty {
            filteredEvents = []
            return
        }
        filteredEvents = events.filter { $0.title.contains(searchText) }
        if filteredEvents.isEmpty {
            alertMessage = Constants.noResultsMessage
        }
    }
    
    func isFavorite(at index: Int) -> Bool {
        let event = isSearching ? filteredEvents[index] : events[index]
        return fileService.isEventFavorite(with: event.id)
    }
}
