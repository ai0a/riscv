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
    
    func run() throws {
        let url = URL(filePath: codeFilePath)
        let codeData = try Data(contentsOf: url)
        
        // 8mb ish
        var ram = Ram(data: Data(count: 0x8000000))
        ram.data.replaceSubrange(ram.data.startIndex...codeData.count, with: codeData)
        var cpu = CPU(pc: 0, memory: ram)
        for _ in 0..<5000 {
            do {
                try cpu.executeSingleInstruction()
            } catch {
                print(error)
                return cpu.printRegisters()
            }
        }
        cpu.printRegisters()
    }
}
