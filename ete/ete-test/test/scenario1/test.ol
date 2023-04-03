from customer-core.interfaces import CustomerInformationHolder as CustomerInformationHolder_CustomerCore
from customer-management.interfaces import CustomerInformationHolder as CustomerInformationHolder_CustomerManagement
from assertions import Assertions
from console import Console
from string-utils import StringUtils

interface TestInterface {
RequestResponse:

	/// @BeforeEach
	setup(void)(void),

	/// @Test
	testScenario1(void)(void) throws TestFailed(string)
}

// - interaction between CustomerManagement and CustomerCore. We check
// that we have the user in the database with getCustomers (e.g., the name
// of the user), then we get its id from the response and we update the data
// of the user via the updateCustomer operation. We check that the update
// was successful. We issue an update and we check that the operation
// succeeded

service Main {
	embed Assertions as assertions
	embed Console as console
	embed StringUtils as su

	execution: sequential

	outputPort customerCore {
		location: "socket://customer-core:8080"
		protocol: http {
			osc.createCustomer << {
				template = "/customers"
				method = "post"
			}
			format = "json"
		}
		interfaces: CustomerInformationHolder_CustomerCore
	}

	outputPort customerManagement {
		location: "socket://customer-management:8080"
		protocol: http {
			osc.getCustomers << {
				template = "/customers"
				method = "get"
			}
			osc.updateCustomer << {
				template = "/customers/{customerId}"
				method = "put"
			}
		}
		interfaces: CustomerInformationHolder_CustomerManagement
	}

	inputPort Input {
		location: "local"
		interfaces: TestInterface
	}

	main {

		[ setup()() {
			request << {
				firstName = "Jane"
				lastName = "Doe"
				birthday = "1/1/2022"
				streetAddress = "Some street"
				postalCode = "12123"
				city = "Some City"
				email = "a@a.com"
				phoneNumber = "01230304030"
			}
			createCustomer@customerCore(request)(actual)
			global.user_id = actual.customerId
		} ]

		[ testScenario1()() {
			
			getCustomer@customerManagement( { ids = global.user_id } )( responseGetCustomer )
			equals@assertions( {
				actual << responseGetCustomer.customerId
				expected << global.user_id
			} )()

			undef(responseGetCustomer.customerId)
			responseGetCustomer.firstName = "John2"
			// update
			updateCustomer@customerManagement( { 
				customerId = global.user_id
				requestDto << responseGetCustomer
			} )( responseUpdateCustomer )
			equals@assertions( {
				actual = responseUpdateCustomer.firstName
				expected = "John2"
			} )()

			
			getCustomers@customerManagement( { filter="John2" } )( responseGetCustomers )
			equals@assertions( {
				actual = #responseGetCustomers.customers
				expected = 1
			} )()
		} ]
	}
}
