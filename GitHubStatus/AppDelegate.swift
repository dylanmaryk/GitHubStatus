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
    
    private var statusItem: NSStatusItem?
    private var cancellable: AnyCancellable?
    private var statusUrl: URL?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        self.statusItem?.button?.image = NSImage(named: "octoface")
        
        let menu = NSMenu()
        let statusMenuItem = NSMenuItem(title: "Getting status...", action: nil, keyEquivalent: "")
        menu.addItem(statusMenuItem)
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
        self.statusItem?.menu = menu
        
        self.cancellable = URLSession.shared
            .dataTaskPublisher(for: URL(string: "https://kctbh9vrtdwd.statuspage.io/api/v2/status.json")!)
            .map { $0.data }
            .decode(type: StatusResponse.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    statusMenuItem.title = error.localizedDescription
                    statusMenuItem.action = nil
                }
            }, receiveValue: { [unowned self] statusResponse in
                DispatchQueue.main.async {
                    self.statusItem?.button?.image =
                        self.statusItem?.button?.image?
                            .tinted(with: self.statusItemColor(for: statusResponse.status.indicator))
                }
                self.statusUrl = statusResponse.page.url
                statusMenuItem.title = statusResponse.status.description
                statusMenuItem.action = #selector(self.openStatusUrl(_:))
            })
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
