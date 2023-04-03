from .dtos import CustomerRegistrationRequest, CustomerResponse

type GetCustomerRequest {
	customerId : string
}

interface CustomerInformationHolder {
RequestResponse:
	getCustomer( GetCustomerRequest )( CustomerResponse ),
	registerCustomer( CustomerRegistrationRequest )( CustomerResponse )  
}
