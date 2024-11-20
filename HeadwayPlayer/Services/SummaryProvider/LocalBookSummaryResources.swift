//
//  LocalBookSummaryResources.swift
//  HeadwayPlayer
//
//  Created by Yevhen Pravda on 18.11.2024.
//

import Foundation

struct LocalBookSummaryResources {
    private static let chapterSoundNames = [
        "sound1",
        "sound2",
        "sound3",
        "sound4"
    ]
    
    private static let chapterMottos = [
        "Lorem ipsum dolor sit amet",
        "Curabitur mollis blandit pretium",
        "Proin non placerat diam",
        "Sed rutrum massa massa"
    ]
    
    private static let coverName = "bookCover"
    
    let chapters: [Chapter] = zip(chapterSoundNames, chapterMottos)
        .compactMap { soundName, motto in
            guard
                let url = Bundle.main.url(forResource: soundName, withExtension: "mp3")
            else {
                return nil
            }
            return Chapter(shortMoto: motto, chapterAudioURL: url)
        }
    
    
    let coverURL: URL = Bundle.main.url(forResource: coverName, withExtension: "jpg")!
}
