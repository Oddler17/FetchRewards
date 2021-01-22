//
//  FileSavingService.swift
//  FetchRewards
//
//  Created by Arseniy Oddler on 1/20/21.
//

/*
 I personally believe that adding to favorites should be done on the backend side through the request from the app.
 But here we need to save data locally.
 - NSUserDefaults is not good for it. Saving user preferences in NSUserDefaults is ok - not data.
 - Core Data or any DBs are too much I think in this case just to send one array
 - KeyChain is used mostly for protected data. And also not for potentially large sets of data
 That's why I am just using file to save favorites inside documents folder in the app's bundle
 Code may be not good here - worked with saving to files very long time ago )
 */

import Foundation

fileprivate enum FileReadWriteError: String, Error {
    case fileNotExists = "File not found"
    case readError = "Can't read from file"
    case writeError = "Can't save to file"
    case deleteError = "Can't delete from file"
    case alreadyPresent = "This item is already in Favorites"
}

protocol FileSavingProtocol {
    func addEventToFavorites(with id: Int)
    func removeEventFromFavorites(with id: Int)
    func removeAllFromFavorites()
    func isEventFavorite(with id: Int) -> Bool
}

class FileSavingService: FileSavingProtocol {
    
    private struct Constants {
        static let fileName = "Save"
        static let fileExtension = ".txt"
        static let dataSeparator = "***"
    }
    
    // MARK: - Public Interface
    func addEventToFavorites(with id: Int) {
        if isEventFavorite(with: id) {
            print(FileReadWriteError.alreadyPresent)
            return
        }
        let currentText = readFileContent()
        let addedText = String(id) + Constants.dataSeparator
        writeToFile(content: currentText + addedText)
    }
    
    func removeEventFromFavorites(with id: Int) {
        var currentText = readFileContent()
        let textToDelete = String(id) + Constants.dataSeparator
        if currentText.contains(textToDelete) {
            currentText = currentText.replacingOccurrences(of: textToDelete, with: "")
            writeToFile(content: currentText)
        } else {
            print(FileReadWriteError.deleteError)
        }
    }
    
    func removeAllFromFavorites() {
        writeToFile(content: "")
    }
    
    func isEventFavorite(with id: Int) -> Bool {
        let checkedText = String(id) + Constants.dataSeparator
        let text = readFileContent()
        return text.contains(checkedText)
    }
    
    // MARK: - Private
    private func getDocumentsDirectory() -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first
    }

    private func writeToFile(content: String) {
        guard let filename = getDocumentsDirectory()?.appendingPathComponent(Constants.fileName + Constants.fileExtension) else {
            print(FileReadWriteError.fileNotExists)
            return
        }
        do {
            try content.write(to: filename, atomically: false, encoding: .utf8)
        }
        catch {
            print(FileReadWriteError.writeError)
        }
    }
    
    private func readFileContent() -> String {
        guard let filename = getDocumentsDirectory()?.appendingPathComponent(Constants.fileName + Constants.fileExtension) else {
            print(FileReadWriteError.fileNotExists.localizedDescription)
            return ""
        }
        do {
            let text = try String(contentsOf: filename, encoding: .utf8)
            return text
        }
        catch {
            print(FileReadWriteError.readError)
            return ""
        }
    }
}
