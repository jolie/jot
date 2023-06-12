from ..main import CustomerCoreInterface
from console import Console

interface MyTestInterface {
RequestResponse:
	/// @Test
	testCreateCustomer(void)(void) throws TestFailed(string)
}

type TestParams {
    location: string
}

service TestSimpleCustomerCore( params:TestParams ) {

    outputPort SimpleCustomerCore {
        location: params.location
        protocol: sodep
        interfaces: CustomerCoreInterface
    }

    embed Console as Console
	execution: sequential

	inputPort Input {
		location: "local"
		interfaces: MyTestInterface
	}

    main {
        [ testCreateCustomer()(){
            createCustomer@SimpleCustomerCore( { name = "Max" surname = "Mustermann" } )( response )
            if( response.id != 1 ){
                throw TestFailed("expected 1, got " + response.id)
            }
        }]
    }
}