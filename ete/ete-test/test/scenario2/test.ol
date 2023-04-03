

from customer-core.interfaces import CustomerInformationHolder as CustomerInformationHolder_CustomerCore
from customer-management.interfaces import CustomerInformationHolder as CustomerInformationHolder_CustomerManagement
from customer-self-service.interfaces import CustomerInformationHolder as CustomerInformationHolder_CustomerSelfService
from assertions import Assertions
from console import Console
from string-utils import StringUtils

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
		location: "socket://customer-management:8080"
		protocol: http {
			osc.getCustomers << {
				template = "/customers"
				method = "get"
			}
		}
		interfaces: CustomerInformationHolder_CustomerManagement
	}

	outputPort customerSelfService {
		location: "socket://customer-self-service:8080"
		protocol: http {
			osc.registerCustomer << {
				template = "/customers"
				method = "post"
			}
		}
		interfaces: CustomerInformationHolder_CustomerSelfService
	}

	inputPort Input {
		location: "local"
		interfaces: TestInterface
	}

	main {

		[ testScenario2()() {
			customer << {
				firstName = "Homer2"
				lastName = "Simpson"
				birthday = "12/05/1956"
				streetAddress = "742 Evergreen Terrace"
				postalCode = "89011"
				city = "Some City"
				email = "h@simpson.com"
				phoneNumber = "01230304030"
			}
			registerCustomer@customerSelfService(customer)(createSelfServiceResponse)
			equals@assertions( {
				actual = createSelfServiceResponse.firstName
				expected = "Homer2"
			} )()

			
			getCustomers@customerManagement( { filter = "Homer2" } )( responseGetCustomers )
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
