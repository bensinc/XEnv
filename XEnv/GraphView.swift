//
//  GraphView.swift
//  XEnv
//
//  Created by Ben Sinclair on 2/12/19.
//  Copyright © 2019 Ben Sinclair. All rights reserved.
//

import Cocoa

class GraphView: NSView {
    
    var percent:Float = 0.0

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        NSColor.red.setFill()
        __NSRectFill(NSRect(x: 0, y: 0, width: Int(self.frame.size.width), height: 5))
        
        NSColor.init(red: 0, green: 0, blue: 0, alpha: 0.8).setFill()
        __NSRectFill(NSRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        
        NSColor.init(red: 50/255.0, green: 132/255.0, blue: 255/255.0, alpha: 0.8).setFill()
        let height = self.frame.size.height * CGFloat(percent)
        
        __NSRectFill(NSRect(x: 0, y: 0, width: self.frame.size.width, height: height))

        self.layer?.cornerRadius = 1

        
    }
    
}
