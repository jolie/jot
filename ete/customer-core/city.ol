from .domain import CityLookupService as CityLookupServiceInterface
from file import File
from string-utils import StringUtils
from console import Console
type CityLookupServiceParams {
	csvLocation: string
}

service CityLookupService( params:CityLookupServiceParams ) {

	embed File as File
	embed StringUtils as stringUtils
	embed Console as Console

	inputPort Input {
		location: "local"
		protocol: http {
			osc.getCitiesForPostalCode << {
				template = "/cities/{postalCode}"
				method = "get"
			}
		}
		interfaces: CityLookupServiceInterface
	}

	execution: concurrent

	main {

		[ loadLookupMap(req)(res){
			if (!is_defined(global.cities)){
				readFile@File( {
					filename= params.csvLocation
				} )( response )
				responseByLine << split@stringUtils(response { regex = "\n"})
				isFirst = true
				for ( line in responseByLine.result ){
					separated << split@stringUtils(line { regex = ";"})
					if ( !isFirst ) {
						global.cities.entries[#global.cities.entries] << {key = separated.result[0], value = separated.result[1]}
					}
					isFirst = false
				}
			}
			// println@Console(valueToPrettyString@stringUtils(global.cities))()
			res << global.cities
			// println@Console("loaded " + #global.cities.entries + " postal-code / cities pairs.")()
		}]

		[ getLookupMap(postalCode)(res) {
			for ( entry in global.cities.entries ){
				if (entry.key == postalCode){
					res.entries[#res.entries] << entry
				}
			}
		}]

		[ getCitiesForPostalCode(city)(res) {
			for ( entry in global.cities.entries ){
				if (entry.value == city) {
					res.entries[#res.entries] << entry
				}
			}
		}]

	}
}
