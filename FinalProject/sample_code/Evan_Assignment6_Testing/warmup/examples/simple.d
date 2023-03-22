// @file simple.d
// For general code coverage: 
//      dmd  -cov simple.d -of=prog  && ./prog
// For coverage in our test suite:
//      rdmd -unittest -cov simple.d
import std.stdio;

// Function always returns one
int functionOne(){
    writeln("functionOne was called");
    return 1;
}

// unittest for func()
unittest{
    assert(functionOne()==1);
}

void main(){

    for(int i=0; i < 10; i++){
        if(i==0){
            functionOne();
        }
    }

}
