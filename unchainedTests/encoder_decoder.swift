//
//  encoder_decoder.swift
//  unchained
//
//  Created by Johannes Schriewer on 13/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import XCTest
@testable import unchained

class codecTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBase64Encode() {
        var b64 = Base64.encode("Hello World!")
        XCTAssert(b64 == "SGVsbG8gV29ybGQh")
        
        b64 = Base64.encode("Hello World")
        XCTAssert(b64 == "SGVsbG8gV29ybGQ=")
        
        b64 = Base64.encode("Hello You!")
        XCTAssert(b64 == "SGVsbG8gWW91IQ==")
        
        b64 = Base64.encode("Nullam id dolor id nibh ultricies vehicula ut id elit. Donec id elit non mi porta gravida at eget metus. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras justo odio, dapibus ac facilisis in, egestas eget quam.", linebreak: 76)
        XCTAssert(b64 == "TnVsbGFtIGlkIGRvbG9yIGlkIG5pYmggdWx0cmljaWVzIHZlaGljdWxhIHV0IGlkIGVsaXQuIERv\r\nbmVjIGlkIGVsaXQgbm9uIG1pIHBvcnRhIGdyYXZpZGEgYXQgZWdldCBtZXR1cy4gTG9yZW0gaXBz\r\ndW0gZG9sb3Igc2l0IGFtZXQsIGNvbnNlY3RldHVyIGFkaXBpc2NpbmcgZWxpdC4gQ3JhcyBqdXN0\r\nbyBvZGlvLCBkYXBpYnVzIGFjIGZhY2lsaXNpcyBpbiwgZWdlc3RhcyBlZ2V0IHF1YW0u")
    }
    
    func testBase64Decode() {
        var result = Base64.decode("SGVsbG8gV29ybGQh")
        result.append(0)
        var string = String(CString: UnsafePointer<CChar>(result), encoding: NSUTF8StringEncoding)
        XCTAssert(string == "Hello World!")
        
        result = Base64.decode("SGVsbG8gV29ybGQ=")
        result.append(0)
        string = String(CString: UnsafePointer<CChar>(result), encoding: NSUTF8StringEncoding)
        XCTAssert(string == "Hello World")

        result = Base64.decode("SGVsbG8gWW91IQ==")
        result.append(0)
        string = String(CString: UnsafePointer<CChar>(result), encoding: NSUTF8StringEncoding)
        XCTAssert(string == "Hello You!")

        result = Base64.decode("TnVsbGFtIGlkIGRvbG9yIGlkIG5pYmggdWx0cmljaWVzIHZlaGljdWxhIHV0IGlkIGVsaXQuIERv\r\nbmVjIGlkIGVsaXQgbm9uIG1pIHBvcnRhIGdyYXZpZGEgYXQgZWdldCBtZXR1cy4gTG9yZW0gaXBz\r\ndW0gZG9sb3Igc2l0IGFtZXQsIGNvbnNlY3RldHVyIGFkaXBpc2NpbmcgZWxpdC4gQ3JhcyBqdXN0\r\nbyBvZGlvLCBkYXBpYnVzIGFjIGZhY2lsaXNpcyBpbiwgZWdlc3RhcyBlZ2V0IHF1YW0u")
        result.append(0)
        string = String(CString: UnsafePointer<CChar>(result), encoding: NSUTF8StringEncoding)
        XCTAssert(string == "Nullam id dolor id nibh ultricies vehicula ut id elit. Donec id elit non mi porta gravida at eget metus. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras justo odio, dapibus ac facilisis in, egestas eget quam.")
    }
        
    func testQuotedPrintableEncode() {
        var encoded = QuotedPrintable.encode("Hello World")
        XCTAssert(encoded == "Hello World")
        
        encoded = QuotedPrintable.encode("e = m * c^2")
        XCTAssert(encoded == "e =3D m * c^2")
        
        encoded = QuotedPrintable.encode("Nullam id dolor id nibh ultricies vehicula ut id elit. Donec id elit non mi porta gravida at eget metus. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras justo odio, dapibus ac facilisis in, egestas eget quam.")
        XCTAssert(encoded == "Nullam id dolor id nibh ultricies vehicula ut id elit. Donec id elit non mi=\r\n porta gravida at eget metus. Lorem ipsum dolor sit amet, consectetur adipi=\r\nscing elit. Cras justo odio, dapibus ac facilisis in, egestas eget quam.")
    }

    func testQuotedPrintableDecode() {
        var decoded = QuotedPrintable.decode("Hello World")
        XCTAssert(decoded == "Hello World")
     
        decoded = QuotedPrintable.decode("e =3D m * c^2")
        XCTAssert(decoded == "e = m * c^2")
        
        decoded = QuotedPrintable.decode("Nullam id dolor id nibh ultricies vehicula ut id elit. Donec id elit non mi=\r\n porta gravida at eget metus. Lorem ipsum dolor sit amet, consectetur adipi=\r\nscing elit. Cras justo odio, dapibus ac facilisis in, egestas eget quam.")
        XCTAssert(decoded == "Nullam id dolor id nibh ultricies vehicula ut id elit. Donec id elit non mi porta gravida at eget metus. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras justo odio, dapibus ac facilisis in, egestas eget quam.")
    }
}
