pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons

Item {
  id: root

  property var shell: null
  property var manifest: null
  property bool opened: false
  property bool libraryReady: false
  property bool scanning: false
  property bool contentSearching: false
  property bool searchAgain: false
  property string query: ""
  property string sortMode: "recent"
  property bool favoritesOnly: false
  property bool unreadOnly: false
  property bool textOnly: false
  property string contentSearchQuery: ""
  property string message: ""
  property string pendingOpenPath: ""
  property int selectedIndex: 0
  property var library: []
  property var contentHits: []

  readonly property string home: Quickshell.env("HOME")
  readonly property string stateDirectory: home + "/.local/state/omarchy"
  readonly property string statePath: stateDirectory + "/pdf-library.json"
  readonly property color foreground: Color.bar.text
  readonly property color muted: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.56)
  readonly property color accent: Color.bar.active
  readonly property color panelColor: Qt.rgba(Color.bar.background.r, Color.bar.background.g, Color.bar.background.b, 0.96)
  readonly property color raised: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.055)
  readonly property color outline: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.13)

  readonly property var visibleEntries: filteredEntries()
  readonly property var selectedEntry: selectedIndex >= 0 && selectedIndex < visibleEntries.length
    ? visibleEntries[selectedIndex] : null
  readonly property var latestEntry: mostRecentlyOpened()

  function open(payloadJson) {
    root.opened = true
    var payload = {}
    try { payload = JSON.parse(payloadJson || "{}") || {} } catch (e) {}
    if (payload.path) root.openWith(String(payload.path))
    Qt.callLater(function() {
      if (root.opened) surface.forceActiveFocus()
    })
  }

  function close() {
    root.opened = false
  }

  function dismiss() {
    var id = root.manifest && root.manifest.id ? String(root.manifest.id) : "natori.pdf-library"
    if (root.shell && typeof root.shell.hide === "function") root.shell.hide(id)
    else root.close()
  }

  function toggle() {
    if (root.opened) root.close()
    else root.open("{}")
  }

  function beginLoad() {
    if (!stateDirectoryProc.running) stateDirectoryProc.running = true
  }

  function parseLibrary(raw) {
    try {
      var data = JSON.parse(raw || "{}")
      if (data && Array.isArray(data.files)) {
        var valid = []
        for (var i = 0; i < data.files.length; i++) {
          var item = data.files[i]
          if (!item || !item.path) continue
          valid.push({
            path: String(item.path),
            title: String(item.title || titleFromPath(item.path)),
            folder: String(item.folder || folderFromPath(item.path)),
            reads: Math.max(0, Number(item.reads) || 0),
            last: Math.max(0, Number(item.last || item.lastOpened) || 0),
            favorite: item.favorite === true || item.fav === true
          })
        }
        root.library = valid
        root.libraryReady = true
        if (valid.length === 0) root.scanLibrary()
        return
      }
    } catch (e) {}
    root.scanLibrary()
  }

  function titleFromPath(path) {
    var parts = String(path || "").split("/")
    return (parts[parts.length - 1] || "PDF").replace(/\.pdf$/i, "")
  }

  function folderFromPath(path) {
    var parts = String(path || "").split("/")
    return parts.length > 1 ? parts[parts.length - 2] : "~"
  }

  function scanLibrary() {
    if (root.scanning) return
    root.scanning = true
    root.message = ""
    scanProcess.running = true
  }

  function finishScan(raw) {
    var previous = {}
    for (var i = 0; i < root.library.length; i++) previous[root.library[i].path] = root.library[i]

    var found = []
    var lines = String(raw || "").split("\n")
    for (var j = 0; j < lines.length && found.length < 1000; j++) {
      var path = lines[j].trim()
      if (!path || !/\.pdf$/i.test(path)) continue
      var relative = path.substring(root.home.length)
      if (/(^|\/)\./.test(relative)) continue
      if (previous[path]) {
        found.push(previous[path])
      } else {
        found.push({ path: path, title: titleFromPath(path), folder: folderFromPath(path), reads: 0, last: 0, favorite: false })
      }
    }
    root.library = found
    root.libraryReady = true
    root.scanning = false
    root.saveLibrary()
  }

  function saveLibrary() {
    if (!root.libraryReady) return
    stateFile.setText(JSON.stringify({ files: root.library }, null, 2) + "\n")
  }

  function entryFor(path) {
    for (var i = 0; i < root.library.length; i++)
      if (root.library[i].path === path) return i
    return -1
  }

  function changeEntry(path, changes) {
    var next = root.library.slice()
    var index = entryFor(path)
    if (index < 0) {
      next.unshift({ path: path, title: titleFromPath(path), folder: folderFromPath(path), reads: 0, last: 0, favorite: false })
      index = 0
    }
    next[index] = Object.assign({}, next[index], changes)
    root.library = next
    root.saveLibrary()
  }

  function absolutePath(path) {
    var value = String(path || "").trim()
    if (value.indexOf("~/") === 0) return root.home + value.substring(1)
    if (value.charAt(0) !== "/") return root.home + "/" + value
    return value
  }

  function openWith(path) {
    var file = absolutePath(path)
    if (!file) return
    if (!/\.pdf$/i.test(file)) {
      root.message = "Choose a PDF file."
      return
    }
    if (!root.libraryReady) {
      root.pendingOpenPath = file
      return
    }
    root.message = ""
    var index = entryFor(file)
    var entry = index >= 0 ? root.library[index] : {
      path: file, title: titleFromPath(file), folder: folderFromPath(file), reads: 0, last: 0, favorite: false
    }
    root.changeEntry(file, { reads: (Number(entry.reads) || 0) + 1, last: Date.now() })
    Quickshell.execDetached(["zathura", file])
  }

  function toggleFavorite(path) {
    var index = entryFor(path)
    if (index < 0) return
    root.changeEntry(path, { favorite: !root.library[index].favorite })
  }

  function copyPath(path) {
    if (path) Quickshell.execDetached(["wl-copy", path])
  }

  function showFolder(path) {
    var parts = String(path || "").split("/")
    parts.pop()
    Quickshell.execDetached(["xdg-open", parts.join("/") || root.home])
  }

  function filteredEntries() {
    var needle = root.query.trim().toLowerCase()
    var rows = root.library.filter(function(item) {
      if (root.favoritesOnly && !item.favorite) return false
      if (root.unreadOnly && item.reads > 0) return false
      if (root.textOnly && root.contentHits.indexOf(item.path) < 0) return false
      var titleMatch = item.title.toLowerCase().indexOf(needle) >= 0
      var pathMatch = item.path.toLowerCase().indexOf(needle) >= 0
      var contentMatch = root.contentHits.indexOf(item.path) >= 0
      if (needle && !titleMatch && !pathMatch && !contentMatch) return false
      return true
    })
    rows.sort(function(a, b) {
      if (root.sortMode === "reads") return b.reads - a.reads
      if (root.sortMode === "az") return a.title.localeCompare(b.title)
      return b.last - a.last
    })
    return rows
  }

  function mostRecentlyOpened() {
    var latest = null
    for (var i = 0; i < root.library.length; i++) {
      var item = root.library[i]
      if (item.last > 0 && (!latest || item.last > latest.last)) latest = item
    }
    return latest
  }

  function ago(timestamp) {
    if (!timestamp) return "not opened yet"
    var seconds = Math.floor((Date.now() - timestamp) / 1000)
    if (seconds < 60) return "just now"
    if (seconds < 3600) return Math.floor(seconds / 60) + "m ago"
    if (seconds < 86400) return Math.floor(seconds / 3600) + "h ago"
    if (seconds < 604800) return Math.floor(seconds / 86400) + "d ago"
    return Qt.formatDate(new Date(timestamp), "MMM d, yyyy")
  }

  function select(delta) {
    var count = visibleEntries.length
    if (count === 0) {
      selectedIndex = 0
      return
    }
    selectedIndex = Math.max(0, Math.min(count - 1, selectedIndex + delta))
    bookList.positionViewAtIndex(selectedIndex, ListView.Contain)
  }

  function activateFilter(key) {
    if (key === "all") {
      favoritesOnly = false
      unreadOnly = false
      textOnly = false
      sortMode = "recent"
    } else if (key === "favorite") {
      favoritesOnly = !favoritesOnly
    } else if (key === "unread") {
      unreadOnly = !unreadOnly
    } else if (key === "recent" || key === "reads" || key === "az") {
      sortMode = key
    } else if (key === "text" && contentHits.length > 0) {
      textOnly = !textOnly
    }
  }

  function startContentSearch() {
    var search = root.query.trim()
    if (search.length < 3) {
      root.contentHits = []
      root.contentSearchQuery = ""
      root.contentSearching = false
      root.textOnly = false
      return
    }
    if (contentProcess.running) {
      root.searchAgain = true
      return
    }

    var files = []
    for (var i = 0; i < root.library.length && files.length < 80; i++)
      if (/\.pdf$/i.test(root.library[i].path)) files.push(root.library[i].path)
    if (files.length === 0) {
      root.contentHits = []
      root.contentSearchQuery = search
      root.contentSearching = false
      return
    }

    root.searchAgain = false
    root.contentSearchQuery = search
    root.contentSearching = true
    var helper = decodeURIComponent(String(Qt.resolvedUrl("search-content.sh")).replace(/^file:\/\//, ""))
    contentProcess.command = ["sh", helper, search].concat(files)
    contentProcess.running = true
  }

  function finishContentSearch(raw) {
    if (root.contentSearchQuery === root.query.trim()) {
      var matches = []
      var lines = String(raw || "").split("\n")
      for (var i = 0; i < lines.length; i++) {
        var path = lines[i].trim()
        if (path) matches.push(path)
      }
      root.contentHits = matches
      root.contentSearching = false
    }
    if (root.searchAgain || root.contentSearchQuery !== root.query.trim()) {
      root.searchAgain = false
      contentDebounce.restart()
    }
  }

  onQueryChanged: {
    selectedIndex = 0
    if (query.trim().length >= 3) {
      contentHits = []
      textOnly = false
      contentDebounce.restart()
    }
    else {
      contentDebounce.stop()
      contentHits = []
      contentSearchQuery = ""
      contentSearching = false
      textOnly = false
    }
  }
  onLibraryReadyChanged: {
    if (libraryReady && pendingOpenPath !== "") {
      var path = pendingOpenPath
      pendingOpenPath = ""
      Qt.callLater(function() { root.openWith(path) })
    }
  }
  onVisibleEntriesChanged: selectedIndex = Math.min(selectedIndex, Math.max(0, visibleEntries.length - 1))
  Component.onCompleted: beginLoad()

  Process {
    id: stateDirectoryProc
    command: ["mkdir", "-p", root.stateDirectory]
    onExited: stateFile.reload()
  }

  FileView {
    id: stateFile
    path: root.statePath
    printErrors: false
    onLoaded: root.parseLibrary(text())
    onLoadFailed: root.scanLibrary()
  }

  Process {
    id: scanProcess
    command: ["find", root.home, "-maxdepth", "6", "-path", "*/.*", "-prune", "-o", "-type", "f", "-iname", "*.pdf", "-print"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.finishScan(text)
    }
    stderr: StdioCollector { waitForEnd: true }
  }

  Process {
    id: contentProcess
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.finishContentSearch(text)
    }
    stderr: StdioCollector { waitForEnd: true }
  }

  Timer {
    id: contentDebounce
    interval: 650
    onTriggered: root.startContentSearch()
  }

  FloatingWindow {
    id: window
    title: "PDF Library"
    implicitWidth: 780
    implicitHeight: 620
    minimumSize: Qt.size(620, 420)
    color: "transparent"
    visible: root.opened
    onVisibleChanged: {
      if (!visible && root.opened) root.dismiss()
    }

    Rectangle {
      id: surface
      anchors.fill: parent
      anchors.margins: 1
      radius: 16
      color: root.panelColor
      border.width: 1
      border.color: root.outline
      focus: true

      Keys.onEscapePressed: root.dismiss()
      Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Down || event.key === Qt.Key_J) {
          root.select(1)
          event.accepted = true
        } else if (event.key === Qt.Key_Up || event.key === Qt.Key_K) {
          root.select(-1)
          event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_O) {
          if (root.selectedEntry) root.openWith(root.selectedEntry.path)
          event.accepted = true
        } else if (event.key === Qt.Key_F) {
          if (root.selectedEntry) root.toggleFavorite(root.selectedEntry.path)
          event.accepted = true
        } else if (event.key === Qt.Key_C) {
          if (root.selectedEntry) root.copyPath(root.selectedEntry.path)
          event.accepted = true
        } else if (event.key === Qt.Key_Slash) {
          searchField.forceActiveFocus()
          event.accepted = true
        }
      }

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        RowLayout {
          Layout.fillWidth: true
          spacing: 10

          Rectangle {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            radius: 15
            color: root.raised
            border.width: 1
            border.color: root.outline
            Text { anchors.centerIn: parent; text: "▤"; color: root.foreground; font.family: Style.font.family; font.pixelSize: 15 }
          }

          Text {
            text: "PDF LIBRARY"
            color: root.foreground
            font.family: Style.font.family
            font.pixelSize: 13
            font.weight: Font.Bold
            font.letterSpacing: 1.2
          }

          Item { Layout.fillWidth: true }

          Text {
            text: root.scanning ? "Scanning…" : root.library.length + " PDFs"
            color: root.muted
            font.family: Style.font.family
            font.pixelSize: 10
          }

          Rectangle {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            radius: 15
            color: refreshMouse.containsMouse ? root.raised : "transparent"
            border.width: 1
            border.color: root.outline
            Text { anchors.centerIn: parent; text: "↻"; color: root.foreground; font.pixelSize: 17 }
            MouseArea { id: refreshMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.scanLibrary() }
          }

          Rectangle {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            radius: 15
            color: closeMouse.containsMouse ? root.raised : "transparent"
            border.width: 1
            border.color: root.outline
            Text { anchors.centerIn: parent; text: "×"; color: root.foreground; font.pixelSize: 20 }
            MouseArea { id: closeMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.dismiss() }
          }
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: root.outline }

        Rectangle {
          visible: !root.query && root.latestEntry !== null
          Layout.fillWidth: true
          Layout.preferredHeight: 66
          radius: 12
          color: root.raised
          border.width: 1
          border.color: root.outline

          RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 13
            anchors.rightMargin: 12
            spacing: 12

            ColumnLayout {
              Layout.fillWidth: true
              spacing: 3
              Text { text: "CONTINUE READING"; color: root.muted; font.family: Style.font.family; font.pixelSize: 9; font.weight: Font.Bold; font.letterSpacing: 1.1 }
              Text { text: root.latestEntry ? root.latestEntry.title : ""; color: root.foreground; font.family: Style.font.family; font.pixelSize: 12; font.weight: Font.DemiBold; elide: Text.ElideRight; Layout.fillWidth: true }
              Text { text: root.latestEntry ? ("Last opened " + root.ago(root.latestEntry.last) + " · " + root.latestEntry.reads + " opens") : ""; color: root.muted; font.family: Style.font.family; font.pixelSize: 9 }
            }

            Rectangle {
              Layout.preferredWidth: 74
              Layout.preferredHeight: 30
              radius: 15
              color: continueMouse.containsMouse ? root.accent : root.raised
              border.width: 1
              border.color: root.outline
              Text { anchors.centerIn: parent; text: "Open"; color: continueMouse.containsMouse ? Color.bar.background : root.foreground; font.family: Style.font.family; font.pixelSize: 10; font.weight: Font.DemiBold }
              MouseArea { id: continueMouse; anchors.fill: parent; hoverEnabled: true; onClicked: if (root.latestEntry) root.openWith(root.latestEntry.path) }
            }
          }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: 8

          Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            radius: 9
            color: root.raised
            border.width: 1
            border.color: searchField.activeFocus ? root.accent : root.outline

            RowLayout {
              anchors.fill: parent
              anchors.leftMargin: 10
              anchors.rightMargin: 10
              spacing: 8
              Text { text: "⌕"; color: root.muted; font.pixelSize: 17 }
              TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: "Search titles, paths, and PDF text (3+ characters)"
                placeholderTextColor: root.muted
                color: root.foreground
                selectionColor: root.accent
                font.family: Style.font.family
                font.pixelSize: 10
                background: null
                selectByMouse: true
                onTextChanged: root.query = text
                onAccepted: if (root.selectedEntry) root.openWith(root.selectedEntry.path)
              }
            }
          }

          Rectangle {
            Layout.preferredWidth: 205
            Layout.preferredHeight: 36
            radius: 9
            color: root.raised
            border.width: 1
            border.color: pathField.activeFocus ? root.accent : root.outline
            RowLayout {
              anchors.fill: parent
              anchors.leftMargin: 9
              anchors.rightMargin: 6
              spacing: 5
              TextField {
                id: pathField
                Layout.fillWidth: true
                placeholderText: "/path/to/file.pdf"
                placeholderTextColor: root.muted
                color: root.foreground
                selectionColor: root.accent
                font.family: Style.font.family
                font.pixelSize: 9
                background: null
                selectByMouse: true
                onAccepted: {
                  root.openWith(text)
                  text = ""
                }
              }
              Rectangle {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 24
                radius: 7
                color: pathOpenMouse.containsMouse ? root.accent : root.raised
                Text { anchors.centerIn: parent; text: "Open"; color: root.foreground; font.family: Style.font.family; font.pixelSize: 9; font.weight: Font.DemiBold }
                MouseArea { id: pathOpenMouse; anchors.fill: parent; hoverEnabled: true; onClicked: { root.openWith(pathField.text); pathField.text = "" } }
              }
            }
          }
        }

        Text {
          visible: root.message !== ""
          Layout.fillWidth: true
          text: root.message
          color: root.foreground
          font.family: Style.font.family
          font.pixelSize: 9
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: 6
          Repeater {
            model: [
              { key: "all", label: "All" },
              { key: "favorite", label: "★" },
              { key: "recent", label: "Recent" },
              { key: "reads", label: "Most read" },
              { key: "az", label: "A–Z" },
              { key: "unread", label: "Unread" },
              { key: "text", label: root.contentSearching ? "Searching…" : (root.contentHits.length ? "Text " + root.contentHits.length : "Text") }
            ]
            delegate: Rectangle {
              required property var modelData
              implicitWidth: chipLabel.implicitWidth + 24
              Layout.preferredWidth: implicitWidth
              Layout.preferredHeight: 27
              radius: 14
              property bool active: modelData.key === "all"
                ? !root.favoritesOnly && !root.unreadOnly && !root.textOnly && root.sortMode === "recent"
                : modelData.key === "favorite" ? root.favoritesOnly
                : modelData.key === "unread" ? root.unreadOnly
                : modelData.key === "text" ? root.textOnly
                : root.sortMode === modelData.key
              color: active ? root.raised : chipMouse.containsMouse ? root.raised : "transparent"
              border.width: 1
              border.color: active ? root.accent : root.outline
              Text { id: chipLabel; anchors.centerIn: parent; text: modelData.label; color: parent.active ? root.foreground : root.muted; font.family: Style.font.family; font.pixelSize: 9; font.weight: Font.DemiBold }
              MouseArea { id: chipMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.activateFilter(modelData.key) }
            }
          }
          Item { Layout.fillWidth: true }
          Text {
            visible: root.textOnly
            text: root.contentHits.length + " text matches"
            color: root.muted
            font.family: Style.font.family
            font.pixelSize: 9
          }
        }

        ListView {
          id: bookList
          Layout.fillWidth: true
          Layout.fillHeight: true
          clip: true
          spacing: 4
          currentIndex: root.selectedIndex
          model: root.visibleEntries
          highlightMoveDuration: 110
          highlight: Rectangle { radius: 9; color: root.raised; border.width: 1; border.color: root.outline }
          ScrollBar.vertical: ScrollBar { active: true; policy: ScrollBar.AsNeeded }

          delegate: Rectangle {
            required property var modelData
            required property int index
            width: ListView.view.width
            height: 48
            radius: 9
            color: rowMouse.containsMouse ? root.raised : "transparent"
            border.width: 1
            border.color: root.outline

            MouseArea {
              id: rowMouse
              anchors.fill: parent
              hoverEnabled: true
              onClicked: {
                root.selectedIndex = index
                root.openWith(modelData.path)
              }
            }

            RowLayout {
              anchors.fill: parent
              anchors.leftMargin: 11
              anchors.rightMargin: 11
              spacing: 10
              z: 1

              Rectangle {
                Layout.preferredWidth: 25
                Layout.preferredHeight: 25
                radius: 13
                color: starMouse.containsMouse ? root.raised : "transparent"
                Text { anchors.centerIn: parent; text: modelData.favorite ? "★" : "☆"; color: modelData.favorite ? root.foreground : root.muted; font.pixelSize: 16 }
                MouseArea { id: starMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.toggleFavorite(modelData.path) }
              }

              ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text { text: modelData.title; color: root.foreground; font.family: Style.font.family; font.pixelSize: 10; font.weight: Font.DemiBold; elide: Text.ElideRight; Layout.fillWidth: true }
                Text { text: modelData.folder + (modelData.reads > 0 ? " · " + modelData.reads + " opens · " + root.ago(modelData.last) : " · unread"); color: root.muted; font.family: Style.font.family; font.pixelSize: 8; elide: Text.ElideRight; Layout.fillWidth: true }
              }

              Rectangle {
                visible: root.contentHits.indexOf(modelData.path) >= 0
                Layout.preferredWidth: 54
                Layout.preferredHeight: 19
                radius: 10
                color: root.raised
                border.width: 1
                border.color: root.outline
                Text { anchors.centerIn: parent; text: "MATCH"; color: root.muted; font.family: Style.font.family; font.pixelSize: 7; font.weight: Font.Bold; font.letterSpacing: 0.7 }
              }

              Text { text: "Zathura  →"; color: root.muted; font.family: Style.font.family; font.pixelSize: 9 }
            }
          }

          Text {
            visible: root.libraryReady && root.visibleEntries.length === 0
            anchors.centerIn: parent
            text: root.scanning ? "Scanning for PDFs…" : root.contentSearching ? "Searching inside PDFs…" : "No PDFs match this view."
            color: root.muted
            font.family: Style.font.family
            font.pixelSize: 10
          }
        }

        Rectangle {
          Layout.fillWidth: true
          Layout.preferredHeight: 42
          radius: 10
          color: root.raised
          border.width: 1
          border.color: root.outline
          RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 11
            anchors.rightMargin: 9
            spacing: 8
            Text { text: root.selectedEntry ? root.selectedEntry.title : "No PDF selected"; color: root.foreground; font.family: Style.font.family; font.pixelSize: 9; font.weight: Font.DemiBold; elide: Text.ElideRight; Layout.fillWidth: true }

            Rectangle {
              Layout.preferredWidth: 30; Layout.preferredHeight: 28; radius: 8
              color: favoriteActionMouse.containsMouse ? root.raised : "transparent"
              Text { anchors.centerIn: parent; text: root.selectedEntry && root.selectedEntry.favorite ? "★" : "☆"; color: root.foreground; font.pixelSize: 15 }
              MouseArea { id: favoriteActionMouse; anchors.fill: parent; hoverEnabled: true; enabled: !!root.selectedEntry; onClicked: root.toggleFavorite(root.selectedEntry.path) }
            }
            Rectangle {
              Layout.preferredWidth: 30; Layout.preferredHeight: 28; radius: 8
              color: copyActionMouse.containsMouse ? root.raised : "transparent"
              Text { anchors.centerIn: parent; text: "⧉"; color: root.foreground; font.pixelSize: 15 }
              MouseArea { id: copyActionMouse; anchors.fill: parent; hoverEnabled: true; enabled: !!root.selectedEntry; onClicked: root.copyPath(root.selectedEntry.path) }
            }
            Rectangle {
              Layout.preferredWidth: 30; Layout.preferredHeight: 28; radius: 8
              color: folderActionMouse.containsMouse ? root.raised : "transparent"
              Text { anchors.centerIn: parent; text: "▱"; color: root.foreground; font.pixelSize: 16 }
              MouseArea { id: folderActionMouse; anchors.fill: parent; hoverEnabled: true; enabled: !!root.selectedEntry; onClicked: root.showFolder(root.selectedEntry.path) }
            }
            Rectangle {
              Layout.preferredWidth: 68; Layout.preferredHeight: 28; radius: 14
              color: openActionMouse.containsMouse ? root.accent : root.raised
              border.width: 1
              border.color: root.outline
              Text { anchors.centerIn: parent; text: "Open"; color: root.foreground; font.family: Style.font.family; font.pixelSize: 9; font.weight: Font.DemiBold }
              MouseArea { id: openActionMouse; anchors.fill: parent; hoverEnabled: true; enabled: !!root.selectedEntry; onClicked: root.openWith(root.selectedEntry.path) }
            }
          }
        }

        Text {
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignHCenter
          text: "↑ ↓ browse   ·   Enter open   ·   F favorite   ·   C copy path   ·   / search   ·   Esc close"
          color: root.muted
          font.family: Style.font.family
          font.pixelSize: 8
        }
      }
    }
  }
}
