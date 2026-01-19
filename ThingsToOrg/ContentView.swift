//
//  ContentView.swift
//  ThingsToOrg
//
//  Created by S2Ler on 27.09.2025.
//

import SwiftUI
import Combine
import ThingsToOrgKit
import UniformTypeIdentifiers

// MARK: - Script Runner ViewModel

@MainActor
final class ScriptRunnerViewModel: ObservableObject {
    struct Command: Identifiable, Hashable {
        let id: String
        let name: String
        let description: String?
        let script: AppleScript
    }

    @Published var commands: [Command]
    @Published var isExecuting: Bool = false
    @Published var output: String = ""
    @Published var errorMessage: String?
    @Published var lastExecutedCommand: Command?

    init(commands: [Command] = [
        .init(
            id: "areas",
            name: "List Areas",
            description: "Fetches the names of all areas defined in Things.",
            script: areas()
        ),
        .init(
            id: "projects",
            name: "List Projects",
            description: "Fetches all projects with their status.",
            script: listProjects()
        ),
        .init(
            id: "tags",
            name: "List Tags",
            description: "Fetches all tags defined in Things.",
            script: listTags()
        ),
        .init(
            id: "today",
            name: "List Today",
            description: "Fetches all tasks in Today list.",
            script: listToday()
        )
    ]) {
        self.commands = commands
    }

    func run(_ command: Command) async {
        guard !isExecuting else { return }

        isExecuting = true
        errorMessage = nil
        output = ""
        lastExecutedCommand = command

        do {
            let result = try await command.script()
            output = result.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            if let scriptError = error as? AppleScript.Error {
                errorMessage = scriptError.payload
            } else {
                errorMessage = error.localizedDescription
            }
        }

        isExecuting = false
    }
}

// MARK: - Export ViewModel

@MainActor
final class ExportViewModel: ObservableObject {
    @Published var isExporting = false
    @Published var exportResult: ExportService.ExportResult?
    @Published var errorMessage: String?
    @Published var previewContent: String?
    @Published var showPreview = false

    private let exportService = ExportService()

    func export(to url: URL) async {
        isExporting = true
        errorMessage = nil
        exportResult = nil

        do {
            exportResult = try await exportService.exportToFile(url: url)
        } catch {
            if let scriptError = error as? AppleScript.Error {
                errorMessage = scriptError.payload
            } else {
                errorMessage = error.localizedDescription
            }
        }

        isExporting = false
    }

    func generatePreview() async {
        isExporting = true
        errorMessage = nil

        do {
            let result = try await exportService.export()
            previewContent = result.content
            showPreview = true
        } catch {
            if let scriptError = error as? AppleScript.Error {
                errorMessage = scriptError.payload
            } else {
                errorMessage = error.localizedDescription
            }
        }

        isExporting = false
    }
}

// MARK: - Org Document

struct OrgDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText] }

    var content: String

    init(content: String = "") {
        self.content = content
    }

    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            content = String(data: data, encoding: .utf8) ?? ""
        } else {
            content = ""
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: content.data(using: .utf8)!)
    }
}

// MARK: - Script Runner View

struct ScriptRunnerView: View {
    @ObservedObject var viewModel: ScriptRunnerViewModel

    var body: some View {
        List {
            Section("Commands") {
                if viewModel.commands.isEmpty {
                    Text("No commands available yet.")
                        .foregroundStyle(.secondary)
                }

                ForEach(viewModel.commands) { command in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(command.name)
                            .font(.headline)

                        if let description = command.description {
                            Text(description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Button {
                            Task { await viewModel.run(command) }
                        } label: {
                            Label("Run", systemImage: "play.fill")
                                .labelStyle(.titleAndIcon)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.isExecuting)
                    }
                    .padding(.vertical, 4)
                }
            }

            Section("Output") {
                if viewModel.isExecuting {
                    HStack(spacing: 12) {
                        ProgressView()
                        Text("Running \(viewModel.lastExecutedCommand?.name ?? "command")…")
                    }
                } else if let error = viewModel.errorMessage {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Error")
                            .font(.headline)
                            .foregroundStyle(.red)
                        Text(error)
                            .font(.body)
                            .foregroundStyle(.red)
                    }
                } else if !viewModel.output.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        if let command = viewModel.lastExecutedCommand {
                            Text("Result for \(command.name)")
                                .font(.headline)
                        }
                        Text(viewModel.output)
                            .font(.system(.body, design: .monospaced))
                    }
                } else {
                    Text("Run a command to see its output here.")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Export View

struct ExportView: View {
    @StateObject private var viewModel = ExportViewModel()
    @State private var showFileSaver = false
    @State private var exportDocument = OrgDocument()

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)

                Text("Export to Org-mode")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Export all your Things 3 data (areas, projects, tasks, tags) to an Org-mode file.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 20)

            Spacer()

            // Buttons
            VStack(spacing: 12) {
                Button {
                    Task {
                        await viewModel.generatePreview()
                    }
                } label: {
                    Label("Preview Export", systemImage: "eye")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.isExporting)

                Button {
                    showFileSaver = true
                } label: {
                    Label("Export to File…", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isExporting)
            }
            .padding(.horizontal, 40)

            // Progress
            if viewModel.isExporting {
                HStack(spacing: 12) {
                    ProgressView()
                    Text("Exporting from Things 3…")
                }
                .padding()
            }

            // Error
            if let error = viewModel.errorMessage {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                    Text(error)
                        .font(.callout)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }

            // Success
            if let result = viewModel.exportResult {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.green)

                    Text("Export Complete!")
                        .font(.headline)

                    HStack(spacing: 24) {
                        StatView(title: "Areas", value: result.statistics.areasCount)
                        StatView(title: "Projects", value: result.statistics.projectsCount)
                        StatView(title: "Tasks", value: result.statistics.toDosCount)
                        StatView(title: "Tags", value: result.statistics.tagsCount)
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }

            Spacer()
        }
        .fileExporter(
            isPresented: $showFileSaver,
            document: exportDocument,
            contentType: .plainText,
            defaultFilename: "things-export.org"
        ) { result in
            switch result {
            case .success(let url):
                Task {
                    await viewModel.export(to: url)
                }
            case .failure(let error):
                viewModel.errorMessage = error.localizedDescription
            }
        }
        .sheet(isPresented: $viewModel.showPreview) {
            PreviewSheet(content: viewModel.previewContent ?? "")
        }
    }
}

// MARK: - Stat View

struct StatView: View {
    let title: String
    let value: Int

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Preview Sheet

struct PreviewSheet: View {
    let content: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(content)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
            .navigationTitle("Export Preview")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .frame(minWidth: 600, minHeight: 400)
    }
}

// MARK: - Main Content View

struct ContentView: View {
    @StateObject private var scriptViewModel = ScriptRunnerViewModel()

    var body: some View {
        TabView {
            NavigationStack {
                ScriptRunnerView(viewModel: scriptViewModel)
                    .navigationTitle("Things Scripts")
            }
            .tabItem {
                Label("Commands", systemImage: "terminal")
            }

            NavigationStack {
                ExportView()
                    .navigationTitle("Export")
            }
            .tabItem {
                Label("Export", systemImage: "square.and.arrow.up")
            }
        }
        .frame(minWidth: 500, minHeight: 400)
    }
}

#Preview {
    ContentView()
}
