from assertions import Assertions
from console import Console


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
	execution: sequential

	inputPort Input {
		location: "local"
		interfaces: MyTestInterface
	}
    main{
		[ op1()() {
			println@console( "op1 is called" )()
		} ]
		[ op2()() {
			println@console( "op2 is called" )()
		} ]
        
		[ testBlah()() {
            equals@assertions({
                actual = 1
                expected = 1
            })()
			println@console( "testBlah is correct!" )()
		} ]
    }
}