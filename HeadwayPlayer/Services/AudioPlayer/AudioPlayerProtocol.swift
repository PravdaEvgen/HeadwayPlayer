//
//  AudioPlayerProtocol.swift
//  HeadwayPlayer
//
//  Created by Yevhen Pravda on 19.11.2024.
//

import AVFoundation
import Dependencies

protocol AudioPlayerProtocol: AnyObject {
    var isPlaying: Bool { get }
    func load(url: URL)
    func play()
    func pause()
    func seek(to value: Double)
    func jump(by seconds: Double)
    func update(playbackSpeed: Float)
    func itemDuration() async throws -> Double
    func itemCurrentTime() -> Double
    func subscribeToErrors() -> AsyncStream<Error>
}

enum AudioPlayerKey: DependencyKey {
    static let liveValue: any AudioPlayerProtocol = AudioPlayer()
    static var testValue: any AudioPlayerProtocol = liveValue
}
