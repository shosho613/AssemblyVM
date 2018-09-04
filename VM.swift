import Foundation
class VM {
	var mr = MemReg()
	var counter = 0
	var retCounter = 0
	var stack = IntStack(size: 50)
	enum Command : Int { //ordered so each case has the correct rawValue
		case halt,clrr,clrx,clrm,clrb,movir,movrr,movrm,movmr,movxr,movar,movb,addir,addrr,addmr,addxr,subir,subrr,submr,subxr,mulir,mulrr,mulmr,mulxr,divir,divrr,divmr,divxr,jmp,sojz,sojnz,aojz,aojnz,cmpir,cmprr,cmpmr,jmpn,jmpz,jmpp,jsr,ret,push,pop,stackc,outci,outcr,outcx,outcb,readi,printi,readc,readln,brk,movrx,movxx,outs,nop,jmpne
	}
	
	// HELPER FUNCTIONS //
	
	func ssil(_ expression: String) -> [String] { //split string into lines
		return expression.characters.split{$0 == "\n"}.map{String($0)}
	}
	func satia(_ array: [String]) -> [Int] { //string array to int array
		return array.filter({Int($0) != nil})
					.map({Int($0)!})
	}
	func ctu(_ c: Character) ->Int{ //char to unicode
		let s = String(c)
		return Int(s.unicodeScalars[s.unicodeScalars.startIndex].value)
	}
	func utc(_ n: Int)-> Character{ //unicode to char
		return Character(UnicodeScalar(n)!)
	}
	func rtf(_ path:String)->(message: String?, fileText: String?){ //read text file
		let text:String
		do {
			text = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
		}
		catch {
			return ("\(error)", nil)
		}
	print("Successfully read file \(path)")
	return(nil,text)
	}
	
	// INITIALIZER //
	
	init(fileName: String) {
		var program = satia(ssil(rtf(fileName).fileText!)) //read file, split into lines, convert lines to int
		mr.loadProgram(program)
		print("Loaded \(fileName) into memory")
		counter = program[1]
		
	}
	
	// PROGRAM //
	
	func processcmd(_ cmd: Command) -> Bool { //return FALSE when halting, return TRUE otherwise
		switch cmd {
			case .halt: //0
				print("### HALT ###")
				exit(0)
			case .clrr: //1
				counter += 1
				let t1 = mr.memory[counter]
				mr.uregi(t1,0)
				counter += 1
				return true
			case .clrx: //2
				counter += 1
				let t1 = mr.registers[mr.memory[counter]]
				mr.umemi(t1,0)
				counter += 1
				return true
			case .clrm: //3
				counter += 1
				let t1 = mr.memory[mr.memory[counter]]
				mr.umemi(t1,0)
				counter += 1
				return true
			case .clrb: //4
				counter += 1
				let t1 = mr.memory[counter]
				counter += 1
				let t2 = mr.memory[counter]
				for i in t1+1...t1+t2 {
					mr.umemi(i,0)
				}
				counter += 1
				return true
			case .movir: //5
				counter += 1
				let t1 = mr.memory[counter]
				counter += 1
				let t2 = mr.memory[counter]
				mr.uregi(t2,t1)
				counter += 1
				return true
			case .movrr: //6
				counter += 1
				let t1 = mr.memory[counter]
				counter += 1
				let t2 = mr.memory[counter]
				mr.uregr(t1,t2)
				counter += 1
				return true
			case .movrm: //7
				counter += 1
				let t1 = mr.memory[counter]
				counter += 1
				let t2 = mr.memory[mr.memory[counter]]
				mr.umemi(t2,t1)
				counter += 1
				return true
			case .movmr: //8
				counter += 1 // move counter to label
				let v = mr.memory[mr.memory[counter]]
				counter += 1 // move counter to register
				let i = mr.memory[counter]
				mr.uregi(i, v)
				counter += 1
				return true
			case .movxr: //9
				counter += 1
				let t1 = mr.memory[mr.registers[mr.memory[counter]]]
				counter += 1 
				let t2 = mr.memory[counter]
				mr.uregi(t2, t1)
				counter += 1
				return true
			case .movar: //10
				counter += 1
				let t1 = mr.memory[counter]
				counter += 1
				let t2 = mr.memory[counter]
				mr.uregi(t2, t1)
				counter += 1
				return true
			case .movb: //11
				counter += 1
				var t1 = mr.memory[counter] // starting location
				counter += 1
				let t2 = mr.memory[counter] // destination
				counter += 1
				let t3 = mr.memory[counter] // count
				for i in t2+1...t2+t3 {
					mr.umemi(i,mr.memory[t1])
					t1 += 1
				}
				counter += 1
				return true
			case .addir: //12
				counter += 1 // counter is now where int is stored
				let temp = mr.memory[counter] // Int is stored
				counter += 1 // counter indicates register
				let r = mr.memory[counter] //register stored
				mr.urega(r, temp)
				counter += 1
				return true
				
			case .addrr: //13
				counter += 1 //counter is now at first regi
				let t1 = mr.registers[mr.memory[counter]]  //first regi value
				counter += 1 //counter indicates resulting regi
				let t2 = mr.memory[counter] //value at second regi + value at first regi
				mr.urega(t2, t1)
				counter += 1
				return true
			case .addmr: //14
				counter += 1
				let t1 = mr.memory[mr.memory[counter]]
				counter += 1
				let t2 = mr.memory[counter]
				mr.urega(t2, t1)
				counter += 1
				return true
			case .addxr: //15
				counter += 1
				let t1 = mr.memory[mr.registers[mr.memory[counter]]] 
				counter += 1
				let t2 = mr.memory[counter]
				mr.urega(t2, t1)
				counter += 1
				return true
			case .subir: //16
				counter += 1
				let t1 = mr.memory[counter] //int being subtracted
				counter += 1
				let t2 = mr.memory[counter] //register subtracting from
				mr.urega(t2,(-1*t1))
				counter += 1
				return true
			case .subrr: //17
				counter += 1
				let t1 = mr.registers[mr.memory[counter]]
				counter += 1
				let t2 = mr.memory[counter]
				mr.uregi(t2,t2-t1)
				counter += 1
				return true
			case .submr: //18
				counter += 1
				let t1 = mr.memory[mr.memory[counter]]
				counter += 1
				let t2 = mr.memory[counter]
				mr.urega(t2,(-1*t1))
				counter += 1
				return true
			case .subxr: //19
				counter += 1
				let t1 = mr.memory[mr.registers[mr.memory[counter]]]
				counter += 1
				let t2 = mr.memory[counter]
				mr.urega(t2,(-1*t1))
				counter += 1
				return true
			case .mulir: //20
				counter += 1
				let t1 = mr.memory[counter]
				counter += 1
				let t2 = mr.memory[counter]
				mr.uregm(t2,t1)
				counter += 1
				return true
			case .mulrr: //21
				counter += 1
				let t1 = mr.registers[mr.memory[counter]]
				counter += 1
				let t2 = mr.memory[counter]
			//	print("### Multiplying \(t1) * \(t2)")
				mr.uregm(t2,t1)
			//	print("### Successfully multiplied \(mr.registers[mr.memory[counter]])")
				counter += 1
				return true
			case .mulmr: //22
				counter += 1
				let t1 = mr.memory[mr.memory[counter]]
				counter += 1
				let t2 = mr.memory[counter]
				mr.urega(t2,t1)
				counter += 1
				return true
			case .mulxr: //23
				counter += 1
				let t1 = mr.memory[mr.registers[mr.memory[counter]]]
				counter += 1
				let t2 = mr.memory[counter]
				mr.urega(t2,t1)
				counter += 1
				return true
			case .divir: //24
				counter += 1
				let t1 = mr.memory[counter]
				counter += 1
				let t2 = mr.memory[counter]
				mr.uregd(t2,t1)
				counter += 1
				return true
			case .divrr: //25
				counter += 1
				let t1 = mr.registers[mr.memory[counter]]
				counter += 1
				let t2 = mr.memory[counter]
				mr.uregd(t2,t1)
				counter += 1
				return true
			case .divmr: //26
				counter += 1
				let t1 = mr.memory[mr.memory[counter]]
				counter += 1
				let t2 = mr.memory[counter]
				mr.uregd(t2,t1)
				counter += 1
				return true
			case .divxr: //27
				counter += 1
				let t1 = mr.memory[mr.registers[mr.memory[counter]]]
				counter += 1
				let t2 = mr.memory[counter]
				mr.uregd(t2,t1)
				counter += 1
				return true
			case .jmp: //28
				counter += 1
				counter = mr.memory[counter]
				return true
			case .sojz: //29
				counter += 1
				let r1 = mr.registers[mr.memory[counter]] 
				mr.urega(r1, -1)
				if r1 == 0{
					counter += 1
					counter = mr.memory[mr.memory[counter]]	
					return true
				}
				counter += 1
				return true
			case .sojnz: //30 
				counter += 1
				let r = mr.registers[mr.memory[counter]] 
				mr.urega(r, -1)
				if r != 0{
					counter += 1
					counter = mr.memory[counter]
					return true
				}
				counter += 1
				return true
			case .aojz: //31
				counter += 1
				var r1 = mr.registers[mr.memory[counter]]
				r1 += 1
				if r1 == 0{
					counter += 1
					counter = mr.memory[mr.memory[counter]]	
					return true
				}
				counter += 1
				return true
			case .aojnz: //32
				counter += 1
				var r1 = mr.registers[mr.memory[counter]]
				r1 -= 1
				if r1 != 0{
					counter += 1
					counter = mr.memory[mr.memory[counter]]	
					return true
				}
				counter += 1
				return true
			case .cmpir: //33
				counter += 1
				let i = mr.memory[counter]
				counter += 1
				let r1 = mr.registers[mr.memory[counter]]
				mr.compare(i, r1)
				//print("### Compare register: \(mr.compreg)")
				counter += 1
				return true
			case .cmprr: //34
				counter += 1
				let reg1 = mr.registers[mr.memory[counter]] // value at register 1
				counter += 1
				let reg2 = mr.registers[mr.memory[counter]] // value at register 2
				mr.compare(reg1, reg2)
				counter += 1
				return true
			case .cmpmr: //35
				counter += 1
				let mem = mr.memory[mr.memory[counter]]
				counter += 1
				let reg = mr.registers[mr.memory[counter]]
				mr.compare(mem,reg)
				counter += 1
				return true
			case .jmpn: //36
				counter += 1
				let t1 = mr.memory[mr.memory[counter]]
				if mr.compreg < 0 {
					counter = t1
					return true
				} 
				counter += 1
				return true
			case .jmpz: //37
				counter += 1
				let t1 = mr.memory[counter]
				if mr.compreg == 0{
					counter = t1
					return true
				}
				counter += 1
				return true
			case .jmpp: //38
				counter += 1
				let t1 = mr.memory[mr.memory[counter]]
				if mr.compreg > 0 {
					counter = t1
					return true
				} 
				counter += 1
				return true
			case .jsr: //39
				counter += 1
				retCounter = counter
				let label = mr.memory[counter]
				counter = label
				for r in 5...9 {
					//print("Pushing register \(r) onto stack")
					stack.push(mr.registers[r])
				}
			///print("jsr completed")
				return true
			case .ret: //40
				for r in 5...9 {
					if stack.isEmpty() != true {
						mr.registers[r] = stack.pop()!
					}
				}
				counter = retCounter + 1
				return true
			case .push: //41
				counter += 1
				let r = mr.registers[mr.memory[counter]]
				stack.push(mr.registers[r])
				counter += 1
				return true
			case .pop: //42
				counter += 1
				let r = mr.memory[counter]
				if stack.isEmpty() != true {
					mr.registers[r] = stack.pop()!
				}
				counter += 1
				return true
			/*case .stackc: //43
				counter += 1
				let r = mr*/
				
			case .outci: //44
				counter += 1
				print(utc(mr.memory[counter]), terminator: "")
				counter += 1
				return true
			case .outcr: //45
				counter += 1
				let temp = mr.registers[mr.memory[counter]]
				print(utc(temp), terminator: "")
				counter += 1
				return true
			case .outcx: //46
				counter += 1
				let r = mr.memory[counter]
				print(mr.memory[mr.registers[r]], terminator: "")
				counter += 1
				return true
			case .outcb: //47
				counter += 1
				let startingLoc = counter
				counter = mr.registers[mr.memory[counter]]
				let blockLength = mr.registers[mr.memory[counter]]
            	for i in startingLoc+1...blockLength+startingLoc {
            		counter += 1
            		print(mr.memory[i], terminator: "")
            	}
            	counter = startingLoc
            	counter += 1
            	return true
            case .readi: //48
            	counter += 1
            	let v = readLine()
				guard let vi = Int(v!) else {
					counter += 1
					mr.uregi(mr.memory[counter],1)
					return true
				}
				mr.uregi(mr.memory[counter],vi)
				return true
			case .printi: //49
				counter += 1
				print(mr.registers[mr.memory[counter]], terminator: "")
				counter += 1
				return true
			case .readc: //50
          		counter += 1
            	let v = readLine()
				mr.uregi(mr.memory[counter],ctu(Character(v!)))
				return true
			case .brk: //52 FOR NOW NO OPERATION, WILL CHANGE W/ DEBUGGER
				return true
			case .movrx: //53
				counter += 1
				let t1 = mr.registers[mr.memory[counter]]
				counter += 1
				let t2 = mr.registers[mr.memory[counter]]
				mr.memory[t2] = t1
				counter += 1
				return true
			case .movxx: // 54
				counter += 1
				let t1 = mr.registers[mr.memory[counter]]
				counter += 1
				let t2 = mr.registers[mr.memory[counter]]
				mr.memory[t2] = mr.memory[t1]
				counter += 1
				return true
			case .outs: //55
				counter += 1 // now at label location
				let startingLoc = counter
				let labelLoc = mr.memory[counter]
				counter = labelLoc
				let stringLength = mr.memory[labelLoc]
            	for i in labelLoc+1...stringLength+labelLoc {
            		counter += 1
            		print(utc(mr.memory[i]), terminator: "")
            	}
            	counter = startingLoc
				counter += 1
            	return true
            case .nop: //56
            	return true
			case .jmpne: //57
				counter += 1 // now at label location
				if mr.compreg != 0 { 
					counter = mr.memory[counter] 
					return true
				}
				counter += 1
				return true
			
			default: // ???
				print("\(cmd) is unknown")
				counter += 1
				return true
		}
	}
	var halting = true
	func run(){
		print("Program starting. Counter at \(counter)")
		while mr.memory[counter] != mr.numMem || halting { //only run when counter isn't at the end of the program or when halting
		//	print(mr.memory)
		//	print("### \(mr.memory[counter]) counter @ \(counter)")
			let temp = Command(rawValue: mr.memory[counter])!
		//	print("### Current command: \(temp)")
			halting = processcmd(temp)
		}
	}
}