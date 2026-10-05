import SwiftUI
import AppKit

private enum PetStorePage: String,CaseIterable,Identifiable {
    case discover,favorites,installed,sources
    var id:Self { self }
    var title:String {
        switch self {
        case .discover:return L("发现", "Discover")
        case .favorites:return L("收藏", "Favorites")
        case .installed:return L("已安装", "Installed")
        case .sources:return L("主题来源", "Sources")
        }
    }
    var symbol:String {
        switch self { case .discover:return "square.grid.2x2";case .favorites:return "bookmark";case .installed:return "square.stack";case .sources:return "network" }
    }
}

struct ThemeStoreView: View {
    static let size=NSSize(width:1040,height:740)
    static let minimumSize=NSSize(width:900,height:600)
    static let previewInstallOptions=Notification.Name("CodexPetsPreviewInstallOptions")
    @ObservedObject var store:ThemeStoreModel
    @State private var page:PetStorePage? = {
        if let i=CommandLine.arguments.firstIndex(of:"--ui-page"),CommandLine.arguments.count > i+1 { return PetStorePage(rawValue:CommandLine.arguments[i+1]) ?? .discover }
        return .discover
    }()
    @State private var search=""
    @State private var installedSearch=""
    @State private var sourceSearch=""
    @State private var sourceFilter=""
    @State private var sortByInstalls=true
    @State private var addingSource=false
    @State private var showingSettingsGuide=false
    @State private var showingInstallOptions=false
    @State private var showingStatistics=false
    var body: some View {
        Group {
            if store.visible {
                HStack(spacing:0) {
                    sidebar
                    Divider()
                    VStack(spacing:0) {
                        toolbar
                        Divider()
                        ScrollView {
                            VStack(alignment:.leading,spacing:16) {
                                if let theme=store.selected { detail(theme) }
                                else {
                                    switch page ?? .discover {
                                    case .discover:PetDiscoverView(store:store,search:search,sourceFilter:$sourceFilter,sortByInstalls:$sortByInstalls)
                                    case .favorites:PetDiscoverView(store:store,search:search,sourceFilter:$sourceFilter,sortByInstalls:$sortByInstalls,favoritesOnly:true)
                                    case .installed:installed
                                    case .sources:sources
                                    }
                                }
                            }.padding(16).frame(maxWidth:.infinity,alignment:.leading)
                        }
                        if store.modifyingLocalLibrary {
                            HStack(spacing:9) {
                                ProgressView().controlSize(.small)
                                Text(store.uninstallingLocally ? L("正在卸载主题…", "Removing theme…") : L("正在校验并保存主题…", "Verifying and saving theme…")).font(.system(size:12))
                                Spacer()
                            }.padding(14).background(Color.accentColor.opacity(0.06))
                        }
                        if let notice=store.notice {
                            HStack(alignment:.top,spacing:8) {
                                Image(systemName:"info.circle").foregroundStyle(.blue)
                                VStack(alignment:.leading,spacing:8) {
                                    Text(notice).fixedSize(horizontal:false,vertical:true)
                                    if store.installationHandoff {
                                        HStack(spacing:14) {
                                            Button(L("打开 Codex 设置", "Open Codex settings")) { store.chooseInstalled() }
                                                .disabled(store.handingOff)
                                            Button(L("复制安装链接", "Copy install link")) { store.copyInstallLink() }
                                        }.buttonStyle(.link)
                                    }
                                    if store.trashedDirectory != nil {
                                        Button(L("显示废纸篓文件", "Reveal trashed files")) { store.revealTrashedFiles() }.buttonStyle(.link)
                                    }
                                    if store.localInstallDirectory != nil || store.recoveryDirectory != nil {
                                        HStack(spacing:14) {
                                            if store.localInstallDirectory != nil {
                                                Button(L("打开 Codex 设置", "Open Codex settings")) { store.chooseInstalled() }.disabled(store.handingOff)
                                            }
                                            Button(store.recoveryDirectory != nil ? L("显示恢复文件", "Reveal recovery files") : L("显示主题文件", "Reveal theme files")) { store.revealLocalFiles() }
                                        }.buttonStyle(.link)
                                    }
                                }
                                Spacer(minLength:0)
                                Button { store.notice=nil } label:{ Image(systemName:"xmark") }.buttonStyle(.plain)
                                    .accessibilityLabel(L("关闭提示", "Dismiss notice"))
                            }.font(.system(size:12)).padding(14).background(Color.blue.opacity(0.07))
                        }
                    }.background(Color(nsColor:.controlBackgroundColor))
                }
            } else { Color(nsColor:.windowBackgroundColor) }
        }.frame(minWidth:Self.minimumSize.width,minHeight:Self.minimumSize.height)
            .disabled(store.modifyingLocalLibrary)
            .sheet(isPresented:$addingSource) { PetSourceSheet(store:store) }
            .sheet(item:$store.uninstallRequest) { request in
                PetUninstallConsent(name:request.pet.name,cancel:{store.cancelUninstall()},confirm:{store.confirmUninstall()})
            }
            .sheet(isPresented:$showingSettingsGuide) {
                PetSettingsGuide(openSettings:{showingSettingsGuide=false;store.chooseInstalled()},close:{showingSettingsGuide=false})
            }
            .sheet(item:$store.localInstallRequest) { request in
                PetLocalInstallConsent(name:request.package.name,author:request.package.author,license:request.package.license,source:request.sourceName,
                    destination:request.displayPath,replacing:request.replacing,cancel:{store.cancelLocalInstallation()},confirm:{store.confirmLocalInstallation()})
            }
            .onChange(of:store.visible) { if !$0 { addingSource=false;showingSettingsGuide=false;showingInstallOptions=false } }
            .onChange(of:store.selected?.id) { _ in showingInstallOptions=false }
            .onReceive(NotificationCenter.default.publisher(for:Self.previewInstallOptions)) { note in
                if CommandLine.arguments.contains("--ui-install-options"),let model=note.object as? ThemeStoreModel,model === store { showingInstallOptions=true }
            }
    }
    private var sidebar: some View {
        VStack(alignment:.leading,spacing:0) {
            HStack(spacing:10) {
                PetStoreMark(size:32)
                Text("Codex Pets").font(.system(size:15,weight:.bold))
            }.padding(.horizontal,16).padding(.top,14).padding(.bottom,14)
            VStack(spacing:3) {
                ForEach(PetStorePage.allCases) { item in
                    Button { page=item;store.select(nil);store.notice=nil } label: {
                        HStack(spacing:10) {
                            Image(systemName:item.symbol).frame(width:20)
                            Text(item.title);Spacer()
                        }.font(.system(size:13,weight:.medium)).padding(.horizontal,10).padding(.vertical,8)
                            .foregroundStyle(Color.primary)
                            .background(page == item ? Color.accentColor.opacity(0.13) : Color.clear,in:RoundedRectangle(cornerRadius:7))
                            .contentShape(RoundedRectangle(cornerRadius:8))
                    }.buttonStyle(.plain).accessibilityAddTraits(page == item ? .isSelected : [])
                }
            }.padding(.horizontal,12)
            Spacer(minLength:16)
            VStack(alignment:.leading,spacing:10) {
                Button { showingSettingsGuide=true } label:{ Label(L("设置指引", "Settings guide"),systemImage:"questionmark.circle") }
                    .buttonStyle(.plain).font(.system(size:12)).foregroundStyle(.secondary)
            }.padding(16)
        }.frame(width:180).frame(maxHeight:.infinity).background(PetSidebarMaterial())
    }
    private var pageCount:Int {
        switch page ?? .discover {
        case .discover:return store.matchingThemes(query:search,sourceID:sourceFilter).count
        case .favorites:return store.matchingThemes(query:search,sourceID:sourceFilter,favoritesOnly:true).count
        case .installed:return filteredInstalled.count
        case .sources:return filteredSources.count
        }
    }
    private var filteredInstalled:[InstalledPet] {
        let query=installedSearch.trimmingCharacters(in:.whitespacesAndNewlines)
        return store.installed.filter { query.isEmpty || ($0.name+" "+($0.sourceID.map(store.sourceName) ?? "")).localizedCaseInsensitiveContains(query) }
    }
    private var filteredSources:[PetSource] {
        let query=sourceSearch.trimmingCharacters(in:.whitespacesAndNewlines)
        return store.sources.filter { query.isEmpty || ($0.name+" "+$0.websiteURL.absoluteString).localizedCaseInsensitiveContains(query) }
    }
    private var toolbarSearch:Binding<String> {
        switch page ?? .discover {
        case .installed:return $installedSearch
        case .sources:return $sourceSearch
        default:return $search
        }
    }
    private var searchPrompt:String {
        switch page ?? .discover {
        case .installed:return L("搜索本机主题", "Search local pets")
        case .sources:return L("搜索来源", "Search sources")
        default:return L("搜索主题、作者", "Search pets, authors")
        }
    }
    private var toolbar:some View {
        HStack(spacing:12) {
            if store.selected != nil {
                Button { store.select(nil) } label:{ Label(L("返回", "Back"),systemImage:"chevron.left") }
                    .buttonStyle(.borderless)
            }
            Text(store.selected == nil ? (page ?? .discover).title : L("主题详情", "Theme details"))
                .font(.system(size:16,weight:.semibold))
            if store.selected == nil {
                Text("\(pageCount)").font(.system(size:12)).foregroundStyle(.secondary)
            }
            Spacer()
            if store.selected == nil {
                HStack(spacing:6) {
                    Image(systemName:"magnifyingglass").foregroundStyle(.secondary)
                    TextField(searchPrompt,text:toolbarSearch).textFieldStyle(.plain)
                    if !toolbarSearch.wrappedValue.isEmpty {
                        Button { toolbarSearch.wrappedValue="" } label:{ Image(systemName:"xmark.circle.fill").foregroundStyle(.secondary) }.buttonStyle(.plain)
                    }
                }.font(.system(size:12)).padding(.horizontal,9).padding(.vertical,6).frame(width:230)
                    .background(Color(nsColor:.textBackgroundColor),in:RoundedRectangle(cornerRadius:7))
            }
            if page == .installed && store.selected == nil {
                Button(L("Codex 设置", "Codex settings")) { store.chooseInstalled() }.buttonStyle(.borderless).font(.system(size:12))
            }
            if page == .sources && store.selected == nil {
                Button { addingSource=true } label:{ Image(systemName:"plus") }.buttonStyle(.borderless)
                    .help(L("添加来源", "Add source"))
                    .disabled(store.sources.filter({!$0.builtIn}).count>=8)
            }
            if store.loading { ProgressView().controlSize(.small) }
            Button {
                if page == .installed { store.refreshInstalled() } else { store.refresh() }
            } label: { Image(systemName:"arrow.clockwise") }
                .buttonStyle(.borderless).disabled(store.loading)
                .help(L("刷新主题", "Refresh themes")).accessibilityLabel(L("刷新主题", "Refresh themes"))
        }.padding(.horizontal,16).frame(height:48)
    }
    private func detail(_ theme:PetTheme) -> some View {
        VStack(alignment:.leading,spacing:16) {
            HStack(alignment:.top,spacing:22) {
                PetAnimatedPreview(image:store.sheet,loading:store.preparing,error:store.detailError).frame(width:208,height:336)
                VStack(alignment:.leading,spacing:11) {
                    HStack(alignment:.top) {
                        Text(theme.name).font(.system(size:25,weight:.bold)).textSelection(.enabled)
                        Spacer(minLength:0);PetFavoriteButton(theme:theme,store:store)
                    }
                    Text(theme.author+" · "+store.sourceName(theme.sourceID)).font(.system(size:12)).foregroundStyle(.secondary)
                        .textSelection(.enabled)
                    HStack(spacing:10) {
                        Button {
                            if store.isInstalled(theme) { store.chooseInstalled() } else { store.requestLocalInstallation() }
                        } label:{ Text(store.checkingLocalInstall ? L("正在检查…", "Checking…") : (store.isInstalled(theme) ? L("Codex 设置", "Codex settings") : L("安装到本机", "Install locally"))) }
                            .buttonStyle(.borderedProminent).disabled(store.preparedPackage == nil || store.preparing || store.checkingLocalInstall || store.modifyingLocalLibrary || store.handingOff)
                        Button { showingInstallOptions.toggle() } label:{ Image(systemName:"ellipsis").frame(width:24,height:24) }
                            .buttonStyle(.borderless).help(L("更多安装与使用操作", "More installation and usage options"))
                            .accessibilityLabel(L("更多安装与使用操作", "More installation and usage options"))
                            .popover(isPresented:$showingInstallOptions,arrowEdge:.bottom) {
                                PetInstallOptions(installed:store.isInstalled(theme),
                                    canReinstall:store.preparedPackage != nil && !store.preparing && !store.checkingLocalInstall && !store.modifyingLocalLibrary,
                                    canSend:store.preparedLink != nil && !store.handingOff && !store.preparing,
                                    canCopy:store.preparedLink != nil,
                                    showGuide:{showingInstallOptions=false;showingSettingsGuide=true},
                                    reinstall:{showingInstallOptions=false;store.requestLocalInstallation(reinstall:true)},
                                    sendToCodex:{showingInstallOptions=false;store.installSelected()},
                                    copyLink:{showingInstallOptions=false;store.copyInstallLink()})
                            }
                    }
                    if store.isInstalled(theme) { Text(L("设置 → 虚拟宠物 → 刷新并选择", "Settings → Pets → Refresh and choose")).font(.system(size:11)).foregroundStyle(.secondary) }
                    Text(description(for:theme))
                        .font(.system(size:13)).foregroundStyle(.secondary).fixedSize(horizontal:false,vertical:true).textSelection(.enabled)
                    if let stats=store.statistics(for:theme) {
                        HStack(spacing:10) {
                            PetPopularityLine(stats:stats)
                            if let weekly=stats.installs7d { Text(L("快照周安装 \(weekly.formatted())", "Snapshot week: \(weekly.formatted()) installs")).font(.system(size:10)).foregroundStyle(.secondary) }
                            Button { showingStatistics.toggle() } label:{Image(systemName:"info.circle")}.buttonStyle(.plain).foregroundStyle(.secondary)
                                .help(L("统计来源与时间", "Statistics source and time"))
                                .popover(isPresented:$showingStatistics) { PetStatisticsNote(store:store).padding(16).frame(width:340) }
                        }
                    }
                }.frame(maxWidth:.infinity,alignment:.leading)
            }
            if store.detailError != nil { Button(L("重新加载", "Retry")) { store.select(theme) }.buttonStyle(.link) }
            Divider()
            HStack(alignment:.top,spacing:16) {
                Text(L("授权", "License")).font(.system(size:11,weight:.medium)).foregroundStyle(.secondary).frame(width:52,alignment:.leading)
                Text(theme.license).font(.system(size:12)).textSelection(.enabled).fixedSize(horizontal:false,vertical:true)
                Spacer(minLength:0)
                Button { store.showWebsite(theme.websiteURL) } label:{Image(systemName:"arrow.up.right").frame(width:24,height:24)}.buttonStyle(.borderless).help(L("原始主题与授权", "Original theme and license"))
            }
        }
    }
    private func description(for theme:PetTheme) -> String {
        let text=theme.summary.isEmpty ? (store.preparedPackage?.description ?? "") : theme.summary
        return text.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty ? L("暂无简介。", "No description provided.") : text
    }
    private var installed:some View {
        VStack(alignment:.leading,spacing:0) {
            if store.installed.isEmpty {
                emptyState(symbol:"pawprint",title:L("还没有本机主题", "No local themes yet"),detail:L("在发现页安装喜欢的 Pet。", "Install a Pet from Discover."))
            } else {
                if filteredInstalled.isEmpty { Text(L("没有匹配的本机主题", "No matching local pets")).font(.system(size:13)).foregroundStyle(.secondary).padding(.vertical,16) }
                ForEach(filteredInstalled) { pet in
                    HStack(spacing:12) {
                        PetLocalImage(pet:pet).frame(width:44,height:46)
                        VStack(alignment:.leading,spacing:3) {
                            Text(pet.name).font(.system(size:14,weight:.semibold))
                            Text(pet.sourceID.map(store.sourceName) ?? L("本机导入", "Local import")).font(.system(size:11)).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("v\(pet.version)").font(.system(size:10)).foregroundStyle(.secondary)
                        Menu {
                            Button(L("设置指引…", "Settings guide…")) { showingSettingsGuide=true }
                            Button(L("显示主题文件", "Reveal theme files")) { store.revealInstalledFiles(pet) }
                            Divider()
                            Button(L("卸载…", "Uninstall…"),role:.destructive) { store.requestUninstall(pet) }.disabled(store.checkingLocalInstall)
                        } label:{ Image(systemName:"ellipsis").frame(width:24,height:24) }.menuStyle(.borderlessButton).fixedSize()
                            .accessibilityLabel(L("管理 \(pet.name)", "Manage \(pet.name)"))
                        Button(role:.destructive) { store.requestUninstall(pet) } label:{ Image(systemName:"trash").frame(width:24,height:24) }
                            .buttonStyle(.borderless).disabled(store.checkingLocalInstall).help(L("卸载主题", "Uninstall theme"))
                    }.padding(.vertical,9).contextMenu {
                        Button(L("显示主题文件", "Reveal theme files")) { store.revealInstalledFiles(pet) }
                        Button(L("卸载…", "Uninstall…"),role:.destructive) { store.requestUninstall(pet) }
                    }
                    Divider()
                }
            }
        }
    }
    private var sources:some View {
        VStack(alignment:.leading,spacing:0) {
            if filteredSources.isEmpty { Text(L("没有匹配的来源", "No matching sources")).font(.system(size:13)).foregroundStyle(.secondary).padding(.vertical,16) }
            ForEach(filteredSources) { source in
                HStack(spacing:12) {
                    Image(systemName:source.builtIn ? "shippingbox" : "globe").font(.system(size:20)).frame(width:32)
                    VStack(alignment:.leading,spacing:4) {
                        HStack(spacing:7) {
                            Text(source.name).font(.system(size:14,weight:.semibold))
                            if source.statisticsURL != nil { Image(systemName:"chart.bar").font(.system(size:10)).foregroundStyle(.secondary).help(L("提供来源热度", "Provides popularity counters")) }
                        }
                        if let error=store.sourceErrors[source.id] {
                            Text(error+(store.cachedSources.contains(source.id) ? L(" · 缓存", " · cached") : "")).font(.system(size:11)).foregroundStyle(.secondary)
                        } else {
                            Text(source.websiteURL.host == "github.com" ? source.websiteURL.path.trimmingCharacters(in:CharacterSet(charactersIn:"/")) : (source.websiteURL.host ?? ""))
                                .font(.system(size:11)).foregroundStyle(.secondary).lineLimit(1)
                        }
                    }
                    Spacer()
                    Text(source.enabled ? L("\(store.themes.filter{$0.sourceID == source.id}.count) 个", "\(store.themes.filter{$0.sourceID == source.id}.count) pets") : L("已关闭", "Disabled"))
                        .font(.system(size:11)).foregroundStyle(.secondary)
                    Button { store.showWebsite(source.websiteURL) } label:{Image(systemName:"arrow.up.right").frame(width:24,height:24)}.buttonStyle(.borderless)
                        .help(L("访问来源", "Visit source"))
                    if !source.builtIn {
                        Button(role:.destructive) { store.removeSource(source) } label:{Image(systemName:"minus.circle").frame(width:24,height:24)}.buttonStyle(.borderless)
                    }
                    Toggle(L("启用", "Enable"),isOn:Binding(get:{source.enabled},set:{store.setEnabled(source,$0)})).labelsHidden().toggleStyle(.switch).controlSize(.small)
                        .accessibilityLabel(L("启用 \(source.name)", "Enable \(source.name)"))
                }.padding(.vertical,13)
                Divider()
            }
        }
    }
    private func emptyState(symbol:String,title:String,detail:String) -> some View {
        VStack(spacing:12) {
            if symbol == "pawprint" { PetStoreMark(size:64) }
            else { Image(systemName:symbol).font(.system(size:38,weight:.light)).foregroundStyle(.tertiary) }
            Text(title).font(.system(size:18,weight:.semibold))
            Text(detail).font(.system(size:13)).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }.frame(maxWidth:.infinity).padding(.vertical,55)
    }
}

struct PetTileImage:View {
    let theme:PetTheme
    @ObservedObject var store:ThemeStoreModel
    @State private var image:NSImage?
    var body:some View {
        Group {
            if let image { Image(nsImage:image).resizable().scaledToFit().padding(5) }
            else { PetStoreMark(size:44) }
        }.accessibilityHidden(true).task(id:theme.id) { image=nil;image=await store.thumbnail(for:theme) }
    }
}

private struct PetLocalImage:View {
    let pet:InstalledPet
    @State private var image:NSImage?
    var body:some View {
        Group {
            if let image { Image(nsImage:image).resizable().scaledToFit() }
            else { PetStoreMark(size:44) }
        }.accessibilityHidden(true).task(id:pet.id) {
            let pet=pet
            let frame=await Task.detached(priority:.utility) { () -> CGImage? in
                guard let file=try? FileHandle(forReadingFrom:pet.imageURL) else { return nil }
                defer { try? file.close() }
                guard let bytes=try? file.read(upToCount:32_000_001), let sheet=try? PetSprite.image(bytes,version:pet.version) else { return nil }
                return sheet.cropping(to:CGRect(x:0,y:0,width:192,height:208))
            }.value
            guard !Task.isCancelled else { return }
            image=frame.map { NSImage(cgImage:$0,size:NSSize(width:192,height:208)) }
        }
    }
}

private struct PetSidebarMaterial:NSViewRepresentable {
    func makeNSView(context:Context) -> NSVisualEffectView {
        let view=NSVisualEffectView();view.material = .sidebar;view.blendingMode = .behindWindow;view.state = .followsWindowActiveState;return view
    }
    func updateNSView(_ view:NSVisualEffectView,context:Context) {}
}

private struct PetSourceSheet:View {
    @ObservedObject var store:ThemeStoreModel
    @Environment(\.dismiss) private var dismiss
    @State private var url=""
    @State private var error:String?
    @State private var loading=false
    @State private var task:Task<Void,Never>?
    var body:some View {
        VStack(alignment:.leading,spacing:16) {
            Text(L("添加主题来源", "Add a theme source")).font(.system(size:20,weight:.bold))
            Text(L("粘贴兼容主题目录的公开 HTTPS 地址。", "Paste a public HTTPS URL for a compatible theme catalog."))
                .font(.system(size:13)).foregroundStyle(.secondary)
            TextField("https://example.com/pets/catalog.json",text:$url).textFieldStyle(.roundedBorder)
                .accessibilityLabel(L("主题目录地址", "Theme catalog URL"))
            if let error { Text(error).font(.system(size:12)).foregroundStyle(.red).fixedSize(horizontal:false,vertical:true) }
            HStack {
                if loading { ProgressView().controlSize(.small) }
                Spacer()
                Button(L("取消", "Cancel")) { task?.cancel();dismiss() }.keyboardShortcut(.cancelAction)
                Button(L("添加", "Add")) {
                    loading=true;error=nil
                    task=Task {
                        do { try await store.addSource(url);dismiss() }
                        catch is CancellationError {} catch { self.error=(error as? PetStoreError)?.localizedDescription ?? L("暂时无法连接该来源。", "Could not connect to this source.") }
                        loading=false
                    }
                }.keyboardShortcut(.defaultAction).disabled(loading || url.isEmpty)
            }
        }.padding(24).frame(width:450).onDisappear { task?.cancel() }
    }
}
