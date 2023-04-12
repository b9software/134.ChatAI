//
//  OAEntityTests.swift
//  UnitTests
//
//  Created by Joseph Zhao on 2023/4/10.
//  Copyright © 2023 B9Software. All rights reserved.
//

@testable import B9ChatAI
import XCTest

class OAEntityTests: TestCase {
    func testRoleDecode() throws {
        let json = #"{"role":"bad","content":"test"}"#
        let jsonData = json.data(using: .utf8)!

        let item = try OAChatMessage.decode(jsonData)
        assertEqual(item.role?.isUnknown, true)
        assertEqual(item.content, "test")
    }

    func testEngineConfigEncoding() throws {
        var sut = EngineConfig(model: "test")
        // Test lower
        sut.temperature = 0
        sut.topP = 0
        sut.presenceP = 0
        sut.frequencyP = 0
        assertEqual(try sut.toOpenAIParameters() as NSDictionary, [
            "model": "test",
            "frequency_penalty": -2,
            "presence_penalty": -2,
            "temperature": 0,
            "top_p": 0,
        ] as NSDictionary)

        // Test upper
        sut.temperature = 1
        sut.topP = 1
        sut.presenceP = 1
        sut.frequencyP = 1
        assertEqual(try sut.toOpenAIParameters() as NSDictionary, [
            "model": "test",
            "frequency_penalty": 2,
            "presence_penalty": 2,
            "temperature": 2,
        ] as NSDictionary)

        // Test default
        sut.temperature = 0.5
        sut.topP = 1
        sut.presenceP = 0.5
        sut.frequencyP = 0.5
        assertEqual(try sut.toOpenAIParameters() as NSDictionary, [
            "model": "test",
        ] as NSDictionary)
    }

//    func testStreamEncode() {
//        var param: [String: Encodable] = [
//            "model": "test-model"
//        ]
//        var messages: [OAChatMessage] = [
//            .init(role: .user, content: "foo"),
//            .init(role: .assistant, content: "bar"),
//        ]
//        param["messages"] = messages
//
//    }
}
