from .assertions import Assertions
from string-utils import StringUtils

interface TestInterface {
RequestResponse:
	///@Test
	testToLowerCase(void)(void) throws AssertionError(string),
	///@Test
	testLength(void)(void) throws AssertionError(string)
}

service TestStringUtils( ) {

	embed Assertions as assertions
	embed StringUtils as stringUtils
	execution: sequential

	inputPort Input {
		location: "local"
		interfaces: TestInterface
	}

	main{
		[ testToLowerCase()() {
			toLowerCase@stringUtils("AbC dEf_GhI")(result)
			equals@assertions({
				actual = result
				expected = "abc *def_ghi"
				message = "expected 'abc *def_ghi', got '" + result + "'."
			})()
		} ]		
		[ testLength()() {
			length@stringUtils("12345678")(result)
			equals@assertions({
				actual = result
				expected = 8
				message = "expected 8, got " + result + "."
			})()
		} ]
	}
}