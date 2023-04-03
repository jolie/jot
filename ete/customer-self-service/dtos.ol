
type Email:string(regex(".*@.*\\..*"))
type PhoneNumber:string//(regex(???))

type Address {
	streetAddress:string
	postalCode:string
	city:string
}

type CustomerRegistrationRequest {
	firstName:string
	lastName:string
	birthday:string
	streetAddress:string
	postalCode:string
	city:string
	email:Email
	phoneNumber:PhoneNumber
}

type CustomerResponse {
	customerId? :string
	firstName? :string
	lastName? :string
	birthday? :string
	streetAddress? :string
	postalCode? :string
	city? :string
	email? :Email
	phoneNumber? :PhoneNumber
	moveHistory? {
		address*:Address
	}
}