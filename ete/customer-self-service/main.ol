from ..customer-core.interfaces import CustomerInformationHolder as CustomerCoreCustomerInformationHolder
from .interfaces import CustomerInformationHolder 
from console import Console
from string-utils import StringUtils

type CustomerSelfServiceParams {
	location: string
	customerCoreLocation: string
}

service CustomerSelfService( params: CustomerSelfServiceParams ) {

	embed Console as console
	embed StringUtils as stringUtils
	execution: concurrent

	outputPort customerCore {
		location: params.customerCoreLocation
		protocol: http {
			osc.getCustomer << {
				template = "/customers/{ids}"
				method = "get"
			}
			osc.createCustomer << {
				template = "/customers"
				method = "post"
			}
		}
		interfaces: CustomerCoreCustomerInformationHolder
	}

	inputPort Input {
		location: params.location
		protocol: http {
			osc.getCustomer << {
				template = "/customers/{customerId}"
				method = "get"
           		statusCodes.CustomerNotFound = 404
			}
			osc.registerCustomer << {
				template = "/customers"
				method = "post"
			}
		}
		interfaces: CustomerInformationHolder
	}

	main {
		[getCustomer( request )( response ) {
			scope ( getCustomer ){
				getCustomer@customerCore( {ids = request.customerId} )( customerCoreResponse )
				if (#customerCoreResponse.customers > 0 && customerCoreResponse.customers.customerId != ""){
					response << customerCoreResponse.customers[0]
				} else {
					throw( CustomerNotFound )
				}
			}
		}]
		[registerCustomer( request )( response ) {
			createCustomer@customerCore( request )( response )
		}]
	}
}