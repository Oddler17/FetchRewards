//
//  ParsingService.swift
//  FetchRewards
//
//  Created by Arseniy Oddler on 1/20/21.
//

import Foundation

fileprivate enum ParsingError: String, Error {
    case parsingError = "File does not exist"
}

protocol ParsingProtocol {
    func parsePage(jsonData: Data) -> ReceivedPage?
}

class ParsingService: ParsingProtocol {

    func parsePage(jsonData: Data) -> ReceivedPage? {
        let decoder = JSONDecoder()
        if let page = try? decoder.decode(ReceivedPage.self, from: jsonData) {
            return page
        }
        print(ParsingError.parsingError.localizedDescription)
        return nil
    }
}
