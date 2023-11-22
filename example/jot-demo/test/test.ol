from ..main import CustomerCoreInterface
from console import Console

interface TestInterface {
RequestResponse:
    /// @Test
    testCreateCustomer1(void)(void) throws TestFailed(string),
    /// @Test
    testCreateCustomer2(void)(void) throws TestFailed(string)
}

type TestParams {
    location: string
    protocol: string
}

service TestCustomerCore( params:TestParams ) {

    outputPort SimpleCustomerCore {
        location: params.location
        protocol: params.protocol
        interfaces: CustomerCoreInterface
    }

    embed Console as Console
	execution: sequential

	inputPort Input {
		location: "local"
		interfaces: TestInterface
	}

    main {
        [ testCreateCustomer1()(){
            createCustomer@SimpleCustomerCore( { name = "Homer" surname = "Simpson" } )( response )
            if( response.id != 1 ){
                throw TestFailed("expected 1, got " + response.id)
            }
        }]
        [ testCreateCustomer2()(){
            createCustomer@SimpleCustomerCore( { name = "Homer" surname = "Simpson" } )( response )
            if( response.id != 2 ){
                throw TestFailed("expected 2, got " + response.id)
            }
        }]
    }
}