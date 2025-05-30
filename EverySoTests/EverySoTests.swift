//
//  EverySoTests.swift
//  EverySoTests
//
//  Created by Jeremy Kim on 2/20/25.
//

import Testing
@testable import EverySo

struct EverySoTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

    @Test
    func testCountdownInitialization() async throws {
        let entry = CountdownEntry(title: "Beer Time", description: "Monthly reward", intervalDays: <#T##Int#>: 30, intervalHours: <#T##Int#>: 0, intervalMinutes: <#T##Int#>: 0)
        #expect(entry.title == "Beer Time")
        #expect(entry.description == "Monthly reward")
        #expect(entry.totalDuration == 30 * 24 * 60 * 60)
    }

    @Test
    func testCountdownReset() async throws {
        var entry = CountdownEntry(title: "Reset Test", description: "", durationDays: 0, durationHours: 1, durationMinutes: 0)
        let originalStart = entry.startTime
        try await Task.sleep(nanoseconds: 1_000_000_000) // Wait 1 second
        entry.reset()
        #expect(entry.startTime > originalStart)
    }

    @Test
    func testTimeRemainingCalculation() async throws {
        let entry = CountdownEntry(title: "Test", description: "", durationDays: 0, durationHours: 0, durationMinutes: 1)
        #expect(entry.timeRemaining <= 60)
        #expect(entry.timeRemaining > 0)
    }

    @Test
    func testZeroDurationIsInvalid() async throws {
        let entry = CountdownEntry(title: "Zero Test", description: "", durationDays: 0, durationHours: 0, durationMinutes: 0)
        #expect(entry.totalDuration == 0)
        #expect(entry.isValid == false)
    }

}
