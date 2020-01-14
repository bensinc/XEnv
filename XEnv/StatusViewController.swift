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


extension NSButton {
    func setAttributes(foreground: NSColor? = nil, fontSize: CGFloat = -1.0, alignment: NSTextAlignment? = nil) {
        
        var attributes: [NSAttributedString.Key: Any] = [:]
        
        if let foreground = foreground {
            attributes[NSAttributedString.Key.foregroundColor] = foreground
        }
        
        if fontSize != -1 {
            attributes[NSAttributedString.Key.font] = NSFont.systemFont(ofSize: fontSize)
        }
        
        if let alignment = alignment {
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = alignment
            attributes[NSAttributedString.Key.paragraphStyle] = paragraph
        }
        
        let attributed = NSAttributedString(string: self.title, attributes: attributes)
        self.attributedTitle = attributed
    }
}


extension String {
    /*
     Truncates the string to the specified length number of characters and appends an optional trailing string if longer.
     - Parameter length: Desired maximum lengths of a string
     - Parameter trailing: A 'String' that will be appended after the truncation.
     
     - Returns: 'String' object.
     */
    func trunc(length: Int, trailing: String = "…") -> String {
        return (self.count > length) ? self.prefix(length) + trailing : self
    }
}




extension NSImage {
    func resized(to newSize: NSSize) -> NSImage? {
        if let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: Int(newSize.width), pixelsHigh: Int(newSize.height),
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
            ) {
            bitmapRep.size = newSize
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
            draw(in: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height), from: .zero, operation: .copy, fraction: 1.0)
            NSGraphicsContext.restoreGraphicsState()
            
            let resizedImage = NSImage(size: newSize)
            resizedImage.addRepresentation(bitmapRep)
            return resizedImage
        }
        
        return nil
    }
}


class StatusViewController: NSViewController, EventSubscriber {
    
    
    var clockLabel: NSTextField!
    var volumeButton: NSButton!
    var batteryLabel: NSButton!
    var wifiLabel: NSButton!
    
    var timer = Timer()
    
    
    // Images
    
    var wifiFullIcon: NSImage!
    var wifiOffIcon: NSImage!
    
    // Font Awesome Images
    
    var muteIcon: NSImage!
    var volumeHighIcon: NSImage!
    var volumeMediumIcon: NSImage!
    var volumeLowIcon: NSImage!
    
    
    var battery100Icon: NSImage!
    var battery25Icon: NSImage!
    var battery50Icon: NSImage!
    var battery75Icon: NSImage!
    var battery0Icon: NSImage!
   
    
    let formatter = DateFormatter()
    let dateFormatter = DateFormatter()

    
    var components: Array<NSView> = []
    
    enum BatteryError: Error { case error }

    
    override func viewDidLoad() {

        
        super.viewDidLoad()
        
        AwesomePro.loadFonts(from: Bundle.main)

        
        // Show launcher window
        let launcherWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Launcher Controller")) as! NSWindowController
//        launcherWindowController.showWindow(self)
        
        // Show left status window
        let leftStatusWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Left Status Controller")) as! NSWindowController
        leftStatusWindowController.showWindow(self)
        
        // show bottom right window
        
        let bottomRightWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Bottom Right Controller")) as! NSWindowController
        bottomRightWindowController.showWindow(self)
        
        formatter.dateFormat = "E h:mm a"
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        wifiFullIcon = Awesome.Solid.wifi.asImage(size: 16.0, color: .white)
        wifiOffIcon = Awesome.Solid.wifi.asImage(size: 16.0, color: .gray)
        
        
        muteIcon = Awesome.Solid.volumeMute.asImage(size: CGSize(width: 16, height: 16), color: .white, backgroundColor: .clear)
        volumeLowIcon = Awesome.Solid.volumeOff.asImage(size: CGSize(width: 16, height: 16), color: .white, backgroundColor: .clear)
        volumeMediumIcon = Awesome.Solid.volumeDown.asImage(size: CGSize(width: 16, height: 16), color: .white, backgroundColor: .clear)
        volumeHighIcon = Awesome.Solid.volumeUp.asImage(size: CGSize(width: 16, height: 16), color: .white, backgroundColor: .clear)
        
        let batteryIconSize = NSSize(width: 16, height: 16)
        
        battery100Icon = Awesome.Solid.batteryFull.asImage(size: batteryIconSize, color: .white, backgroundColor: .clear)
        battery75Icon = Awesome.Solid.batteryThreeQuarters.asImage(size: batteryIconSize, color: .white, backgroundColor: .clear)
        battery50Icon = Awesome.Solid.batteryHalf.asImage(size: batteryIconSize, color: .white, backgroundColor: .clear)
        battery25Icon = Awesome.Solid.batteryQuarter.asImage(size: batteryIconSize, color: .white, backgroundColor: .clear)
        battery0Icon = Awesome.Solid.batteryEmpty.asImage(size: batteryIconSize, color: .white, backgroundColor: .clear)
       
    }
    
    override func viewWillAppear() {
        
        // Round window corners
        self.view.window!.backgroundColor             =   NSColor.clear
        self.view.window!.isOpaque                      =   false
        self.view.window!.isMovableByWindowBackground   =   true
        self.view.window!.makeKeyAndOrderFront(self)
        self.view.wantsLayer                =   true
        self.view.layer!.cornerRadius       =   5
        self.view.layer!.backgroundColor    =   NSColor.init(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        self.view.window!.invalidateShadow()
        
        var componentWidth = 0
        let spacingWidth = 10
        
        // Add clock
        
        clockLabel = NSTextField()
        clockLabel.frame = CGRect(origin: CGPoint(x: spacingWidth + 20, y: 2), size: CGSize(width: 100, height: 20))
        clockLabel.stringValue = "Mon 12:13 PM"
        clockLabel.backgroundColor = .clear
        clockLabel.textColor = .white
        clockLabel.isBezeled = false
        clockLabel.isEditable = false
        clockLabel.alignment = .right
        clockLabel.font = NSFont.systemFont(ofSize: 14)
        clockLabel.sizeToFit()
        clockLabel.usesSingleLineMode = true
        
        // Add volume indicator
        
        NotificationCenter.defaultCenter.subscribe(self, eventType: AudioHardwareEvent.self, dispatchQueue: DispatchQueue.main)
        NotificationCenter.defaultCenter.subscribe(self, eventType: AudioDeviceEvent.self, dispatchQueue: DispatchQueue.main)
        NotificationCenter.defaultCenter.subscribe(self, eventType: AudioStreamEvent.self, dispatchQueue: DispatchQueue.main)
        
        volumeButton = NSButton(title: "", image: volumeHighIcon, target: self, action: #selector(mutePressed))
        volumeButton.imageScaling = .scaleNone
        volumeButton.isBordered = true
        volumeButton.alignment = .right
        volumeButton.font = NSFont.systemFont(ofSize: 14)
        volumeButton.usesSingleLineMode = true
        volumeButton.frame = CGRect(x: componentWidth, y: 0, width: 20, height: 20)
        volumeButton.isBordered = false
        volumeButton.sizeToFit()
        updateVolumeIcon()
        
        
        // Add battery indicator
        
        batteryLabel = NSButton(title: "", image: battery100Icon, target: self, action: #selector(batteryPressed))
        batteryLabel.frame = CGRect(origin: CGPoint(x: componentWidth, y: 0), size: CGSize(width: 120, height: 20))
        batteryLabel.toolTip = "100%"
        batteryLabel.imageScaling = .scaleNone
        batteryLabel.isBordered = false
        batteryLabel.alignment = .right
        batteryLabel.font = NSFont.systemFont(ofSize: 14)
        batteryLabel.usesSingleLineMode = true
        batteryLabel.sizeToFit()
        
        
        // Add wifi component
        
        wifiLabel = NSButton(title: "wifiwifiwifi", image: wifiFullIcon, target: self, action: #selector(wifiPressed))
        wifiLabel.frame = CGRect(origin: CGPoint(x: componentWidth, y: 0), size: CGSize(width: 120, height: 20))
        wifiLabel.title = "wifiwifiwifi"
        wifiLabel.imagePosition = .imageRight
        
        
        wifiLabel.imageScaling = .scaleNone
        wifiLabel.isBordered = false
        wifiLabel.alignment = .right
        wifiLabel.font = NSFont.systemFont(ofSize: 14)
        wifiLabel.usesSingleLineMode = true
        wifiLabel.sizeToFit()
        wifiLabel.setAttributes(foreground: NSColor.white, fontSize: 12, alignment: NSTextAlignment.left)

        
        components = [volumeButton, wifiLabel, batteryLabel, clockLabel]
        
        componentWidth += Int(batteryLabel.frame.size.width) + spacingWidth
        
        let barHeight = 25
        
        let componentSpacing = 8
        componentWidth = componentSpacing
        for c in components {

            let cWidth = c.frame.size.width
            
            var offset = 0
            
            if (c.className == "NSTextField") {
                offset = -3
            }
            
            if (c.className == "NSButton") {
                offset = 0
            }
            
            
            c.frame = CGRect(origin: CGPoint(x: componentWidth, y: 0 + offset), size: CGSize(width: cWidth, height: CGFloat(barHeight)))
            
            self.view.addSubview(c)
            componentWidth += Int(cWidth) + componentSpacing
        }
        


        
        DispatchQueue.main.async { [unowned self] in
            let width = componentWidth
            
            self.view.window?.setFrame(CGRect(x: Int(NSScreen.main!.frame.width) - width - 20, y: Int(NSScreen.main!.frame.height) - (barHeight + 6), width: width, height: barHeight), display: true)
        }
        
        // Setup updaters
        
        Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.updateBattery), userInfo: nil, repeats: true)
        updateBattery()
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateClock), userInfo: nil, repeats: true)
        updateClock();

        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.updateWifi), userInfo: nil, repeats: true)
        updateWifi();

        print(self.view.frame)
        
    
        
    }
    
    @objc func wifiPressed() {
        updateWifi()
    }
    
    @objc func updateWifi() {
        let wifiNetwork = CWWiFiClient.shared().interface()
        
        

        if ((wifiNetwork?.ssid()) != nil) {
            let ssid = wifiNetwork?.ssid()!.trunc(length: 9)
//            let ba2 = Awesome.Solid.wifi.asAttributedText(fontSize: 11, color: .white)
//
//            let attString2 = NSMutableAttributedString(string: "\(ssid ?? "?") ", attributes: [NSAttributedString.Key.font : NSFont.systemFont(ofSize: 12.0)])
//            attString2.append(ba2)
            wifiLabel.title = ssid ?? ""
            wifiLabel.image = wifiFullIcon
            wifiLabel.toolTip = "RSSI: \(wifiNetwork?.rssiValue() ?? 0) - Channel: \(wifiNetwork?.wlanChannel()?.channelNumber ?? 0)"
            
            wifiLabel.setAttributes(foreground: NSColor.white, fontSize: 12, alignment: NSTextAlignment.left)

            
//            wifiLabel.textColor = .white

        } else {
            wifiLabel.title = "wifi off"
            wifiLabel.image = wifiOffIcon
            wifiLabel.toolTip = ""
            
            wifiLabel.setAttributes(foreground: NSColor.gray, fontSize: 12, alignment: NSTextAlignment.left)

//            wifiLabel.titl = .gray
        }
        
        
        



    }
    
    @objc func updateClock() {
        clockLabel.stringValue = formatter.string(from: Date())
        clockLabel.toolTip = dateFormatter.string(from: Date())
        
    }
    
    
    @objc func batteryPressed() {
        updateBattery()
    }
    
    @objc func updateBattery() {
        do {
            guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue()
                else { throw BatteryError.error }
            
            guard let sources: NSArray = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue()
                else { throw BatteryError.error }
            
            for ps in sources {
                guard let info: NSDictionary = IOPSGetPowerSourceDescription(snapshot, ps as CFTypeRef)?.takeUnretainedValue()
                else { throw BatteryError.error }
                let percentage = info[kIOPSCurrentCapacityKey] as! Int
                let charging = info[kIOPSIsChargingKey] as? Bool
                
                batteryLabel.toolTip = "\(percentage)% - \((charging ?? false) ? "charging" : "not charging")"
                
                if (percentage > 90) {
                    batteryLabel.image = battery100Icon
                } else if (percentage > 75) {
                    batteryLabel.image = battery75Icon
                } else if (percentage > 50) {
                    batteryLabel.image = battery50Icon
                } else if (percentage > 25) {
                    batteryLabel.image = battery25Icon
                } else {
                    batteryLabel.image = battery0Icon
                }
                        
             
            }
        } catch {
            print("Error updating battery status")
        }
    }
    
    @objc func mutePressed(_sender: Any?) {
        print("Mute pressed!")
        
        let muted = AudioDevice.defaultOutputDevice()?.isMasterChannelMuted(direction: Direction.playback)
        print("Muted? \(muted)")
        
        AudioDevice.defaultOutputDevice()?.setMute(!(AudioDevice.defaultOutputDevice()?.isMasterChannelMuted(direction: Direction.playback))!, channel: 0, direction: Direction.playback)
    }
    
    override func viewDidAppear() {
        self.view.window!.backgroundColor = NSColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    }
    
  
    
    override var representedObject: Any? {
        didSet {
        }
    }
    
    func updateVolumeIcon() {
        let muted = AudioDevice.defaultOutputDevice()?.isMasterChannelMuted(direction: Direction.playback)
        
        volumeButton.toolTip = AudioDevice.defaultOutputDevice()?.name
        if (muted!) {
            volumeButton.image = muteIcon
        } else {
            
            let defaultDevice = AudioDevice.defaultOutputDevice()
            
            if (defaultDevice != nil) {
                let volume = Double((defaultDevice?.virtualMasterVolume(direction: Direction.playback) ?? 0))
                    if (volume > 0.75) {
                        volumeButton.image = volumeHighIcon
                    } else if (volume > 0.4) {
                        volumeButton.image = volumeMediumIcon
                    } else {
                        volumeButton.image = volumeLowIcon
                    }
            }
            
        }
    }
    
    
    func eventReceiver(_ event: Event) {
        switch event {
        case let event as AudioDeviceEvent:
            switch event {
            
            case .volumeDidChange(_, _, _):
                updateVolumeIcon();
                break
            case .muteDidChange(_, _, _):
                updateVolumeIcon();
                break
            default:
                break
            }
        default:
            break
        }
    }
    
    
}

