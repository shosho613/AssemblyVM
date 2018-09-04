import Foundation
class UI {
    let helpStr = "Welcome to SAP-2.0!\nCommands:\nasm </path/to/file> NO .txt: assemble a program\nrun <file.bin>: run a program\nprintlst </path/to/file.txt>: print listing file for program\nprintbin </path/to/file.txt>: print binary file for program\nprintsym </path/to/file.txt>: print symbol file for program\nhelp: print this help text\nquit: quit SAP-2.0"
	static func ssip(_ expression: String) -> [String]{ //split String into parts
		return expression.characters.split{$0 == " " }.map{String($0)}
	}
	func wtf(_ path: String, _ data: String) -> String? {
        let url = NSURL.fileURL(withPathComponents: [path])
        do {
            try data.write(to: url!, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            return "Failed writing to URL: \(url), Error: " + error.localizedDescription
        }
        return nil
    }
    func run() {
        var command = ""
        var commandArray = [String]()
        print(helpStr)
        while command != "quit" {
        print("SAP> ", terminator: "")
        command = readLine()!
        commandArray = UI.ssip(command)
            if command == "help" {
                print(helpStr)
            }
            if commandArray[0] == "asm" {
                let asm = Assembler(program: "\(commandArray[1]).txt")
                let assembled = asm.assemble() 
                if asm.numberErrors > 0 {
                    print("\(asm.numberErrors) errors encountered in program, see listing file for details")
                }
                else {
                    var binary = ""
                    for value in assembled {
                        binary += String(describing: value!)
                        binary += "\n"
                    }
                    let temp = commandArray[1]
                    _ = wtf("\(temp).bin", binary)
                    var s = ""
                    for (key,value) in asm.symbolTable{
                        s += "\(key)  \(value)\n"
                    }
                    _ = wtf("\(temp).sym", String(describing: s))
                }
            }
            if commandArray[0] == "run" {
                let vm = VM(fileName: commandArray[1])
                vm.run()
            }
            if commandArray[0] == "printbin" {
                let asm = Assembler(program: "\(commandArray[1]).txt")
                let assembled = asm.assemble() 
                for i in assembled {
                    print(i!)
                }
            }
            if commandArray[0] == "printsym" {
                let asm = Assembler(program: "\(commandArray[1]).txt")
                let assembled = asm.assemble() 
                var s = ""
                for (key,value) in asm.symbolTable {
                    s += "\(key)\t\(value)\n"
                }
                print(s)
            }
        }
    }
}