from .....assertions import Assertions
from console import Console
from string-utils import StringUtils

type GetCustomerRequest {
	ids:string
	fields?:string
	authorizationHeader: string
}

type GetCustomersRequest {
	filter?:string //< default: ""
	limit?:int //< default: 10
	offset?:int //< default: 0
	fields?:string //< default: ""
	authorizationHeader: string
}

type CreateCustomerRequest {
	firstname:string
	lastname:string
	birthday:string
	streetAddress:string
	postalCode:string
	city:string
	email:string
	phoneNumber:string
	authorizationHeader: string
}

type UpdateCustomerRequest {
	authorizationHeader: string
	customerId:string
	firstname:string
	lastname:string
	birthday:string
	streetAddress:string
	postalCode:string
	city:string
	email:string
	phoneNumber:string
}

interface CustomerInformationHolder_CustomerCore {
RequestResponse:
	createCustomer(CreateCustomerRequest)(undefined)
}
interface CustomerInformationHolder_CustomerManagement {
RequestResponse:
	getCustomer(GetCustomerRequest)(undefined),
	getCustomers(GetCustomersRequest)(undefined),
	updateCustomer(UpdateCustomerRequest)(undefined)
}

interface TestInterface {
RequestResponse:

	/// @BeforeAll
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
		location: "socket://localhost:8110"
		protocol: http {
			osc.createCustomer << {
				template = "customers"
				method = "post"
				outHeaders.("Authorization") = "authorizationHeader"
			}
			format = "json"
		}
		interfaces: CustomerInformationHolder_CustomerCore
	}

	outputPort customerManagement {
		location: "socket://localhost:8100"
		protocol: http {
			osc.getCustomers << {
				template = "customers"
				method = "get"
				outHeaders.("Authorization") = "authorizationHeader"
			}
			osc.getCustomer << {
				template = "customers/{ids}"
				method = "get"
				outHeaders.("Authorization") = "authorizationHeader"
			}
			osc.updateCustomer << {
				template = "customers/{customerId}"
				method = "put"
				outHeaders.("Authorization") = "authorizationHeader"
			}
			format = "json"
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
				firstname = "Jane"
				lastname = "Doe"
				birthday = "2022-01-01"
				streetAddress = "Some street"
				postalCode = "12123"
				city = "Some City"
				email = "a@a.com"
				phoneNumber = "055 222 41 11"
				authorizationHeader = "Bearer b318ad736c6c844b"
			}
			createCustomer@customerCore(request)(actual)
			global.user_id = actual.customerId
		} ]

		[ testScenario1()() {
			
			getCustomer@customerManagement( { ids = global.user_id, authorizationHeader = "Bearer 9b93ebe19e16bbbd" } )( responseGetCustomer )
			equals@assertions( {
				actual << responseGetCustomer.customerId
				expected << global.user_id
			} )()

			// update
			updateCustomer@customerManagement( { 
				customerId = global.user_id
				firstname = "John2"
				lastname = "Doe"
				birthday = "2022-01-01"
				streetAddress = "Some street"
				postalCode = "12123"
				city = "Some City"
				email = "a@a.com"
				phoneNumber = "055 222 41 11"
				authorizationHeader = "Bearer 9b93ebe19e16bbbd"
			} )( responseUpdateCustomer )
			equals@assertions( {
				actual = responseUpdateCustomer.firstName
				expected = "John2"
			} )()
			
			getCustomers@customerManagement( { filter="John2", authorizationHeader = "Bearer 9b93ebe19e16bbbd" } )( responseGetCustomers )
			equals@assertions( {
				actual = #responseGetCustomers.customers
				expected = 1
			} )()
		} ]
	}
}
