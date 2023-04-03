// from .time import Instant

///@ValueObject
type Address {
	id:long
	streetAddress:string
	postalCode:string
	city:string
}

///@ValueObject
type CustomerId:string

interface CustomerIdAPI {
RequestResponse:
	random(void)(CustomerId)
}

///@Entity
type CustomerProfile {
	firstName:string
	lastName:string
	// birthday:Instant
	birthday:string
	currentAddress:Address
	email:string
	phoneNumber:string
	moveHistory {
		address*:Address
	}
}

/*
type MoveToAddressCustomerProfileRequest {
	customerProfile:CustomerProfile
	address:Address
}

interface CustomerProfileAPI {
RequestResponse:
	moveToAddress(MoveToAddressCustomerProfileRequest)(CustomerProfile)
}
*/

///@AggregateRoot
type Customer {
	///@Identifier
	id:CustomerId
	customerProfile:CustomerProfile
}

///@ValueObject
type MoveToAddressRequest {
	customerId:CustomerId
	address:Address
}

///@ValueObject
type UpdateCustomerProfileRequest {
	customerId:CustomerId
	updatedCustomerProfile:CustomerProfile
}

interface CustomerAPI {
RequestResponse:
	moveToAddress(MoveToAddressRequest)(void),
	updateCustomerProfile(UpdateCustomerProfileRequest)(void)
}

// interface CustomerFactoryAPI {
// RequestResponse:
// 	createCustomer(CustomerProfile)(CustomerAggregate)
// 	//, formatPhoneNumber
// }

type Pair {
	key: string
	value: string
}

type MultiMap {
	entries* : Pair
}

type city: string
type postalCode: string

///@DDDService
interface CityLookupService {
RequestResponse:
	loadLookupMap(void)(MultiMap),
	getLookupMap(postalCode)(MultiMap),
	getCitiesForPostalCode(city)(MultiMap)
}