type CustomerRequest { 
    name: string
    surname: string
}

type CustomerResponse { id: int }

interface CustomerCoreInterface {
requestResponse:
    createCustomer(CustomerRequest)(CustomerResponse)
}

service Main {

    inputPort ip {
        location: "socket://localhost:3030"
        protocol: sodep
        interfaces: CustomerCoreInterface
    }

    main {
        createCustomer( request )( response ){
            if ( request.name == "Max" && request.surname == "Mustermann" ){
                response << {
                    id = 1
                }
            }
        }
    }
}