// @file app.d
// For general code coverage: 
//  dub -b cov
// For coverage in our test suite:
//  dub -b unittest-cov
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
