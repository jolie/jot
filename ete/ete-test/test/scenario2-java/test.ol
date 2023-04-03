from .....assertions import Assertions
from console import Console
from string-utils import StringUtils

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

interface CustomerInformationHolder_CustomerManagement {
RequestResponse:
	getCustomers(GetCustomersRequest)(undefined),
}

interface CustomerInformationHolder_CustomerSelfService {
RequestResponse:
	registerCustomer(CreateCustomerRequest)(undefined)
}

interface TestInterface {
RequestResponse:
	/// @Test
	testScenario2(void)(void) throws TestFailed(string)
}

// - interaction between CustomerSelf-Service, CustomerManagement, and
// CustomerCore. We register a new user and use CustomerManagement to
// check that the registration successfully saved the data of the registered
// user.

service Main {
	embed Assertions as assertions
	embed Console as console
	embed StringUtils as su

	execution: sequential

	outputPort customerManagement {
		location: "socket://localhost:8100"
		protocol: http {
			osc.getCustomers << {
				template = "customers"
				method = "get"
				outHeaders.("Authorization") = "authorizationHeader"
			}
			format = "json"
		}
		interfaces: CustomerInformationHolder_CustomerManagement
	}

	outputPort customerSelfService {
		location: "socket://localhost:8080"
		protocol: http {
			osc.registerCustomer << {
				template = "customers"
				method = "post"
				outHeaders.("Authorization") = "authorizationHeader"
			}
			format = "json"
		}
		interfaces: CustomerInformationHolder_CustomerSelfService
	}

	inputPort Input {
		location: "local"
		interfaces: TestInterface
	}

	main {

		[ testScenario2()() {
			registerRequest << {
				firstname = "Homer3"
				lastname = "Simpson"
				birthday = "1956-12-05"
				streetAddress = "742 Evergreen Terrace"
				postalCode = "89011"
				city = "Some City"
				email = "h@simpson.com"
				phoneNumber = "01230304030"
				authorizationHeader = "Bearer b318ad736c6c844b"
			}
			registerCustomer@customerSelfService(registerRequest)(createSelfServiceResponse)
			equals@assertions( {
				actual = createSelfServiceResponse.firstName
				expected = "Homer3"
			} )()

			
			getCustomers@customerManagement( { filter = "Homer3", authorizationHeader = "Bearer 9b93ebe19e16bbbd" } )( responseGetCustomers )
			equals@assertions( {
				actual = #responseGetCustomers.customers
				expected = 1
			} )()
			
			equals@assertions( {
				actual = responseGetCustomers.customers.firstName
				expected = "Homer2"
			} )()
		} ]
	}
}
