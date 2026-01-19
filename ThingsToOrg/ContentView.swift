//
//  ContentView.swift
//  ThingsToOrg
//
//  Created by S2Ler on 27.09.2025.
//

import SwiftUI
import Combine
import ThingsToOrgKit

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

struct ContentView: View {
    @StateObject private var viewModel = ScriptRunnerViewModel()

    var body: some View {
        NavigationStack {
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
            .navigationTitle("Things Scripts")
        }
    }
}

#Preview {
    ContentView()
}

