from assertions import Assertions
from console import Console
from string-utils import StringUtils

interface MyTestInterface {
RequestResponse:
	///@BeforeAll
	op1,
	///@AfterAll
	op2,

	///@Test
	testBlah(void)(void) throws TestFailed(string)
}

service main( ) {

	embed Assertions as assertions
	embed Console as console
	embed StringUtils as stringUtils
	execution: sequential

	inputPort Input {
		location: "local"
		interfaces: MyTestInterface
	}
    main{
		// [ op1()() {
		// 	nullProcess
		// 	// println@console( "op1 is called" )()
		// } ]
		
		[ op2()() {
			nullProcess
			// println@console( "op2 is called" )()
		} ]
        
		[ testBlah()() {
			scope(test){
				install( default => 
					throw( TestFailed, "expected 2" )
				)
				equals@assertions({
					actual = 1
					expected = 2
				})()
			}
		} ]
    }
}