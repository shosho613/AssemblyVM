class MemReg {
    var registers = [Int](repeating: 0, count: 10)
    var memory = [Int](repeating: 0, count: 2000)
    var compreg = 0
    var numMem: Int = 0
    func uregi(_ r: Int, _ v: Int) { //update register with integer
        registers[r] = v
    }
    func urega(_ r: Int, _ v: Int) { //add v to register
        registers[r] += v
    }
    func umemi(_ r: Int, _ v: Int) { //update memory with integer
        memory[r] = v
    }
    func uregr(_ i: Int, _ ii: Int) { //copy register[i] -> register[ii] 
        registers[ii] = registers[i]
    }
    func uregm(_ r: Int, _ v: Int) { //multiply register by integer
       registers[r] *= v
       
    }
    func uregd(_ r: Int, _ v: Int) { //divide register by integer
        registers[r] /= v
    }
    func compare(_ v1: Int, _ v2: Int) { //compare v1 - v2 -> deposit result in compreg
        compreg = v1 - v2
    } 
    func loadProgram(_ program: [Int]) {
        numMem = program[0]
        memory = program
        memory.remove(at: 0)
        memory.remove(at: 0)
    }



}