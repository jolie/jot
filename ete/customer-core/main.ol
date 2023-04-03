from .interfaces import CustomerInformationHolder
from console import Console
from string-utils import StringUtils
from .repository import CustomerCoreRepository, RepositoryParams
from .city import CityLookupService, CityLookupServiceParams

type CustomerCoreParams {
	location: string
	repository: RepositoryParams
	cityLookupService: CityLookupServiceParams
}

service CustomerCore( params:CustomerCoreParams ) {
	embed CustomerCoreRepository(params.repository) as repository
	embed Console as console
	embed StringUtils as stringUtils
	embed CityLookupService(params.cityLookupService) as cityLookupService

	inputPort Input {
		location: params.location
		protocol: http {
			// debug = true
			// debug.showContent = true
			osc.getCustomers << {
				template = "/customers"
				method = "get"
			}
			osc.getCustomer << {
				template = "/customers/{ids}"
				method = "get"
			}
			osc.updateCustomer << {
				template = "/customers/{customerId}"
				method = "put"
			}
			osc.changeAddress << {
				template = "/customers/{customerId}/address"
				method = "put"
			}
			osc.createCustomer << {
				template = "/customers"
				method = "post"
			}
			osc.getCitiesForPostalCode << {
				template = "/cities/{postalCode}"
				method = "get"
			}
		}
		interfaces: CustomerInformationHolder
	}

	execution: concurrent

	init {
		loadLookupMap@cityLookupService()()
	}

	main {

		[getCustomers(req)(res){
			findAll@repository(req)(repo)
			if ( !is_defined(req.filter) || req.filter == "" ){
				res.filter = "-"
			} else {
				res.filter = req.filter
			}
			if (!is_defined(req.limit)){
				res.limit = 10
			}else{
				res.limit = req.limit
			}
			if (!is_defined(req.offset)){
				res.offset = 0
			}else{
				res.offset = req.offset
			}
			searchTerms << split@stringUtils(req.filter { regex = " "})
			// println@console( "searchTerms "+valueToPrettyString@stringUtils( searchTerms ))()

			filteredCustomer.result << s // create empty array
            for( customer in repo.result ) {
				// println@console( "customer "+valueToPrettyString@stringUtils( customer ))()
				if (#searchTerms.result > 0){
					for ( searchTerm in searchTerms.result ){
						// println@console( "searchTerm "+valueToPrettyString@stringUtils( searchTerm ))()
						if (contains@stringUtils(customer.firstName { substring = searchTerm }) || contains@stringUtils(customer.lastName { substring = searchTerm }) ) {
							// println@console( "Assign customer")()
							undef(customer.password)
							filteredCustomer.result[#filteredCustomer.result] << customer
						}
					}
				} else {
					undef(customer.password)
					filteredCustomer.result[#filteredCustomer.result] << customer
				}
            }
			// println@console( "filteredCustomer.result "+valueToPrettyString@stringUtils( filteredCustomer ))()
			res.size = #filteredCustomer.result
			for ( i = res.offset, i < limit || i < #filteredCustomer.result, i++ ){
				res.customers[#res.customers] << filteredCustomer.result[i]
			}
			if ( !is_defined(res.customers) ){
				res.customers << s // create empty array
			}
			// println@console( "res "+valueToPrettyString@stringUtils( res ))()
		}]

		[getCustomer(req)(res){
			// println@console( "getCustomer "+valueToPrettyString@stringUtils( res ))()
			findAllById@repository(req.ids)(repo)
            for ( customer in repo.result) {
				undef(customer.password)
                res.customers[#res.customers] << customer
            }
			if (#res.customers == 0){
				res.customers = void
			}
		}]

		[updateCustomer(req)(res){
			update << {
				customerId = req.customerId
				firstName = req.requestDto.firstName
				lastName = req.requestDto.lastName
				birthday = req.requestDto.birthday
				streetAddress = req.requestDto.streetAddress
				postalCode = req.requestDto.postalCode
				city = req.requestDto.city
				email = req.requestDto.email
				phoneNumber = req.requestDto.phoneNumber
			}

			findAllById@repository(req.customerId)(repo)

			global.moveHistory.(req.customerId)[#global.moveHistory.(req.customerId)] << {
				streetAddress = repo.result.streetAddress
				postalCode = repo.result.postalCode
				city = repo.result.city
			}
			saveAndFlush@repository(update)(repo)
			
			res << {
				customerId = repo.row.customerId
				firstName = repo.row.firstName
				lastName = repo.row.lastName
				birthday = repo.row.birthday
				streetAddress = repo.row.streetAddress
				postalCode = repo.row.postalCode
				city = repo.row.city
				email = repo.row.email
				phoneNumber = repo.row.phoneNumber
				moveHistory << { address << global.moveHistory.(req.customerId) }
			}
		}]
		

		[createCustomer(req)(res){
			insert << {
				customerId = getRandomUUID@stringUtils()
				firstName = req.firstName
				lastName = req.lastName
				birthday = req.birthday
				streetAddress = req.streetAddress
				postalCode = req.postalCode
				city = req.city
				email = req.email
				phoneNumber = req.phoneNumber
			}
			saveAndFlush@repository(insert)(repo)

			findAllById@repository(insert.customerId)(findResponse)

			res << findResponse.result
			undef(res.password)
		}]

		[changeAddress(req)(res){

			findAllById@repository(req.customerId)(repo)
			// println@console(valueToPrettyString@stringUtils( repo ))()

			global.moveHistory.(req.customerId)[#global.moveHistory.(req.customerId)] << {
				streetAddress = repo.result.streetAddress
				postalCode = repo.result.postalCode
				city = repo.result.city
			}

			update << {
				customerId = req.customerId
				firstName = repo.result.firstName
				lastName = repo.result.lastName
				birthday = repo.result.birthday
				streetAddress = req.requestDto.streetAddress
				postalCode = req.requestDto.postalCode
				city = req.requestDto.city
				email = repo.result.email
				phoneNumber = repo.result.phoneNumber
			}
			saveAndFlush@repository(update)(saveResult)
			// println@console(valueToPrettyString@stringUtils( saveResult ))()
			
			res << {
				streetAddress = saveResult.row.streetAddress
				postalCode = saveResult.row.postalCode
				city = saveResult.row.city
			}
			// println@console(valueToPrettyString@stringUtils( res ))()
		}]
		
		[getCitiesForPostalCode(req)(res){
			getLookupMap@cityLookupService(req.postalCode)(responses)

            for ( entry in responses.entries){
				res.cities[#res.cities] = entry.value
            }
		}]
	}
}
