//
//  URL+Extensions.swift
//  Koleda
//
//  Created by Oanh tran on 7/1/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation

extension URL {
    static func bp_temporaryFileURL(for filename: String) -> URL {
        let temporaryFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
        return temporaryFileURL
    }
    
    func parameter(forName name: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == name })?.value
    }
    
    /**
     Returns url in ".invalid" top domain, which may not be installed as a top-level domain in the Domain Name System
     (DNS) of the Internet.
     - wikipedia: https://en.wikipedia.org/wiki/.invalid
     */
    static var invalidURL: URL {
        return URL(string: "https://this.url.is.invalid")!
    }
}
