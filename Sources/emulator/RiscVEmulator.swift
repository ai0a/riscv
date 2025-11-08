//
//  main.swift
//  riscv
//
//  Created by z on 4/6/24.
//

import Foundation
import ArgumentParser

@main
struct RiscVEmulator: ParsableCommand {
    @Argument(help: "The path to the file containing executable code.")
    var codeFilePath: String
    
    @Flag
    var isElf: Bool = false

    @Flag(name: .customLong("riscv-test"))
    var isRunningTestFromRiscvTests: Bool = false
    
    func run() throws {
        let url = URL(filePath: codeFilePath)
        let fileData = try Data(contentsOf: url)
        
        // 8mb ish
        var ram = Memory(data: Data(count: 0x8000000))
        ram.data.replaceSubrange(ram.data.startIndex...fileData.count, with: fileData)
        var cpu = CPU(
            pc: 0,
            memory: ram,
            ecallHandler: isRunningTestFromRiscvTests ? RiscvTestsEcallHandler() : nil
        )
        for _ in 0..<5000 {
            do {
                try cpu.executeSingleInstruction()
            } catch {
                print(error)
                cpu.printRegisters()
                throw error
            }
        }
        if !isRunningTestFromRiscvTests {
            cpu.printRegisters()
        }
    }
}
