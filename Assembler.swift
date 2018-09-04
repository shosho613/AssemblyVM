import Foundation

class Assembler {
	var file = [String]()
	var previousDirective = ""
	var arguments = ""
	var argumentCharacters = [String]()
	var argumentCounter = 0
	var symbolTable = [String : Int]()
	var numberErrors = 0
	enum TokenType {
		case Register
		case LabelDefinition
		case Label
		case ImmediateString
		case ImmediateInteger
		case ImmediateTuple
		case Instruction
		case Directive
		case BadToken
	}
	
	struct Token : CustomStringConvertible {
		let type: TokenType
		let intValue: Int?
		let stringValue: String?
		let tupleValue: Tuple?
		var description: String {
			if type == .Register {
				return "\(type): r\(intValue!)"
			}
			if type == .Label || type == .LabelDefinition || type == .ImmediateString || type == .BadToken || type == .Instruction || type == .Directive {
				return "\(type): \(stringValue!)"
			}
			if type == .ImmediateInteger {
				return "\(type): #\(intValue!)"
			}
			if type == .ImmediateTuple {
				return "\(type): /\(tupleValue!)/"
			}
			return "\(type)"
		}
	}
	
	enum Command : Int { //ordered so each case has the correct rawValue
		case halt,clrr,clrx,clrm,clrb,movir,movrr,movrm,movmr,movxr,movar,movb,addir,addrr,addmr,addxr,subir,subrr,submr,subxr,mulir,mulrr,mulmr,mulxr,divir,divrr,divmr,divxr,jmp,sojz,sojnz,aojz,aojnz,cmpir,cmprr,cmpmr,jmpn,jmpz,jmpp,jsr,ret,push,pop,stackc,outci,outcr,outcx,outcb,readi,printi,readc,readln,brk,movrx,movxx,outs,nop,jmpne
	}
	
	let commandargs: [String: String] = [ //r = register, l = label, i = immediate (integer)
		"halt" : "",
		"clrr" : "r",
		"clrx" : "r",
		"clrm" : "l",
		"clrb" : "rr",
		"movir" : "ir",
		"movrr" : "rr",
		"movrm" : "rl",
		"movmr" : "lr",
		"movxr" : "rr",
		"movar" : "lr",
		"movb" : "rrr",
		"addir" : "ir",
		"addrr" : "rr",
		"addmr" : "lr",
		"addxr" : "rr",
		"subir" : "ir",
		"subrr" : "rr",
		"submr" : "lr",
		"subxr" : "rr",
		"mulir" : "ir",
		"mulrr" : "rr",
		"muxmr" : "lr",
		"mulxr" : "rr",
		"divir" : "ir",
		"divrr" : "rr",
		"divmr" : "lr",
		"divxr" : "rr",
		"jmp" : "l",
		"sojz" : "rl",
		"sojnz" : "rl",
		"aojz" : "rl",
		"aojnz" : "rl",
		"cmpir" : "ir",
		"cmprr" : "rr",
		"cmpmr" : "lr",
		"jmpn" : "l",
		"jmpz" : "l",
		"jmpp" : "l",
		"jsr" : "l",
		"ret" : "",
		"push" : "r",
		"pop" : "r",
		"stackc" : "r",
		"outci" : "i",
		"outcr" : "r",
		"outcx" : "r",
		"outcb" : "rr",
		"readi" : "rr",
		"printi" : "r",
		"readc" : "r",
		"readln": "lr",
		"brk" : "",
		"movrx" : "rr",
		"movxx" : "rr",
		"outs" : "l",
		"nop" : "",
		"jmpne" : "l"
	]
	
	let registers = ["r0", "r1", "r2", "r3", "r4", "r5", "r6", "r7", "r8", "r9"]
	
let Instructions: [String: Int] = [ //name of instruction, number 
		"halt" : 0,
		"clrr" : 1,
		"clrx" : 2,
		"clrm" : 3,
		"clrb" : 4,
		"movir" : 5,
		"movrr" : 6,
		"movrm" : 7,
		"movmr" : 8,
		"movxr" : 9,
		"movar" : 10,
		"movb" : 11,
		"addir" : 12,
		"addrr" : 13,
		"addmr" : 14,
		"addxr" : 15,
		"subir" : 16,
		"subrr" : 17,
		"submr" : 18,
		"subxr" : 19,
		"mulir" : 20,
		"mulrr" : 21,
		"muxmr" : 22,
		"mulxr" : 23,
		"divir" : 24,
		"divrr" : 25,
		"divmr" : 26,
		"divxr" : 27,
		"jmp" : 28,
		"sojz" : 29,
		"sojnz" : 30,
		"aojz" : 31,
		"aojnz" : 32,
		"cmpir" : 33,
		"cmprr" : 34,
		"cmpmr" : 35,
		"jmpn" : 36,
		"jmpz" : 37,
		"jmpp" : 38,
		"jsr" : 39,
		"ret" : 40,
		"push" : 41,
		"pop" : 42,
		"stackc" : 43,
		"outci" : 44,
		"outcr" : 45,
		"outcx" : 46,
		"outcb" : 47,
		"readi" : 48,
		"printi" : 49,
		"readc" : 50,
		"readln": 51,
		"brk" : 52,
		"movrx" : 53,
		"movxx" : 54,
		"outs" : 55,
		"nop" : 56,
		"jmpne" : 57
	]
	
	struct Tuple: CustomStringConvertible{
		let cs: Int
		let ic: Character
		let ns: Int
		let oc: Character
		let dir: Character
		
		var description: String{
			return "\(cs) \(ic) \(ns) \(oc) \(dir)"
		}
	}
	
	func ssil(_ expression: String) -> [String]{ //split string into lines
		return expression.characters.split{$0 == "\n" || $0 == "\r"}.map{String($0)}
	}
	func ssip(_ expression: String) -> [String]{ //split String into parts
		return expression.characters.split{$0 == " " }.map{String($0)}
	}
	func ssic(_ expression: String) -> [String]{ //split string in chars
		return expression.characters.map{String($0)}
	}
	func ctu(_ c: Character) -> Int{ //char to unicode
		let s = String(c)
		return Int(s.unicodeScalars[s.unicodeScalars.startIndex].value)
	}
	func satu(_ s: [String]) -> [Int] { //string array to unicode
		var results = [Int]()
		for letter in s {
			results.append(Int(letter.unicodeScalars[letter.unicodeScalars.startIndex].value))
		}
		return results
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

    
	init(program : String){
	   file = ssil(rtf(program).1!)
	}	
	
	func getAllTokens() -> [Token] {
		var chunks = [String]()
		var tokens = [Token]()
		for line in 0..<file.count {
			let chunksInLine = chunker(file[line])
			for c in chunksInLine {
				chunks.append(c)
			}
		}
		chunks = chunks.filter { $0 != "" }
		for i in 0..<chunks.count {
			tokens.append(tokenize(chunks[i]))
		}
		return tokens
	}
	
	func chunker(_ line: String) -> [String]{
	//	let legalChars : Set = ["a","b","c", "d","e", "f", "g" "h", "i", "j", "k", "l", "m", "n", "o","p","q","r","s","t","u", "v", "w","x","y","z","A","B","C","D","E","F", "G", "H","I", "J","K","L","M","N","O", "P", "Q","R", "S", "T", "U", "V","W", "X", "Y", "Z", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
		var contents = ssic(line)
		var result = [String]()
		var inString = false
		var inTuple = false
		var inComment = false
	//	var inWord = true
		var currentEntry: String = ""
		for i in 0..<contents.count{
			switch contents[i] {
				case "\"" :
					if inComment == false{
					if inString == false{
						inString = true
						currentEntry += contents[i]
					} else{
						inString = false
						currentEntry += contents[i]
						result.append(currentEntry)
						currentEntry = ""
					}
					}
					 
				
				case "/":
					if inComment == false{
					if inTuple == false{
						inTuple = true
						currentEntry += contents[i]
					} else{
						inTuple = false
						currentEntry += contents[i]
						result.append(currentEntry)
						currentEntry = ""
					}
					}
					
				case " " :
					if inComment == false{
					if inString == false && inTuple == false{
						result.append(currentEntry)
							currentEntry = ""
					} else{
						currentEntry += contents[i]
						if i == contents.count - 1{
							result.append(currentEntry)
							
						}
					}
					}
					
				case ";":
					if inString == false && inTuple == false {
						inComment = true
					}
					else {
						currentEntry += contents[i]
					}
				
				default:
					currentEntry += contents[i]	
				
				
			}
		}
		if inString == false && inTuple == false && inComment == false {
				result.append(currentEntry)
			}
		if result.isEmpty{
			return result
		} else{
		for i in 0..<result.count - 1{
			if result[i] == ""{
				result.remove(at: i)
			}
		}
		return result
		
		}
		}
		
		





	func tokenize(_ s: String) -> Token {
		var array : [String] = ssic(s)
		let directions : Set = ["r", "l", "R", "L"]
		if array[array.count - 1] == ":" { //LabelDefinition
			array.remove(at: array.count - 1)
			let label = array.joined()
			return Token(type: .LabelDefinition, intValue: nil, stringValue: label, tupleValue: nil)
		}
		if registers.contains(s) { //Register
			if ssic(arguments)[argumentCounter] != "r" {
				if argumentCounter - 1 != arguments.characters.count {
					argumentCounter += 1
				}
				return Token(type: .BadToken, intValue: nil, stringValue: "Found unexpected register", tupleValue: nil)
			}
			if argumentCounter - 1 != arguments.characters.count {
				argumentCounter += 1
			}
			return Token(type: .Register, intValue: registers.index(of: s), stringValue: nil, tupleValue: nil)
		}
		if commandargs[s] != nil { //Instruction
			arguments = commandargs[s]!
			argumentCounter = 0
			return Token(type: .Instruction, intValue: nil, stringValue: s, tupleValue: nil)
		}
		if array[0] == "#" { //ImmediateInteger
			array.remove(at: 0)
			if previousDirective == "integer" || ssic(arguments)[argumentCounter] == "i" {
				if argumentCounter - 1 != arguments.characters.count {
					argumentCounter += 1
				}
				return Token(type: .ImmediateInteger, intValue: Int(array.joined()), stringValue: nil, tupleValue: nil)
			}
			guard let _ = Int(array.joined()) else {
				return Token(type: .BadToken, intValue: nil, stringValue: "Expected integer", tupleValue: nil)
			}
			if argumentCounter - 1 != arguments.characters.count {
				argumentCounter += 1
			}
			return Token(type: .BadToken, intValue: nil, stringValue: "Found unexpected integer", tupleValue: nil)
		}
		if array[0] == "\"" && array[array.count - 1] == "\"" { //ImmediateString
			if previousDirective != "string" {
				return Token(type: .BadToken, intValue: nil, stringValue: "Expected string", tupleValue: nil)
			}
			array.remove(at: 0)
			array.remove(at: array.count - 1)
			return Token(type: .ImmediateString, intValue: nil, stringValue: array.joined(), tupleValue: nil)
		}
		if array[0] == "/" && array[array.count - 1] == "/" { //ImmediateTuple
			if previousDirective != "tuple" {
				return Token(type: .BadToken, intValue: nil, stringValue: "Expected tuple", tupleValue: nil)
			}
			array.remove(at: 0)
			array.remove(at: array.count - 1)
			let dir = Character(array[8])
			guard let cs = Int(array[0]), let ns = Int(array[4]), directions.contains(String(dir)) else {
				return Token(type: .BadToken, intValue: nil, stringValue: s, tupleValue: nil)
			}
			return Token(type: .ImmediateTuple, intValue: nil, stringValue: nil, tupleValue: Tuple(cs: cs, ic: Character(array[2]), ns: ns, oc: Character(array[6]), dir: dir))
		}
		if array[0] == "." { //Directive
			array.remove(at: 0)
			let d = array.joined().lowercased()
			if d == "start" || d == "integer" || d == "tuple" || d == "string" {
				previousDirective = d
				return Token(type: .Directive, intValue: nil, stringValue: d, tupleValue: nil)
			}
			return Token(type: .BadToken, intValue: nil, stringValue: d, tupleValue: nil)
		}
		if commandargs[s] == nil { //Label
			let label = array.joined()
			if previousDirective == "start" {
				return Token(type: .Label, intValue: nil, stringValue: label, tupleValue: nil)
			}
			if ssic(arguments)[argumentCounter] != "l" {
				if argumentCounter - 1 != arguments.characters.count {
					argumentCounter += 1
				}
				return Token(type: .BadToken, intValue: nil, stringValue: "Found unexpected label", tupleValue: nil)
			}
			if argumentCounter - 1 != ssic(arguments).count {
				argumentCounter += 1
			}
			return Token(type: .Label, intValue: nil, stringValue: label, tupleValue: nil)
		}
		return Token(type: .BadToken, intValue: nil, stringValue: s, tupleValue: nil)
	}
	
	func assemble() -> [Int?] {
		let tokens = getAllTokens()
		var output = [Int?]()
		var symbols = [String : Int]()
		var unfilledLabels = [Int : String]() //string = label we wanted to insert, int = location where we wanted to insert it
		var badTokens = [0]
		for token in tokens {
			if token.type == .ImmediateString || token.type == .ImmediateTuple {
				var chars = [Int]()
				if token.type == .ImmediateTuple {
					chars.append(token.tupleValue!.cs)
					chars.append(ctu(token.tupleValue!.ic))
					chars.append(token.tupleValue!.ns)
					chars.append(ctu(token.tupleValue!.oc))
					if token.tupleValue!.dir == "r" {
						chars.append(1)
					}
					else {
						chars.append(0)
					}
				}
				else {
					chars = satu(ssic(token.stringValue!))
					output.append(chars.count)
				}
				for c in chars {
					output.append(c)
				}
			}
			if token.type == .ImmediateInteger {
				output.append(token.intValue!)
			}
			if token.type == .LabelDefinition {
				symbols[token.stringValue!] = output.count - 1 //location in program thus far
			}
			if token.type == .Directive { //does this do anything to program?
				if token.stringValue == "start" { 
				//	isStartingLabel = true second path stuff
					
				} // needed to know for the second val for where the prog starts.
			}
			if token.type == .Label {
				if symbols[token.stringValue!] == nil { //location not yet known
					output.append(nil) //temporary written location, to be updated
					unfilledLabels[output.count - 1] = token.stringValue!
				}
				else {
					output.append(symbols[token.stringValue!]!)
				}
			}
			if token.type == .Instruction {
				let instructionName = token.stringValue!
				let value = Instructions[instructionName]
				output.append(value)
			}
			
			if token.type == .Register {
				output.append(token.intValue!)
			}
			if token.type == .BadToken {
				badTokens[0] += 1
			}
		}
		if badTokens[0] > 0 {
			numberErrors = badTokens.count
			return badTokens
		}
		for i in 0..<output.count{
			if output[i] == nil {
				output[i] = symbols[unfilledLabels[i]!]
			}
		}
		output.insert(output.count, at: 0)
		symbolTable = symbols
		return output
	}

func listing()-> String{
		var memoryCounter = 0
		var result = ""
		let assembledProg = assemble()
		let tokens = getAllTokens()
		var isError = false
		for token in tokens{
			if token.type == .BadToken{
				isError = true
			}
		}
		if isError == false{
			for i in file{
				result += i
				result += "\n"
				let temp = chunker(i)
				for t in temp{
					let token = tokenize(t)
					if token.type == .BadToken{
						result += "..........\(token.stringValue!)"
						result += "\n"
					}
				}
			}
		}
		/*if isError = false{
		let temp = assembledProg.map{$0!}	
			
		}*/
	return result
	}
}