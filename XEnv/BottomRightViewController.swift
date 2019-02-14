//
//  ViewController.swift
//  SpaceSwitcher
//
//  Created by Ben Sinclair on 2/10/19.
//  Copyright © 2019 Ben Sinclair. All rights reserved.
//

import Cocoa
import AwesomeEnum

class BottomRightViewController: NSViewController {
    
    @IBOutlet weak var testImageButton: NSButton!
    
    var itemPaths: Array<String> = []
    var buttons: Array<NSButton> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let home = FileManager.default.homeDirectoryForCurrentUser
        
        let rcUrl = home.appendingPathComponent(".benlaunchrc")
        
        do {
            let files = try String(contentsOf: rcUrl, encoding: .utf8).components(separatedBy: .newlines)
            
            for path in files {
                if (!path.hasPrefix("#") && path.count > 1) {
                    itemPaths.append(path)
                }
            }
            
        }
        catch {
            print("Error opening ~/benlaunchrc")
        }
        
        // Do any additional setup after loading the view.
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
        
        let sleepButton = NSButton(image: Awesome.Solid.powerOff.asImage(size: 24.0, color: .white), target: self, action: #selector(buttonPressed))
        sleepButton.isBordered = false
        sleepButton.tag = 1
        sleepButton.frame = CGRect(x: 0, y: 10, width: 24, height: 24)
        buttons.append(sleepButton)
        
        let restartButton = NSButton(image: Awesome.Solid.expand.asImage(size: 24.0, color: .white), target: self, action: #selector(buttonPressed))
        restartButton.isBordered = false
        restartButton.tag = 0
        restartButton.frame = CGRect(x: 0, y: 10, width: 24, height: 24)
        buttons.append(restartButton)
      

        
        let horizontalButton = NSButton(image: Awesome.Solid.pollH.asImage(size: 24.0, color: .white), target: self, action: #selector(buttonPressed))
        horizontalButton.isBordered = false
        horizontalButton.tag = 2
        horizontalButton.frame = CGRect(x: 0, y: 10, width: 24, height: 24)
        buttons.append(horizontalButton)
        
        let verticalButton = NSButton(image: Awesome.Solid.poll.asImage(size: 24.0, color: .white), target: self, action: #selector(buttonPressed))
        verticalButton.isBordered = false
        verticalButton.tag = 3
        verticalButton.frame = CGRect(x: 0, y: 10, width: 24, height: 24)
        buttons.append(verticalButton)
        
        let rotateButton = NSButton(image: Awesome.Solid.redo.asImage(size: 24.0, color: .white), target: self, action: #selector(buttonPressed))
        rotateButton.isBordered = false
        rotateButton.tag = 4
        rotateButton.frame = CGRect(x: 0, y: 10, width: 24, height: 24)
        buttons.append(rotateButton)
        
        let floatButton = NSButton(image: Awesome.Solid.windowRestore.asImage(size: 24.0, color: .white), target: self, action: #selector(buttonPressed))
        floatButton.isBordered = false
        floatButton.tag = 5
        floatButton.frame = CGRect(x: 0, y: 10, width: 24, height: 24)
        buttons.append(floatButton)
        
        let bspButton = NSButton(image: Awesome.Solid.table.asImage(size: 24.0, color: .white), target: self, action: #selector(buttonPressed))
        bspButton.isBordered = false
        bspButton.tag = 6
        bspButton.frame = CGRect(x: 0, y: 10, width: 24, height: 24)
        buttons.append(bspButton)
        
        let spacing = 10

        
        
        var x = 0 + spacing
        for button in buttons {
            button.frame = CGRect(x: x, y: 10, width: 24, height: 24)
            self.view.addSubview(button)
            x += Int(button.frame.width) + spacing
        }
        
        DispatchQueue.main.async { [unowned self] in                         
            let width = self.buttons.count * 24 + self.buttons.count * spacing + spacing
            self.view.window?.setFrame(CGRect(x: Int(NSScreen.main!.frame.width) - width - 20, y: 15, width: width, height: 24 + 20), display: true)
        }
        
        Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.updateLayoutButtons), userInfo: nil, repeats: true)
        updateLayoutButtons()
        
        Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.updateModeButtons), userInfo: nil, repeats: true)
        updateModeButtons()
        
        
    }
    
    @objc func buttonPressed(_sender: NSButton) {
        
        switch _sender.tag {
        case 0:
            let task = Process()
            task.launchPath = "/usr/local/bin/brew"
            task.arguments = ["services", "restart", "chunkwm"]
            task.launch()
            break
        case 1:
            let task = Process()
            task.launchPath = "/usr/bin/pmset"
            task.arguments = ["sleepnow"]
            task.launch()
            break
        case 2:
            _sender.image = Awesome.Solid.pollH.asImage(size: 24.0, color: .init(red: 50/255.0, green: 132/255.0, blue: 255/255.0, alpha: 1.0))
            buttons[3].image = Awesome.Solid.poll.asImage(size: 24.0, color: .white)
            let task = Process()
            task.launchPath = "/usr/local/bin/chunkc"
            task.arguments = ["set", "bsp_split_mode", "horizontal"]
            task.launch()
            break
        case 3:
            _sender.image = Awesome.Solid.poll.asImage(size: 24.0, color: .init(red: 50/255.0, green: 132/255.0, blue: 255/255.0, alpha: 1.0))
            buttons[2].image = Awesome.Solid.pollH.asImage(size: 24.0, color: .white)
            let task = Process()
            task.launchPath = "/usr/local/bin/chunkc"
            task.arguments = ["set", "bsp_split_mode", "vertical"]
            task.launch()
            break
        case 4:
            let task = Process()
            task.launchPath = "/usr/local/bin/chunkc"
            task.arguments = ["tiling::desktop", "--rotate", "90"]
            task.launch()
            break
        case 5:
            let task = Process()
            task.launchPath = "/usr/local/bin/chunkc"
            task.arguments = ["tiling::desktop", "--layout", "float"]
            task.launch()
            buttons[5].image = Awesome.Solid.windowRestore.asImage(size: 24.0, color: .init(red: 50/255.0, green: 132/255.0, blue: 255/255.0, alpha: 1.0))
            buttons[6].image = Awesome.Solid.table.asImage(size: 24.0, color: .white)
            break
        case 6:
            let task = Process()
            task.launchPath = "/usr/local/bin/chunkc"
            task.arguments = ["tiling::desktop", "--layout", "bsp"]
            task.launch()
            buttons[5].image = Awesome.Solid.windowRestore.asImage(size: 24.0, color: .white)
            buttons[6].image = Awesome.Solid.table.asImage(size: 24.0, color: .init(red: 50/255.0, green: 132/255.0, blue: 255/255.0, alpha: 1.0))
            break
        default:
            print("Bye!")
            
        }
    }
    
    @objc func updateLayoutButtons() {
        let task = Process()
        
        task.launchPath = "/usr/local/bin/chunkc"
        task.arguments = ["get", "bsp_split_mode"]
        
        let outpipe = Pipe()
        task.standardOutput = outpipe
        
        task.launch()

        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            let output = string.components(separatedBy: "\n")
            if (output.first == "horizontal") {
                buttons[2].image = Awesome.Solid.pollH.asImage(size: 24.0, color: .init(red: 50/255.0, green: 132/255.0, blue: 255/255.0, alpha: 1.0))
                buttons[3].image = Awesome.Solid.poll.asImage(size: 24.0, color: .white)

            } else {
                buttons[2].image = Awesome.Solid.pollH.asImage(size: 24.0, color: .white)
                buttons[3].image = Awesome.Solid.poll.asImage(size: 24.0, color: .init(red: 50/255.0, green: 132/255.0, blue: 255/255.0, alpha: 1.0))

            }
        }
        
    }
   
    @objc func updateModeButtons() {
        let task = Process()
        
        task.launchPath = "/usr/local/bin/chunkc"
        task.arguments = ["tiling::query", "--desktop", "mode"]
        
        let outpipe = Pipe()
        task.standardOutput = outpipe
        
        task.launch()
        
        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            let output = string.components(separatedBy: "\n")
            if (output.first == "float") {
                buttons[5].image = Awesome.Solid.windowRestore.asImage(size: 24.0, color: .init(red: 50/255.0, green: 132/255.0, blue: 255/255.0, alpha: 1.0))
                buttons[6].image = Awesome.Solid.table.asImage(size: 24.0, color: .white)
                
            } else {
                buttons[5].image = Awesome.Solid.windowRestore.asImage(size: 24.0, color: .white)
                buttons[6].image = Awesome.Solid.table.asImage(size: 24.0, color: .init(red: 50/255.0, green: 132/255.0, blue: 255/255.0, alpha: 1.0))
                
            }
        }
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

