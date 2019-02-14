//
//  ViewController.swift
//  XEnv
//
//  Created by Ben Sinclair on 2/10/19.
//  Copyright © 2019 Ben Sinclair. All rights reserved.
//

import Cocoa
import AMCoreAudio
import AwesomeEnum
import Foundation
import IOKit.ps
import CoreWLAN

class LeftStatusViewViewController: NSViewController {
    
   
    
    // Font Awesome Images
    
    var appleIcon: NSImage!
    var appleButton: NSButton!
    
    var windowNameButton: NSButton!
    
   
    var components: Array<NSView> = []
    
    var graphs: Array<GraphView> = []
    
    var cpuUsage = MyCpuUsage()
    
    var baseWidth = 0
    
    let barHeight = 25

    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Show launcher window
        let launcherWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Launcher Controller")) as! NSWindowController
        launcherWindowController.showWindow(self)
        
   
        
    }
    
    override func viewWillAppear() {
        
        
      
        
        self.view.window!.backgroundColor             =   NSColor.clear
        self.view.window!.isOpaque                      =   false
        //        self.view.window!.styleMask                   =   NSWindow.StyleMask(rawValue: NSBorderlessWindowMask.rawValue | NSResizableWindowMask.rawValue)
        self.view.window!.isMovableByWindowBackground   =   true
        self.view.window!.makeKeyAndOrderFront(self)
        
        self.view.wantsLayer                =   true
        self.view.layer!.cornerRadius       =   5
        self.view.layer!.backgroundColor    =   NSColor.init(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        
        /// :ref:   http://stackoverflow.com/questions/19940019/nswindow-with-round-corners-and-shadow/27613308#21247949
        self.view.window!.invalidateShadow()  //  This manual invalidation is REQUIRED because shadow generation is an expensive operation.
        
        
        
        var componentWidth = 0
        
        
        
        AwesomePro.loadFonts(from: Bundle.main)
        
        appleIcon = Awesome.Brand.apple.asImage(size: 22.0, color: .init(red: 255.0, green: 255.0, blue: 255.0, alpha: 0.8))
        
        
        appleButton = NSButton(image:appleIcon, target: self, action: #selector(applePressed))
        appleButton.alignment = .left
        
        appleButton.frame = CGRect(x: componentWidth, y: 5, width: 16, height: 16)
        appleButton.isBordered = false
        
        
        for _ in 0 ..< cpuUsage.numCPUs {
            let graph = GraphView()
            graph.frame = CGRect(x: 0, y: 0, width: 6, height: 16)
            graphs.append(graph)
        }
        
        
        windowNameButton = NSButton(title: "test", target: self, action: #selector(applePressed))
        windowNameButton.alignment = .left
        
        windowNameButton.frame = CGRect(x: componentWidth, y: 5, width: 100, height: 16)
        windowNameButton.isBordered = false
        windowNameButton.sizeToFit()
        windowNameButton.tag = 100
        
        
        
        components = [appleButton]
        
        for graph in graphs {
            components.append(graph)
        }
        
//        components.append(windowNameButton)
        
        //        self.view.addSubview(batteryLabel)
        
        
        
        let componentSpacing = 10
        componentWidth = componentSpacing
        for c in components {
            
            let cWidth = c.frame.size.width
            
            var offset = 0
            
            if (c.className == "NSTextField") {
                offset = -3
            }
            
            var height = barHeight
            
            if (c.className == "XEnv.GraphView") {
                height = 13
                offset = 6
            }
            
            var x = componentWidth
            if (c.tag == 100) {
                baseWidth = componentWidth
                x = x + 10
            }
            c.frame = CGRect(origin: CGPoint(x: x, y: 0 + offset), size: CGSize(width: cWidth, height: CGFloat(height)))
            
            self.view.addSubview(c)
            if (c.className == "XEnv.GraphView") {
                componentWidth += Int(cWidth) + 2
            } else {
                componentWidth += Int(cWidth) + componentSpacing
            }
        }
        
        componentWidth += componentSpacing
        
        
        
        DispatchQueue.main.async { [unowned self] in
            let width = componentWidth
            
            self.view.window?.setFrame(CGRect(x: 20, y: Int(NSScreen.main!.frame.height) - (self.barHeight + 6), width: width, height: self.barHeight), display: true)
        }
        
        // Setup updaters
        
 
        
        Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.updateActivity), userInfo: nil, repeats: true)
        updateActivity();
        
     
//        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.updateTitle), userInfo: nil, repeats: true)
//        updateTitle()
        
    
        
        
    }
    
    @objc func updateActivity() {
        var i = 0
        for percent in cpuUsage.cpuPercents {
            graphs[i].percent = cpuUsage.cpuPercents[i]
//            graphs[i].percent = 1.0
            graphs[i].needsDisplay = true
            i += 1
        }
        
        
        
        
        
        
    }
    
    
    @objc func updateTitle() {
        
        var windowName = ""
        var title = ""
        
        let task = Process()
        
        task.launchPath = "/usr/local/bin/chunkc"
        task.arguments = ["tiling::query", "--window", "name"]
        
        let outpipe = Pipe()
        task.standardOutput = outpipe
        
        task.launch()
        
        
        var outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            let output = string.components(separatedBy: "\n")
            title = output.first ?? ""
        }
        
        
        
        let task2 = Process()
        
        task2.launchPath = "/usr/local/bin/chunkc"
        task2.arguments = ["tiling::query", "--window", "owner"]
        
        let outpipe2 = Pipe()
        task2.standardOutput = outpipe2
        
        task2.launch()
        
        let outdata2 = outpipe2.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata2, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            let output = string.components(separatedBy: "\n")
            windowName = output.first ?? ""
        }
        
        windowNameButton.title = "\(windowName) - \(title)"
        windowNameButton.sizeToFit()
        
//        DispatchQueue.main.async { [unowned self] in
        
            self.view.window?.setFrame(CGRect(x: 20, y: Int(NSScreen.main!.frame.height) - (self.barHeight + 6), width: self.baseWidth + 20 + Int(self.windowNameButton.frame.size.width), height: self.barHeight), display: true)
//        }
        
    }
    
    
    
    
    
    @objc func applePressed(_sender: Any?) {
        NSWorkspace.shared.launchApplication("Activity Monitor")
    }
    
    override func viewDidAppear() {
        self.view.window!.backgroundColor = NSColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
       
        
    }
    
    
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
   
    
    
}

