//
//  NSImage+TintColor.swift
//  GitHubStatus
//
//  Created by Dylan Maryk on 25/04/2020.
//  Copyright © 2020 Dylan Maryk. All rights reserved.
//

import Cocoa

extension NSImage {
    
    func tinted(with color: NSColor?) -> NSImage {
        guard let color = color else {
            self.isTemplate = true
            return self
        }
        
        self.isTemplate = false
        
        let image = self.copy() as! NSImage
        image.lockFocus()
        
        color.set()
        
        let imageRect = NSRect(origin: .zero, size: image.size)
        imageRect.fill(using: .sourceIn)
        
        image.unlockFocus()
        
        return image
    }
    
}
