/*let asm = Assembler(program: "/mnt/workspace/SAP-2.0/Divide.txt")
let alltokens = asm.getAllTokens()
for token in alltokens {
	print(token)
}
print("### End of tokens ###")
let assembled = asm.assemble().map { $0! }
for i in assembled {
	print(i)
}
print("-------------TESTING LISTING------------")
print(asm.listing())*/

//let vm = VM(fileName: "TM3.bin")
//print(vm.run())

//let asm = Assembler(program: "/mnt/workspace/SAP-2.0/TM3.txt")
//print(asm.assemble())
let ui = UI()
ui.run()