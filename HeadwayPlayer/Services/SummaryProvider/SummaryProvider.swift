//
//  SummaryProvider.swift
//  HeadwayPlayer
//
//  Created by Yevhen Pravda on 18.11.2024.
//

import Foundation
import Dependencies

protocol SummaryProviderProtocol {
  func fetchSummary() async throws -> BookSummary
}

enum SummaryProviderKey: DependencyKey {
    static let liveValue: any SummaryProviderProtocol = LocalSummaryProvider()
    static var testValue: any SummaryProviderProtocol = liveValue
}
