//
//  LocalSummaryProvider.swift
//  HeadwayPlayer
//
//  Created by Yevhen Pravda on 18.11.2024.
//

struct LocalSummaryProvider: SummaryProviderProtocol {
    private let localBookResources: LocalBookSummaryResources
    
    init(localBookResources: LocalBookSummaryResources = .init()) {
        self.localBookResources = localBookResources
    }
    
    func fetchSummary() async throws -> BookSummary {
        return .init(
            coverURL: localBookResources.coverURL,
            chapters: localBookResources.chapters
        )
    }
}
