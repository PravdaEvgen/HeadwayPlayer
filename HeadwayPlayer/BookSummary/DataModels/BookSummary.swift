//
//  BookSummary.swift
//  HeadwayPlayer
//
//  Created by Yevhen Pravda on 18.11.2024.
//

import Foundation

struct BookSummary: Equatable {
    let coverURL: URL
    let chapters: [Chapter]
}

struct Chapter: Equatable {
    let shortMoto: String
    let chapterAudioURL: URL
}
