from assertions import Assertions
from console import Console
from string-utils import StringUtils

type params {
	name: string
}

interface MyTestInterface {
RequestResponse:
	///@BeforeAll
	op1,
	///@AfterAll
	op2,

	///@Test
	testBlah(void)(void) throws TestFailed(string),
	///@Test
	testParams(void)(void) throws TestFailed(string)
}

service main( p : params ) {

	embed Assertions as assertions
	embed Console as console
	embed StringUtils as stringUtils
	execution: sequential

	inputPort Input {
		location: "local"
		interfaces: MyTestInterface
	}

    main{
		[ op1()() {
			nullProcess
			// println@console( "op1 is called" )()
		} ]
		
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
					actual = 2
					expected = 2
				})()
			}
		} ]
        
		[ testParams()() {
			scope(test){
				install( default => 
					throw( TestFailed, "sss" )
				)
				equals@assertions({
					actual = p.name
					expected = "sss"
				})()
			}
		} ]
    }
}