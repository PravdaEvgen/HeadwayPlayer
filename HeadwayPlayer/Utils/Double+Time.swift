//
//  Double+Time.swift
//  HeadwayPlayer
//
//  Created by Yevhen Pravda on 19.11.2024.
//

extension Double {
    /// Convert seconds to format mm:ss
    func formatTime() -> String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
