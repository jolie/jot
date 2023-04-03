from ..dtos import CustomersResponse
from assertions import Assertions
from console import Console


type GetCustomerRequest {
	ids:string
	fields?:string
    authorizationHeader: string
}

interface CustomerInformationHolder {
RequestResponse:
	getCustomer(GetCustomerRequest)(undefined)
}
interface MyTestInterface {
RequestResponse:
	// /// @Test
	testGetCustomer(void)(void) throws TestFailed(string),
}

service TestCustomerCore() {

	// embed CustomerCore( params )
	embed Assertions as assertions
	embed Console as console

	execution: sequential

	outputPort customerCore {
		location: "socket://localhost:8110"
		protocol: http {
			osc.getCustomer << {
				template = "customers/{ids}"
				method = "get"
				outHeaders.("Authorization") = "authorizationHeader"
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
			getCustomer@customerCore({ids= "zbej74yalh", authorizationHeader = "Bearer b318ad736c6c844b"})(response)
			println@console(response)()
			equals@assertions( {
				actual = response.customers[0].customerId
				expected = "zbej74yalh"
			})()
		} ]

	}
}