//
//  AppDelegate.swift
//  GitHubStatus
//
//  Created by Dylan Maryk on 25/04/2020.
//  Copyright © 2020 Dylan Maryk. All rights reserved.
//

import Cocoa
import Combine

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var timerCancellable: AnyCancellable?
    private var sessionCancellable: AnyCancellable?
    private var statusUrl: URL?
    
    private let statusItem: NSStatusItem = {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(named: "octoface")
        return statusItem
    }()
    
    private let statusMenuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return URLSession(configuration: config)
    }()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let menu = NSMenu()
        menu.addItem(self.statusMenuItem)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Refresh", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Launch at Login", action: nil, keyEquivalent: ""))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Check for Updates", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "GitHub Repo",
                                action: #selector(self.openRepoUrl(_:)),
                                keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Octoface Attribution",
                                action: #selector(self.openAttributionUrl(_:)),
                                keyEquivalent: ""))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: nil, keyEquivalent: ""))
        self.statusItem.menu = menu
        
        self.timerCancellable = Timer.publish(every: 300, on: RunLoop.main, in: .common)
            .autoconnect()
            .sink { [unowned self] _ in
                self.retrieveStatus()
            }
        
        self.retrieveStatus()
    }
    
    private func retrieveStatus() {
        self.statusMenuItem.title = "Getting status..."
        self.statusMenuItem.action = nil
        self.statusMenuItem.isEnabled = false
        self.sessionCancellable?.cancel()
        self.sessionCancellable = self.session
            .dataTaskPublisher(for: URL(string: "https://kctbh9vrtdwd.statuspage.io/api/v2/status.json")!)
            .map { $0.data }
            .decode(type: StatusResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [unowned self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.setStatusItemColor(nil)
                    
                    self.statusMenuItem.title = error.localizedDescription
                    self.statusMenuItem.action = nil
                    self.statusMenuItem.isEnabled = false
                }
            }, receiveValue: { [unowned self] statusResponse in
                let statusItemColor = self.statusItemColor(for: statusResponse.status.indicator)
                self.setStatusItemColor(statusItemColor)
                
                self.statusUrl = statusResponse.page.url
                
                self.statusMenuItem.title = statusResponse.status.description
                self.statusMenuItem.action = #selector(self.openStatusUrl(_:))
                self.statusMenuItem.isEnabled = true
            })
    }
    
    private func setStatusItemColor(_ color: NSColor?) {
        self.statusItem.button?.image = self.statusItem.button?.image?.tinted(with: color)
    }
    
    @objc private func openStatusUrl(_ sender: AnyObject?) {
        self.openUrl(self.statusUrl)
    }
    
    @objc private func openRepoUrl(_ sender: AnyObject?) {
        self.openUrl(URL(string: "https://github.com/dylanmaryk/GitHubStatus")!)
    }
    
    @objc private func openAttributionUrl(_ sender: AnyObject?) {
        self.openUrl(URL(string: "https://github.com/primer/octicons/blob/master/LICENSE")!)
    }
    
    private func openUrl(_ url: URL?) {
        if let url = url {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func statusItemColor(for indicator: Indicator) -> NSColor? {
        switch indicator {
        case .none:
            return nil
        case .minor:
            return .yellow
        case .major:
            return .orange
        case .critical:
            return .red
        }
    }
    
}
