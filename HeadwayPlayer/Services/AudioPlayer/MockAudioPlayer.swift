//
//  MockAudioPlayer.swift
//  HeadwayPlayer
//
//  Created by Yevhen Pravda on 20.11.2024.
//

import Foundation

final class MockAudioPlayer: AudioPlayerProtocol {
    private(set) var isPlaying: Bool = false
    private var currentTime: Double = 0.0
    private var playbackSpeed: Float = 1.0
    private var duration: Double = 60.0
    private var errors: [Error] = []
    private var errorContinuation: AsyncStream<Error>.Continuation?
    
    func load(url: URL) {
        currentTime = 0.0
        isPlaying = true
    }
    
    func play() {
        isPlaying = true
    }
    
    func pause() {
        isPlaying = false
    }
    
    func seek(to value: Double) {
        currentTime = min(max(value, 0), duration)
    }
    
    func jump(by seconds: Double) {
        seek(to: currentTime + seconds)
    }
    
    func update(playbackSpeed: Float) {
        self.playbackSpeed = playbackSpeed
    }
    
    func itemDuration() async throws -> Double {
        return duration
    }
    
    func itemCurrentTime() -> Double {
        return currentTime
    }
    
    func subscribeToErrors() -> AsyncStream<Error> {
        AsyncStream { continuation in
            self.errorContinuation = continuation
            continuation.onTermination = { [weak self] _ in
                self?.errorContinuation = nil
            }
        }
    }
}

extension MockAudioPlayer {
    func simulateError(_ error: Error) {
        errors.append(error)
        errorContinuation?.yield(error)
    }
    
    func setDuration(_ duration: Double) {
        self.duration = duration
    }
}
