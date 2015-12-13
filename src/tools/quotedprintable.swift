//
//  quotedprintable.swift
//  unchained
//
//  Created by Johannes Schriewer on 13/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import twohundred

/// Quoted printable encoder and decoder
public class QuotedPrintable {
    
    /// Encode a string in quoted printable encoding
    ///
    /// - parameter string: String to encode
    /// - returns: quoted printable encoded string
    public class func encode(string: String) -> String {
        var gen = string.utf8.generate()
        var charCount = 0
        
        var result = ""
        result.reserveCapacity(string.characters.count)
        
        while let c = gen.next() {
            switch c {
            case 32...60, 62...126:
                charCount++
                result.append(UnicodeScalar(c))
            case 13:
                continue
            case 10:
                if result.characters.last == " " || result.characters.last == "\t" {
                    result.appendContentsOf("=\r\n")
                    charCount = 0
                } else {
                    result.appendContentsOf("\r\n")
                    charCount = 0
                }
            default:
                if charCount > 72 {
                    result.appendContentsOf("=\r\n")
                    charCount = 0
                }
                result.append(UnicodeScalar(61))
                result.appendContentsOf(c.hexString().uppercaseString)
                charCount+=3
            }
            
            if charCount == 75 {
                charCount = 0
                result.appendContentsOf("=\r\n")
            }
        }
        
        return result
    }
    
    /// Decode a quoted printable encoded string
    ///
    /// - parameter string: String to decode
    /// - returns: Decoded string
    public class func decode(string: String) -> String {
        var state = QuotedPrintableState.Text
        var gen = string.utf8.generate()
        
        // reserve space
        var decodedString = ""
        decodedString.reserveCapacity(string.characters.count)
        
        // main parse loop
        while let c = gen.next() {
            var result:(c: UnicodeScalar?, state: QuotedPrintableState) = (c: nil, state: state)

            switch state {
            case .Text:
                result = self.parseText(c)
            case .Equals:
                result = self.parseEquals(c)
            case .EqualsSecondDigit:
                result = self.parseEqualsSecondDigit(c, state: state)
            }
            
            state = result.state
            if let cOut = result.c {
                decodedString.append(cOut)
            }
        }
        
        return decodedString
    }
    
    // MARK: - State machine parser for quoted printable
    
    private enum QuotedPrintableState {
        case Text
        case Equals
        case EqualsSecondDigit(firstDigit: UInt8)
    }
    
    private class func parseText(c: UInt8) -> (c: UnicodeScalar?, state: QuotedPrintableState) {
        switch c {
        case 61:
            return (c: nil, state: .Equals)
        default:
            return (c: UnicodeScalar(c), state: .Text)
        }
    }
    
    private class func parseEquals(c: UInt8) -> (c: UnicodeScalar?, state: QuotedPrintableState) {
        switch c {
        case 13:
            return (c: nil, state: .Equals)
        case 10:
            return (c: nil, state: .Text)
        case 48...57, 65...70, 97...102:
            return (c: nil, state: .EqualsSecondDigit(firstDigit: c))
        default:
            return (c: UnicodeScalar(c), state: .Text)
        }
    }

    private class func parseEqualsSecondDigit(c: UInt8, state: QuotedPrintableState) -> (c: UnicodeScalar?, state: QuotedPrintableState) {
        switch c {
        case 48...57, 65...70, 97...102:
            if case .EqualsSecondDigit(let c0) = state {
                var result: UInt8 = 0
                if c0 <= 57 {
                    result = (c0 - 48) << 4
                } else if c0 <= 70 {
                    result = (c0 - 65 + 10) << 4
                } else {
                    result = (c0 - 97 + 10) << 4
                }
                
                if c <= 57 {
                    result += c - 48
                } else if c <= 70 {
                    result += c - 65 + 10
                } else {
                    result += c - 97 + 10
                }
                
                return (c: UnicodeScalar(result), state: .Text)
            }
            return (c: nil, state: .Text)
        default:
            return (c: UnicodeScalar(c), state: .Text)
        }
    }
}