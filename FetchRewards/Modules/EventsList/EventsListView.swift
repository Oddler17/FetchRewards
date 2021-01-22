//
//  EventsListView.swift
//  FetchRewards
//
//  Created by Arseniy Oddler on 1/20/21.
//

///Hello everyone.
///Unfortunately, if you write this project according to all the rules, then it will take a very long time.
///
///Especially because I like experimenting and try to learn new things, and therefore do something in a way that I have never done before.
///In particular, I haven't created an interface entirely in code very often.
///And also worked with writing / reading from a file for a long time.
///For the same reason I did not use third-party frameworks (FYI I know how to use cocoa pods for example).
///And I used the opportunity to improve my skills.
///
///In contrast, I wrote tests quite often and a lot (mostly using Quick & Nimble frameworks).
///If this is critical, I can write tests, but it will take several hours to cover the project well. And I decided not to write them in this case.
///
///I also used the MVVM for practice (since I worked mainly with VIPER).
///
///I tried to show my understanding of the right approaches. And also make the project fully functional.
///In some places, I ignored them due to the time spent (once again I apologize that I do not have enough time to write the whole project using the best approaches), but I left comments.
///I also didn't spend time creating a good UI design.
///In any case, I will be happy to answer any questions about the project and discuss various solutions.
///Thanks for the opportunity.

/*
 TODO:
 - Tests
 */

import UIKit

class EventsListView: UIViewController {
    
    private struct Constants {
        static let searchDelay = 0.75
        static let alertTitle = "Alert"
        static let closeAlertButtonTitle = "Ok"
    }

    // MARK: - Properties
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .secondaryBackground
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(EventsListCell.self, forCellReuseIdentifier: EventsListCell.identifier)
        table.separatorStyle = .none
        return table
    }()
    
    private let searchBar: UISearchBar = {
        let search = UISearchBar()
        search.backgroundColor = .secondaryBackground
        search.translatesAutoresizingMaskIntoConstraints = false
        return search
    }()
    
    private var statusBarHeight: CGFloat {
        UIApplication.shared.statusBarFrame.size.height
    }
    
    private var viewModel: EventsListViewModel?
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        setupUI()
        initViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    private func setupUI() {
        view.backgroundColor = .secondaryBackground

        view.addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: self.view.topAnchor, constant: statusBarHeight),
            searchBar.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            searchBar.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: .searchBarHeight)
        ])
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor)
        ])
    }
    
    private func initViewModel() {
        let reloadTableViewClosure = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
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
        viewModel = EventsListViewModel(reloadTable: reloadTableViewClosure, showAlert: showAlertClosure)
    }
    
    func showAlert( _ message: String ) {
        let alert = UIAlertController(title: Constants.alertTitle, message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: Constants.closeAlertButtonTitle, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableView DataSource & Delegate
extension EventsListView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EventsListCell.identifier, for: indexPath) as? EventsListCell else {
            fatalError("Can't find package cell") // TODO: Handle Error
        }
        guard let vm = viewModel else {
            return UITableViewCell()
        }
        let eventForCell = vm.getEventForCell(at: indexPath.row)
        let isFavorite = vm.isFavorite(at: indexPath.row)

        /* Dependency Injection */
        cell.configure(with: eventForCell, isFavorite: isFavorite)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfPackages ?? 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let vm = viewModel else {
            return
        }
        vm.fetchMoreEventsIfNeeded(at: indexPath.row)
    }
    
    /*
     To simplify the code I skipped creating Router
     Ideally navigation should be handled by Router class through viewModel
     I also did not use navigation controller (expected in such cases) - just modal presentation
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let event = viewModel?.getEventForCell(at: indexPath.row) else {
            print("Error: No Event found for this cell")
            return 
        }
        /* Dependency Injection */
        // It was possible to pass image as well, but I think passing one object is better
        // Url is inside of an object. We will load image for url again.
        present(DetailedEventView(event: event), animated: true, completion: nil)
    }
}

// MARK: - UISearchBar Delegate
extension EventsListView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.searchDelay) { [weak self] in
            guard let vm = self?.viewModel else {
                return
            }
            vm.performSearch(searchText: searchText)
        }
    }
}

