from .dtos import CustomerResponse, CustomerProfileUpdateRequest, CustomerId, PaginatedCustomerResponse

type GetCustomerRequest {
	ids:string
	fields?:string
}

type GetCustomersRequest {
	filter?:string //< default: ""
	limit?:int //< default: 10
	offset?:int //< default: 0
	fields?:string //< default: ""
}

type UpdateCustomerRequest {
	customerId:CustomerId
	requestDto:CustomerProfileUpdateRequest
}

interface CustomerInformationHolder {
RequestResponse:
	getCustomer( GetCustomerRequest )( CustomerResponse ) throws CustomerNotFound,
	getCustomers( GetCustomersRequest )( PaginatedCustomerResponse ),
	updateCustomer( UpdateCustomerRequest )( CustomerResponse )  
}
