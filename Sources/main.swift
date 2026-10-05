import AppKit
import SwiftUI

private enum PreviewLibrary {
    static let root:URL = {
        let root=URL(fileURLWithPath:"/private/tmp",isDirectory:true).appendingPathComponent("codex-pets-ui-library-"+UUID().uuidString,isDirectory:true)
        try? FileManager.default.createDirectory(at:root,withIntermediateDirectories:false)
        return root
    }()
}
private final class PreviewPreferences:UserDefaults {
    private var values=[String:Any]()
    override func object(forKey key:String) -> Any? { values[key] }
    override func set(_ value:Any?,forKey key:String) { values[key]=value }
}

@MainActor final class PetStoreDelegate:NSObject,NSApplicationDelegate,NSWindowDelegate {
    private var checking:Bool { CommandLine.arguments.contains { $0.hasPrefix("--ui-") } }
    lazy var store=ThemeStoreModel(preferences:checking ? PreviewPreferences() : .standard,
        libraryRoot:checking ? PreviewLibrary.root : PetLocalLibrary.root,
        openCodexURL:{ url in
            if CommandLine.arguments.contains("--ui-handoff-preview") { return .failure(.failed) }
            return await PetCodexLauncher().open(url)
        },
        trashItem:{ directory in
            if CommandLine.arguments.contains(where:{$0.hasPrefix("--ui-")}) {
                let trash=PreviewLibrary.root.appendingPathComponent("synthetic-trash",isDirectory:true)
                try FileManager.default.createDirectory(at:trash,withIntermediateDirectories:true)
                let result=trash.appendingPathComponent(UUID().uuidString,isDirectory:true)
                try FileManager.default.moveItem(at:directory,to:result);return result
            }
            return try PetPackageUninstaller().trash(directory)
        })
    var window:NSWindow?
    var guideWindow:NSWindow?
    func applicationDidFinishLaunching(_ notification:Notification) {
        let menu=NSMenu()
        let applicationItem=NSMenuItem();let applicationMenu=NSMenu()
        let aboutItem=applicationMenu.addItem(withTitle:L("关于 Codex Pets", "About Codex Pets"),action:#selector(showAbout(_:)),keyEquivalent:"")
        aboutItem.target=self
        let settingsGuide=applicationMenu.addItem(withTitle:L("Codex 设置指引…", "Codex settings guide…"),action:#selector(showSettingsGuide(_:)),keyEquivalent:",")
        settingsGuide.target=self
        applicationMenu.addItem(.separator())
        applicationMenu.addItem(withTitle:L("退出 Codex Pets", "Quit Codex Pets"),action:#selector(NSApplication.terminate(_:)),keyEquivalent:"q")
        applicationItem.submenu=applicationMenu;menu.addItem(applicationItem)
        let editItem=NSMenuItem();let editMenu=NSMenu(title:L("编辑", "Edit"))
        for (title,action,key) in [(L("撤销", "Undo"),Selector(("undo:")),"z"),
                                   (L("剪切", "Cut"),#selector(NSText.cut(_:)),"x"),
                                   (L("复制", "Copy"),#selector(NSText.copy(_:)),"c"),
                                   (L("粘贴", "Paste"),#selector(NSText.paste(_:)),"v"),
                                   (L("全选", "Select All"),#selector(NSText.selectAll(_:)),"a")] {
            editMenu.addItem(withTitle:title,action:action,keyEquivalent:key)
        }
        editItem.submenu=editMenu;menu.addItem(editItem)
        let windowItem=NSMenuItem();let windowMenu=NSMenu(title:L("窗口", "Window"))
        windowMenu.addItem(withTitle:L("关闭窗口", "Close Window"),action:#selector(NSWindow.performClose(_:)),keyEquivalent:"w")
        windowMenu.addItem(withTitle:L("最小化", "Minimize"),action:#selector(NSWindow.performMiniaturize(_:)),keyEquivalent:"m")
        windowMenu.addItem(withTitle:L("缩放", "Zoom"),action:#selector(NSWindow.performZoom(_:)),keyEquivalent:"")
        NSApp.windowsMenu=windowMenu
        windowItem.submenu=windowMenu;menu.addItem(windowItem)
        let settingsItem=NSMenuItem();let settingsMenu=NSMenu(title:L("设置", "Settings"))
        for (title,action) in [(L("虚拟宠物设置指引…", "Pets settings guide…"),#selector(showSettingsGuide(_:))),
                               (L("打开 Codex 设置", "Open Codex settings"),#selector(openCodexSettings(_:))),
                               (L("恢复默认宠物指引…", "Restore default pet guide…"),#selector(showSettingsGuide(_:)))] {
            let item=settingsMenu.addItem(withTitle:title,action:action,keyEquivalent:"");item.target=self
        }
        settingsItem.submenu=settingsMenu;menu.addItem(settingsItem);NSApp.mainMenu=menu
        if CommandLine.arguments.contains("--ui-check") { store.usePreview(themes:[]) }
        if CommandLine.arguments.contains("--ui-dark") { NSApp.appearance=NSAppearance(named:.darkAqua) }
        if CommandLine.arguments.contains("--ui-light") { NSApp.appearance=NSAppearance(named:.aqua) }
        showStore()
        if CommandLine.arguments.contains("--ui-about") { showAbout(nil) }
        if CommandLine.arguments.contains("--ui-settings-guide") { showSettingsGuide(nil) }
        if let index=CommandLine.arguments.firstIndex(of:"--ui-capture"),CommandLine.arguments.count > index+1 {
            let path=CommandLine.arguments[index+1]
            Task {
                for _ in 0..<120 {
                    if !self.store.loading { break }
                    try? await Task.sleep(nanoseconds:500_000_000)
                }
                if self.checking && CommandLine.arguments.contains("--ui-community-check") {
                    for source in self.store.sources.dropFirst(4) {
                        guard let theme=self.store.themes.first(where:{$0.sourceID == source.id}) else {
                            print("Community catalog failed: \(source.id)");exit(1)
                        }
                        self.store.select(theme)
                        for _ in 0..<180 {
                            if !self.store.preparing { break }
                            try? await Task.sleep(nanoseconds:500_000_000)
                        }
                        guard self.store.preparedPackage != nil else {
                            print("Community package failed: \(source.id): \(self.store.detailError ?? "timeout")");exit(1)
                        }
                        self.store.requestLocalInstallation();await self.store.finishInstallationCheck()
                        guard self.store.localInstallRequest != nil else { print("Community confirmation failed: \(source.id)");exit(1) }
                        self.store.confirmLocalInstallation();await self.store.finishCurrentInstallation()
                        guard self.store.isInstalled(theme) else { print("Community installation failed: \(source.id)");exit(1) }
                        print("Community package verified in an isolated library: \(source.id)")
                    }
                    self.store.select(nil)
                }
                if self.checking && CommandLine.arguments.contains("--ui-favorites-preview") {
                    for theme in self.store.themes.prefix(6) { self.store.toggleFavorite(theme) }
                }
                if CommandLine.arguments.contains("--ui-detail"),let theme=self.store.themes.first(where:{ theme in
                    if let i=CommandLine.arguments.firstIndex(of:"--ui-detail-id"),CommandLine.arguments.count > i+1 { return theme.id == CommandLine.arguments[i+1] }
                    if let i=CommandLine.arguments.firstIndex(of:"--ui-detail-source"),CommandLine.arguments.count > i+1 { return theme.sourceID == CommandLine.arguments[i+1] }
                    return self.store.statistics(for:theme) != nil
                }) ?? self.store.themes.first {
                    self.store.select(theme)
                    for _ in 0..<120 {
                        if !self.store.preparing { break }
                        try? await Task.sleep(nanoseconds:500_000_000)
                    }
                }
                if self.checking && CommandLine.arguments.contains("--ui-package-preview"),let package=self.store.preparedPackage {
                    let previewRoot=URL(fileURLWithPath:"/private/tmp",isDirectory:true).appendingPathComponent("codex-pets-package-review-"+UUID().uuidString,isDirectory:true)
                    try? FileManager.default.createDirectory(at:previewRoot,withIntermediateDirectories:false)
                    do {
                        let receipt=try PetPackageInstaller().install(package,in:previewRoot.appendingPathComponent("pets",isDirectory:true))
                        print("Validated package for review only: \(receipt.directory.path)")
                    } catch { print("Package review staging failed");exit(1) }
                }
                if self.checking && (CommandLine.arguments.contains("--ui-local-install-preview") || CommandLine.arguments.contains("--ui-native-install-check") || CommandLine.arguments.contains("--ui-native-uninstall-check") || CommandLine.arguments.contains("--ui-uninstall-preview")) {
                    self.store.requestLocalInstallation()
                    await self.store.finishInstallationCheck()
                    if CommandLine.arguments.contains("--ui-native-install-check") || CommandLine.arguments.contains("--ui-native-uninstall-check") || CommandLine.arguments.contains("--ui-uninstall-preview") {
                        guard self.store.localInstallRequest != nil else { print("Native local installation request failed");exit(1) }
                        self.store.confirmLocalInstallation()
                        await self.store.finishCurrentInstallation()
                        guard self.store.localInstallDirectory != nil,self.store.selected.map({self.store.isInstalled($0)}) == true else { print("Native local installation verification failed");exit(1) }
                        print("Native local package verified in an isolated test library")
                        if CommandLine.arguments.contains("--ui-native-uninstall-check") || CommandLine.arguments.contains("--ui-uninstall-preview"),let pet=self.store.installed.first {
                            self.store.requestUninstall(pet);await self.store.finishInstallationCheck()
                            guard self.store.uninstallRequest != nil else { print("Native uninstall request failed");exit(1) }
                            if CommandLine.arguments.contains("--ui-native-uninstall-check") {
                                self.store.confirmUninstall();await self.store.finishCurrentInstallation()
                                guard self.store.installed.isEmpty,self.store.trashedDirectory != nil else { print("Native uninstall verification failed");exit(1) }
                                print("Native uninstall verified in an isolated synthetic Trash")
                            }
                        }
                    }
                }
                if CommandLine.arguments.contains("--ui-handoff-preview") {
                    self.store.installSelected()
                    for _ in 0..<20 {
                        if !self.store.handingOff { break }
                        try? await Task.sleep(nanoseconds:100_000_000)
                    }
                }
                if self.checking && CommandLine.arguments.contains("--ui-return-to-list") { self.store.select(nil) }
                if self.checking && CommandLine.arguments.contains("--ui-install-options") {
                    NotificationCenter.default.post(name:ThemeStoreView.previewInstallOptions,object:self.store)
                }
                var captureDelay:Double=4
                if let i=CommandLine.arguments.firstIndex(of:"--ui-capture-delay"),CommandLine.arguments.count > i+1,let value=Double(CommandLine.arguments[i+1]),value.isFinite { captureDelay=min(15,max(1,value)) }
                try? await Task.sleep(nanoseconds:UInt64(captureDelay*1_000_000_000))
                let captureAuxiliary=["--ui-about","--ui-local-install-preview","--ui-uninstall-preview","--ui-settings-guide","--ui-install-options"].contains(where:CommandLine.arguments.contains)
                let captureWindow=captureAuxiliary ? NSApp.windows.first(where:{$0 !== self.window && $0.isVisible}) ?? self.window : self.window
                guard let view=captureWindow?.contentView,let bitmap=view.bitmapImageRepForCachingDisplay(in:view.bounds) else { exit(1) }
                view.cacheDisplay(in:view.bounds,to:bitmap)
                var captured=bitmap
                if captureAuxiliary,let captureWindow,let source=bitmap.cgImage,
                   let context=CGContext(data:nil,width:source.width,height:source.height,bitsPerComponent:8,bytesPerRow:source.width*4,
                       space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue) {
                    captureWindow.effectiveAppearance.performAsCurrentDrawingAppearance {
                        context.setFillColor(captureWindow.backgroundColor.cgColor)
                    }
                    context.fill(CGRect(x:0,y:0,width:source.width,height:source.height))
                    context.draw(source,in:CGRect(x:0,y:0,width:source.width,height:source.height))
                    if let composed=context.makeImage() { captured=NSBitmapImageRep(cgImage:composed) }
                }
                guard let data=captured.representation(using:.png,properties:[:]) else { exit(1) }
                do { try data.write(to:URL(fileURLWithPath:path)) } catch { exit(1) }
                print("Native UI: \(self.store.themes.count) themes, \(self.store.sourceErrors.count) source errors, statistics: \(self.store.popularity.count), detail prepared: \(self.store.preparedLink != nil)")
                if self.checking { print("Public catalogs: "+self.store.sources.map { source in "\(source.id)=\(self.store.themes.filter{$0.sourceID == source.id}.count)\(self.store.sourceErrors[source.id].map{ " (\($0))" } ?? "")" }.joined(separator:", ")) }
                let expectingDetail=CommandLine.arguments.contains("--ui-detail") && !CommandLine.arguments.contains("--ui-return-to-list")
                let failed=self.store.themes.isEmpty || (expectingDetail && self.store.preparedLink == nil)
                self.store.close();exit(failed ? 1 : 0)
            }
        }
        if CommandLine.arguments.contains("--ui-check") {
            DispatchQueue.main.asyncAfter(deadline:.now()+1) {
                precondition(self.window?.isVisible == true && self.store.visible)
                precondition(self.window?.title == Bundle.main.object(forInfoDictionaryKey:"CFBundleDisplayName") as? String)
                precondition(NSApp.mainMenu?.items.first?.submenu?.items.contains(where:{$0.keyEquivalent == "," && $0.action == #selector(self.showSettingsGuide(_:))}) == true)
                precondition(NSApp.mainMenu?.items.contains(where:{$0.submenu?.items.contains(where:{$0.action == #selector(self.openCodexSettings(_:))}) == true}) == true)
                self.window?.close();precondition(!self.store.visible)
                print("Standalone native UI passed: store window opens, closes and cancels activity")
                exit(0)
            }
        }
    }
    @objc func openCodexSettings(_ sender:Any?) { showStore();store.chooseInstalled() }
    @objc func showSettingsGuide(_ sender:Any?) {
        if guideWindow == nil {
            let panel=NSWindow(contentRect:NSRect(x:0,y:0,width:502,height:350),styleMask:[.titled,.closable],backing:.buffered,defer:false)
            panel.title=L("Codex 设置指引", "Codex settings guide");panel.isReleasedWhenClosed=false
            panel.contentView=NSHostingView(rootView:PetSettingsGuide(
                openSettings:{ [weak self] in self?.guideWindow?.close();self?.openCodexSettings(nil) },
                close:{ [weak self] in self?.guideWindow?.close() }))
            panel.center();guideWindow=panel
        }
        guideWindow?.makeKeyAndOrderFront(nil)
    }
    @objc func showAbout(_ sender:Any?) {
        let glyph=PetStoreBrand.glyph ?? NSImage(systemSymbolName:"cat.fill",accessibilityDescription:nil)
        var options=[NSApplication.AboutPanelOptionKey:Any]()
        if let glyph { options[.applicationIcon]=glyph }
        NSApp.orderFrontStandardAboutPanel(options:options)
        let tint=NSColor(name:nil) { appearance in
            appearance.bestMatch(from:[.darkAqua,.aqua]) == .darkAqua ? .white : .black
        }
        func tintGlyph(in view:NSView) {
            if let icon=view as? NSImageView,icon.image?.isTemplate == true { icon.contentTintColor=tint }
            for child in view.subviews { tintGlyph(in:child) }
        }
        if let about=NSApp.windows.first(where:{$0 !== window && $0.isVisible}),let content=about.contentView { tintGlyph(in:content) }
    }
    func showStore() {
        if window == nil {
            let w=NSWindow(contentRect:NSRect(origin:.zero,size:CommandLine.arguments.contains("--ui-compact") ? ThemeStoreView.minimumSize : ThemeStoreView.size),styleMask:[.titled,.closable,.miniaturizable,.resizable],backing:.buffered,defer:false)
            w.title="Codex Pets";w.delegate=self;w.isReleasedWhenClosed=false
            w.contentMinSize=ThemeStoreView.minimumSize;w.titlebarAppearsTransparent=true;w.titlebarSeparatorStyle = .none
            let hosting=NSHostingView(rootView:ThemeStoreView(store:store));hosting.sizingOptions=[];hosting.autoresizingMask=[.width,.height]
            w.contentView=hosting;w.center();window=w
        }
        store.open();window?.makeKeyAndOrderFront(nil);NSApp.activate(ignoringOtherApps:true)
    }
    func applicationShouldHandleReopen(_ sender:NSApplication,hasVisibleWindows flag:Bool) -> Bool { showStore();return true }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender:NSApplication) -> Bool { !CommandLine.arguments.contains("--ui-check") }
    func windowWillClose(_ notification:Notification) { store.close() }
    func windowDidBecomeKey(_ notification:Notification) { store.refreshInstalled() }
    func windowShouldClose(_ sender:NSWindow) -> Bool { !store.modifyingLocalLibrary }
    func applicationShouldTerminate(_ sender:NSApplication) -> NSApplication.TerminateReply {
        guard store.modifyingLocalLibrary else { return .terminateNow }
        Task { await store.finishCurrentInstallation();sender.reply(toApplicationShouldTerminate:true) }
        return .terminateLater
    }
    func applicationWillTerminate(_ notification:Notification) { store.close() }
}
MainActor.assumeIsolated {
    let app=NSApplication.shared;app.setActivationPolicy(.regular)
    let delegate=PetStoreDelegate();app.delegate=delegate
    withExtendedLifetime(delegate) { app.run() }
}
