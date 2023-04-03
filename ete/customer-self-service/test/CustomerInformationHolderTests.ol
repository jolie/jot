from ..interfaces import CustomerInformationHolder
from ..main import CustomerSelfService, CustomerSelfServiceParams
from assertions import Assertions
from console import Console

type TestParams: CustomerSelfServiceParams

interface MyTestInterface {
RequestResponse:

	/// @Test
	testGetCustomer(void)(void) throws TestFailed(string),
	/// @Test
	testRegisterCustomer(void)(void) throws TestFailed(string),
}

service TestCustomerSelfService( params:TestParams ) {

	embed CustomerSelfService( params )
	embed Assertions as assertions
	embed Console as console

	execution: sequential

	outputPort CustomerSelfService {
		location: params.location
		protocol: http {
			osc.getCustomer << {
				template = "/customers/{customerId}"
				method = "get"
				statusCodes.CustomerNotFound = 404
			}
			osc.registerCustomer << {
				template = "/customers"
				method = "post"
			}
			format = "json"
		}
		interfaces: CustomerInformationHolder
	}

	inputPort Input {
		location: "local"
		interfaces: MyTestInterface
	}

	main {

		[ testGetCustomer()() {
			getCustomer@CustomerSelfService( { customerId = "zbej74yalh" } )(response)
			equals@assertions( {
				actual = response.customerId
				expected = "zbej74yalh"
			})()
		} ]

		[ testRegisterCustomer()() {
			registerCustomer@CustomerSelfService({
                firstName = "John"
                lastName = "Doe"
                birthday = "2/1/2022"
                streetAddress = "Some street"
                postalCode = "code123"
                city = "Some City"
                email = "a@a.com"
                phoneNumber = "01230304030"
            })(response)
			equals@assertions( {
				actual = response.firstName
				expected = "John"
			})()
		} ]

	}
}