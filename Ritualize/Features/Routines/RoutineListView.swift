import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct RoutineListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RoutineDataItem.order) private var routines: [RoutineDataItem]
    @State private var showAddRoutineModal: Bool = false
    @State private var routineInput: String = ""
    @State private var routineColor: String = DefaultValues.color
    @State private var selectedIcon: String = DefaultValues.icon
    @State private var showIconPicker: Bool = false
    @State private var selectedRoutine: RoutineDataItem?
    @State private var isEditMode: Bool = false
    @State private var showExportSheet: Bool = false
    @State private var showImportSheet: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(routines) { item in
                    RoutineItem(item: item)
                }
                .onMove { from, to in
                    let fromIdx = from.first!
                    for (index, routine) in routines.enumerated() {
                        if fromIdx == index {
                            routine.order = to
                        } else if index >= to {
                            routine.order = routine.order + 1
                        }
                    }
                }
            }
            .overlay {
                if routines.isEmpty {
                    ContentUnavailableView {
                        Label("No Routines", systemImage: "checklist")
                    } description: {
                        Text("Add routines to get started")
                    }
                }
            }
            .overlay(alignment: .bottomLeading) {
                Button(action: {
                    self.showAddRoutineModal.toggle()
                }) {
                    Label("Add Routine", systemImage: "plus.circle.fill")
                        .foregroundStyle(Color.accentColor)
                        .fontWeight(.bold)
                }
                .buttonStyle(.plain)
                .padding()
            }
            .navigationTitle("Routines")
            .toolbar {
                if isEditMode == true {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            isEditMode.toggle()
                        }) {
                            Text("Done")
                        }
                    }
                } else {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Button(action: {
                                isEditMode.toggle()
                            }) {
                                Label(isEditMode ? "Done" : "Edit", systemImage: "pencil")
                            }

                            Button(action: {
                                showExportSheet = true
                            }) {
                                Label("Export", systemImage: "square.and.arrow.up")
                            }

                            Button(action: {
                                showImportSheet = true
                            }) {
                                Label("Import", systemImage: "square.and.arrow.down")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                }
            }
            #if os(iOS)
                .environment(\.editMode, Binding.constant(isEditMode ? .active : .inactive))
            #endif
        }
        .sheet(isPresented: $showAddRoutineModal) {
            RoutineFormSheet(
                title: "Add Routine",
                name: $routineInput,
                icon: $selectedIcon,
                showIconPicker: $showIconPicker,
                color: $routineColor,
                onDismiss: {
                    showAddRoutineModal = false
                    routineInput = ""
                    routineColor = DefaultValues.color
                    selectedIcon = DefaultValues.icon
                },
                onSave: {
                    let newItem = RoutineDataItem(
                        name: routineInput, color: routineColor)
                    newItem.icon = selectedIcon
                    newItem.order = routines.count
                    modelContext.insert(newItem)
                    showAddRoutineModal = false
                    routineInput = ""
                    routineColor = DefaultValues.color
                    selectedIcon = DefaultValues.icon
                }
            )
        }
        .fileExporter(
            isPresented: $showExportSheet,
            document: CSVDocument(csvString: CSVManager.shared.exportToCSV(routines: routines)),
            contentType: .commaSeparatedText,
            defaultFilename: "routines.csv"
        ) { result in
            switch result {
            case .success(let url):
                print("Saved to \(url)")
            case .failure(let error):
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
        .fileImporter(
            isPresented: $showImportSheet,
            allowedContentTypes: [.commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                guard url.startAccessingSecurityScopedResource() else { return }
                do {
                    let csvString = try String(contentsOf: url)
                    try CSVManager.shared.importFromCSV(
                        csvString: csvString, modelContext: modelContext)
                } catch {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
}

struct CSVDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }

    var csvString: String

    init(csvString: String) {
        self.csvString = csvString
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
            let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        csvString = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(csvString.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}
