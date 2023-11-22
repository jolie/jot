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
    execution: concurrent

    inputPort ip0 {
        location: "socket://localhost:3030"
        protocol: soap
        interfaces: CustomerCoreInterface
    }

    inputPort ip1 {
        location: "socket://localhost:3031"
        protocol: jsonrpc
        interfaces: CustomerCoreInterface
    }

    main {
        createCustomer( request )( response ){
            if ( request.name == "Homer" && request.surname == "Simpson" ){
                response << {
                    id = 1
                }
            }
        }
    }
}