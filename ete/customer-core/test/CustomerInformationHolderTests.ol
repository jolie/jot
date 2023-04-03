from ..interfaces import CustomerInformationHolder
from ..main import CustomerCore, CustomerCoreParams
from assertions import Assertions
from console import Console

type TestParams: CustomerCoreParams

interface MyTestInterface {
RequestResponse:
	// /// @BeforeAll
	op1,
	// /// @AfterAll
	op2,

	// /// @Test
	testGetCustomers(void)(void) throws TestFailed(string),
	/// @Test
	testGetCustomer(void)(void) throws TestFailed(string),
	// /// @Test
	testUpdateCustomer(void)(void) throws TestFailed(string),
	// /// @Test
	testUpdateAddressCustomer(void)(void) throws TestFailed(string),
	// /// @Test
	testCreateCustomer(void)(void) throws TestFailed(string)
}

service TestCustomerCore( params:TestParams ) {

	embed CustomerCore( params )
	embed Assertions as assertions
	embed Console as console

	execution: sequential

	outputPort customerCore {
		location: params.location
		protocol: http {
			osc.getCustomer << {
				template = "customers/{ids}"
				method = "get"
				outHeaders.("Authorization") = ""
			}
			osc.getCustomers << {
				template = "/customers"
				method = "get"
			}
			osc.createCustomer << {
				template = "/customers"
				method = "post"
			}
			osc.updateCustomer << {
				template = "/customers/{customerId}"
				method = "put"
			}
			osc.changeAddress << {
				template = "/customers/{customerId}/address"
				method = "put"
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
		[ op1()() {
			nullProcess
			// println@console( "op1 is called" )()
		} ]
		[ op2()() {
			nullProcess
			// println@console( "op2 is called" )()
		} ]

		[ testGetCustomer()() {
			getCustomer@customerCore({ids= "zbej74yalh"})(response)
			equals@assertions( {
				actual = response.customers[0].customerId
				expected = "zbej74yalh"
			})()
		} ]

		[ testGetCustomers()() {
			getCustomers@customerCore({filter=""})(response)
			// getCustomers@customerCore({filter="Vale"})(response)
			len = #response.customers
			equals@assertions( {
				actual = len
				expected = 9
				// expected = 1
			})()
		} ]

		[ testUpdateCustomer()() {
			updateCustomer@customerCore({
				customerId = "rgpp0wkpec"
				requestDto << {
					firstName = "Dane"
					lastName = "Joe"
					birthday = "1/1/2022"
					streetAddress = "Some street"
					postalCode = "postalccc"
					city = "Some City"
					email = "a@a.com"
					phoneNumber = "01230304030"
				}
			})(actual)
			equals@assertions( {
				actual = actual
				expected << {
					birthday = "1/1/2022"
					firstName = "Dane"
					lastName = "Joe"
					phoneNumber = "01230304030"
					streetAddress = "Some street"
					city = "Some City"
					postalCode = "postalccc"
					customerId = "rgpp0wkpec"
					email = "a@a.com"
				}
			})()
		} ]

		[ testUpdateAddressCustomer()() {
			changeAddress@customerCore({
				customerId = "rgpp0wkpec"
				requestDto << {
					streetAddress = "Some street"
					postalCode = "postalccc"
					city = "Some City"
				}
			})(actual)
			equals@assertions( {
				actual = actual
				expected = {
					streetAddress = "Some street"
					postalCode = "postalccc"
					city = "Some City"
				}
			})()
		} ]

		[ testCreateCustomer()() {
			request << {
				firstName = "Jane"
				lastName = "Doe"
				birthday = "1/1/2022"
				streetAddress = "Some street"
				postalCode = "postalccc"
				city = "Some City"
				email = "a@a.com"
				phoneNumber = "01230304030"
			}
			createCustomer@customerCore(request)(actual)
			equals@assertions( {
				actual = actual
				expected = {
					firstName = "Jane"
					lastName = "Doe"
				}
			})()
		}]

	}
}