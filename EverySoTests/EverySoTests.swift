//
//  EverySoTests.swift
//  EverySoTests
//
//  Created by Jeremy Kim on 2/20/25.
//

import Testing
import SwiftUI
import SwiftData
@testable import EverySo

struct EverySoTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

    @Test func testTimeRemainingFutureEvent() {
        let now = Date()
        let futureDate = now.addingTimeInterval(3600) // 1 hour later
        let entry = CountdownEntry(date: now, targetDate: futureDate, title: "Test Event", id: UUID())
        let remaining = entry.timeRemaining(from: now)
        #expect(remaining).toBeClose(to: 3600, within: 1)
    }

    @Test func testFormattedTimeRemaining() {
        let now = Date()
        let futureDate = now.addingTimeInterval(3661) // 1 hour, 1 minute, 1 second later
        let entry = CountdownEntry(date: now, targetDate: futureDate, title: "Test Event", id: UUID())
        let formatted = entry.formattedTimeRemaining(from: now)
        #expect(formatted).toEqual("1h 1m 1s")
    }

    @Test func testProgressFraction() {
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(100)
        let entry = CountdownEntry(date: startDate, targetDate: endDate, title: "Test Event", id: UUID())
        let halfwayDate = startDate.addingTimeInterval(50)
        let progress = entry.progress(from: halfwayDate)
        #expect(progress).toBeClose(to: 0.5, within: 0.01)
    }
}
