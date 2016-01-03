//
//  mimetype.swift
//  unchained
//
//  Created by Johannes Schriewer on 14/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import Darwin

public class MimeType {
    public class func fromFile(filename: String) -> String? {
        var s = stat()
        if stat(filename, &s) != 0 {
            return nil
        }

        // determine content type from file
        var buffer = [CChar](count: 256, repeatedValue: 0)
        let fp = popen("file --mime-type -b '\(filename)'", "r")
        fread(&buffer, 1, 255, fp)
        fclose(fp)
        guard strnlen(buffer, 255) > 0 else {
            return "application/octet-stream"
        }
        buffer[(strnlen(buffer, 255) - 1)] = 0
        if let ct = String.fromCString(buffer) {
            return ct
        } else {
            return "application/octet-stream"
        }
    }
}