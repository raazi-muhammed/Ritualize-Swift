import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct RoutineHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RoutineDataItem.order) private var routines: [RoutineDataItem]
    @State private var showAddRoutineModal: Bool = false
    @State private var isEditMode: Bool = false
    @State private var showExportSheet: Bool = false
    @State private var showImportSheet: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var isProcessingFile: Bool = false
    @State private var selectedRoutines: Set<RoutineDataItem> = []
    @State private var showDeleteConfirmation: Bool = false
    @State private var newRoutine: RoutineDataItem?

    func createNewRoutine() -> RoutineDataItem {
        let routine = RoutineDataItem(
            name: "",
            color: DefaultValues.color,
            icon: DefaultValues.icon
        )
        modelContext.insert(routine)
        return routine
    }

    var body: some View {
        NavigationView {
            RoutineListView(
                selectedRoutines: $selectedRoutines
            )
            .overlay(alignment: .bottomLeading) {
                Button(action: {
                    newRoutine = createNewRoutine()
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
                ToolbarItemGroup {
                    if isEditMode && !selectedRoutines.isEmpty {
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            Label("Delete", systemImage: "trash")
                                .foregroundStyle(.red)
                        }
                    }

                    if isEditMode {
                        Button(action: {
                            isEditMode.toggle()
                        }) {
                            Text("Done")
                        }
                    } else {
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
                            .disabled(isProcessingFile)

                            Button(action: {
                                showImportSheet = true
                            }) {
                                Label("Import", systemImage: "square.and.arrow.down")
                            }
                            .disabled(isProcessingFile)
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                }
            }
            .environment(\.editMode, .constant(isEditMode ? .active : .inactive))
            .listStyle(.insetGrouped)

        }
        .sheet(isPresented: $showAddRoutineModal) {
            if let routine = newRoutine {
                RoutineFormSheet(
                    routine: routine,
                    title: "Add Routine"
                )
            }
        }
        .alert("Delete Routines", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                showDeleteConfirmation = false
            }
            Button("Delete", role: .destructive) {
                deleteSelectedRoutines()
                showDeleteConfirmation = false
            }
        } message: {
            Text(
                "Are you sure you want to delete \(selectedRoutines.count) routine\(selectedRoutines.count == 1 ? "" : "s")? This action cannot be undone."
            )
        }
        .fileExporter(
            isPresented: $showExportSheet,
            document: CSVDocument(csvString: CSVManager.shared.exportToCSV(routines: routines)),
            contentType: .commaSeparatedText,
            defaultFilename: "routines.csv"
        ) { result in
            isProcessingFile = true
            defer { isProcessingFile = false }

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
            isProcessingFile = true
            defer { isProcessingFile = false }

            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                guard url.startAccessingSecurityScopedResource() else { return }
                defer { url.stopAccessingSecurityScopedResource() }

                do {
                    let csvString = try String(contentsOf: url, encoding: .utf8)
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

    private func deleteSelectedRoutines() {
        for routine in selectedRoutines {
            modelContext.delete(routine)
        }
        selectedRoutines.removeAll()
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
