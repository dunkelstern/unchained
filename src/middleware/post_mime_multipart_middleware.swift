//
//  post_mime_multipart_middleware.swift
//  unchained
//
//  Created by Johannes Schriewer on 10/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import twohundred

/// URL Decoding POST data middleware
public class MultipartPostMiddleware: UnchainedMiddleware {
    public init() {}
    
    public func request(request: HTTPRequest, config: UnchainedConfig) -> (request: HTTPRequest?, response: HTTPResponse?)? {
        guard let contentType = request.header["content-type"] where contentType.hasPrefix("multipart/form-data"),
              let data = request.data where data.count > 0 else {
                return nil // not our case
        }
        var tmp:String? = nil
        var modifiedRequest = request
        
        // get boundary
        let components = contentType.componentsSeparatedByString(";")
        for component in components {
            let parts = component.componentsSeparatedByString("=")
            if parts[0].stringByTrimmingWhitespace() == "boundary" {
                tmp = "--" + parts[1].stringByTrimmingWhitespace() + "\r\n"
                break
            }
        }
        guard let boundary = tmp else {
            return nil
        }

        // split by boundary
        let lastChar = boundary.utf8[boundary.utf8.startIndex.advancedBy(boundary.utf8.count - 1)]
        let boundaryLength = boundary.utf8.count
        var splits = [Int]()
        for i in 0..<(data.count - boundaryLength - 2) {
            
            // quick check if boundary possible
            if data[i] == 45 && data[i + 1] == 45 && data[i + boundaryLength - 1] == lastChar {
                // thorough check
                var ok = true
                var idx = boundary.utf8.startIndex
                for j in i..<(i + boundaryLength) {
                    if data[j] != boundary.utf8[idx] {
                        ok = false
                        break
                    }
                    idx = idx.advancedBy(1)
                }
                
                if (ok) {
                    // append split point (first byte after boundary)
                    splits.append(i + boundaryLength)
                }
            }
        }
        
        // set post data
        if modifiedRequest.postData == nil {
            modifiedRequest.postData = [String:String]()
        }
        if modifiedRequest.files == nil {
            modifiedRequest.files = [String:[UInt8]]()
        }
        
        // parse parts
        for (idx, split) in splits.enumerate() {
            var length = 0
            if idx < splits.count - 1 {
                length = splits[idx + 1] - split - boundaryLength
            } else {
                length = (data.count - boundaryLength - 2) - split
            }
            
            let part = data[split..<(split + length - 2)]
            if let result = self.parsePart(part) {
                if let value = result.value {
                    modifiedRequest.postData![result.name] = value
                }
                if let data = result.data {
                    modifiedRequest.files![result.name] = data
                }
            }
        }
        
        return (request: modifiedRequest, response: nil)
    }
    
    // FIXME: return mime type for data too
    private func parsePart(data: ArraySlice<UInt8>) -> (name: String, value: String?, data: [UInt8]?)? {
        var gen = data.generate()
        var headers = [UInt8]()
        
        // find double CR LF
        let search:[UInt8] = [13, 10, 13, 10]
        var idx = 0
        while let c = gen.next() {
            headers.append(c)
            if c == search[idx] {
                idx++
            } else {
                idx = 0
            }
            if idx == 4 {
                break
            }
        }
        headers.append(0)
        
        // parse headers
        guard let headerString = String(CString: UnsafePointer<CChar>(headers), encoding: NSUTF8StringEncoding)  else {
            return nil
        }
        let result = self.parseHeaders(headerString)
        
        // interpret headers
        var isFormData: Bool = false
        var outData = [UInt8]()
        var name:String? = nil
        for header in result {
            switch header.name {
            case "content-disposition":
                print (header.name, header.value)
                let parts = header.value.componentsSeparatedByString(";")
                for part in parts {
                    let tmp = part.lowercaseString.stringByTrimmingWhitespace()
                    if tmp == "form-data" {
                        isFormData = true
                    } else if tmp.hasPrefix("name") {
                        let subparts = part.componentsSeparatedByString("=")
                        if subparts.count == 2 {
                            name = subparts[1]
                            if name!.hasPrefix("\"") {
                                if name!.hasSuffix("\"") {
                                    name = name!.substringWithRange(name!.startIndex.advancedBy(1)..<name!.startIndex.advancedBy(name!.characters.count - 1))
                                }
                            }
                        }
                    }
                }
            case "content-type":
                print (header.name, header.value)
            case "content-transfer-encoding":
                print (header.name, header.value)
                switch header.value {
                case "7bit", "8bit", "binary":
                    continue // plain appending is done at the end
                case "quoted-printable":
                    // decode quoted printable
                    outData.appendContentsOf(self.decodeQuotedPrintable(gen))
                case "base64":
                    // decode base 64
                    outData.appendContentsOf(self.decodeBase64(gen))
                default:
                    print("Unknown encoding: \(header.value)")
                }
            default:
                continue // just ignore for now
            }
        }
        
        // if nothing has been appended by now just dump the data
        if outData.count == 0 {
            while let c = gen.next() {
                outData.append(c)
            }
        }
    
        if let name = name where isFormData == true {
            outData.append(0) // zero terminate outData
            if let value = String(CString: UnsafePointer<CChar>(outData), encoding: NSUTF8StringEncoding) {
                return (name: name, value: value, data: nil)
            }
        }
        return nil
    }

    // MARK: - Decoders
    
    private func decodeQuotedPrintable(generator: IndexingGenerator<ArraySlice<UInt8>>) -> [UInt8] {
        // TODO: decode quoted printable
        return []
    }

    private func decodeBase64(generator: IndexingGenerator<ArraySlice<UInt8>>) -> [UInt8] {
        // TODO: decode base64
        return []
    }


    // MARK: - Parser

    private enum HeaderParserStates {
        case Name
        case BeforeValue
        case Value
        case ErrorState
    }
    
    private var state: HeaderParserStates = .Name
    private func parseHeaders(data: String) -> [(name: String, value: String)] {
        var headers = [(name: String, value: String)]()
        
        var generator: String.CharacterView.Generator
        if !data.hasSuffix("\r\n") {
            generator = "\(data)\r\n".characters.generate()
        } else {
            generator = data.characters.generate()
        }
        
        self.state = .Name
        
        var currentName: String?
        while true {
            guard let c = generator.next() else {
                break
            }
            switch self.state {
            case .Name:
                if let name = self.parseName(c) {
                    currentName = name
                }
            case .BeforeValue:
                self.parseBeforeValue(c)
            case .Value:
                guard let value = self.parseValue(c),
                    let name = currentName else {
                        continue
                }
                headers.append((name: name.lowercaseString, value: value))
                currentName = nil
            case .ErrorState:
                self.parseErrorState(c)
            }
        }
        
        return headers
    }
    
    // MARK: HTTP Headers
    
    var nameTemp: String = ""
    private func parseName(c: Character) -> String? {
        switch c {
        case "A"..."Z", "a"..."z", "0"..."9", "-", "_":
            self.nameTemp.append(c)
        case ":":
            self.state = .BeforeValue
            let result = self.nameTemp
            self.nameTemp = ""
            return result
        default:
            self.nameTemp = ""
            self.state = .ErrorState
        }
        return nil
    }
    
    private func parseBeforeValue(c: Character) {
        switch c {
        case " ", "\t":
            break
        default:
            valueTemp.append(c)
            self.state = .Value
        }
    }
    
    var valueTemp: String = ""
    private func parseValue(c: Character) -> String? {
        switch c {
        case "\r\n", "\n":
            self.state = .Name
            let result = self.valueTemp
            self.valueTemp = ""
            return result
        default:
            self.valueTemp.append(c)
        }
        return nil
    }
    
    private func parseErrorState(c: Character) {
        switch c {
        case "\r\n", "\n":
            self.state = .Name
        default:
            break
        }
    }

}