from spring.jparepository import JpaRepository
from console import Console
from string_utils import StringUtils
from database import ConnectionInfo, Database

type RepositoryParams {
    connectionInfo: ConnectionInfo
}

// implementation of customer core under jpa repository interface
service CustomerCoreRepository(p : RepositoryParams) {

    inputPort ip {
        location: "local"
        interfaces: JpaRepository
    }

    embed Console as console
    embed StringUtils as stringUtils
    embed Database as database

    execution: concurrent

    init {
        // println@Console("initializing CustomerCoreRepository")()
        connect@database( p.connectionInfo )( void )
        checkConnection@database()()
        println@console("connection success")()
    }

    main{

        [findAll(req)(res){
	        queryRequest =
	            "SELECT * FROM customers;";
	        query@database( queryRequest )( queryResponse )
            for ( customerRaw in queryResponse.row){
                res.result[#res.result] << {
                    birthday = customerRaw.birthday
                    firstName = customerRaw.firstName
                    lastName = customerRaw.lastName
                    password = customerRaw.password
                    phoneNumber = customerRaw.phoneNumber
                    streetAddress = customerRaw.streetAddress
                    city = customerRaw.city
                    postalCode = customerRaw.postalCode
                    customerId = customerRaw.customerId
                    email = customerRaw.email
                }
            }
        }]

        [findAllById(req)(res){
	        queryRequest =
	            "SELECT * FROM customers WHERE customerId = :customerId;";
            queryRequest.customerId = req
	        query@database( queryRequest )( queryResponse )
            for ( customerRaw in queryResponse.row ) {
                res.result[#res.result] << {
                    birthday = customerRaw.birthday
                    firstName = customerRaw.firstName
                    lastName = customerRaw.lastName
                    password = customerRaw.password
                    phoneNumber = customerRaw.phoneNumber
                    streetAddress = customerRaw.streetAddress
                    city = customerRaw.city
                    postalCode = customerRaw.postalCode
                    customerId = customerRaw.customerId
                    email = customerRaw.email
                }
            }

            for ( customer in global.customers){
                if (req == customer.customerId){
                    res.result[#res.result]  << customer
                }
            }
        }]

        [saveAll(req)(res){
            nullProcess
        }]

        [flush(req)(res){
            nullProcess // TODO
        }]

        [saveAndFlush(req)(res) {
	        queryRequest =
	            "SELECT * FROM customers WHERE customerId = :customerId;";
            queryRequest.customerId = req.customerId
	        query@database( queryRequest )( selectQueryResponse )
            if (#selectQueryResponse.row == 0){
                queryRequest =
                    "INSERT INTO customers(firstName, lastName, birthday, streetAddress, postalCode, city, email, phoneNumber, customerId) VALUES (:firstName, :lastName, :birthday, :streetAddress, :postalCode, :city, :email, :phoneNumber, :customerId) RETURNING *;"
                queryRequest.firstName = req.firstName
                queryRequest.lastName = req.lastName
                queryRequest.birthday = req.birthday
                queryRequest.streetAddress = req.streetAddress
                queryRequest.postalCode = req.postalCode
                queryRequest.city = req.city
                queryRequest.email = req.email
                queryRequest.phoneNumber = req.phoneNumber
                queryRequest.customerId = req.customerId
                query@database( queryRequest )( res )
                println@console("insert" + valueToPrettyString@stringUtils( res ))()

            }else{
                queryRequest = "UPDATE customers SET firstName = :firstName, lastName = :lastName, birthday = :birthday, streetAddress = :streetAddress, postalCode = :postalCode, city = :city, email = :email, phoneNumber = :phoneNumber WHERE customerId = :customerId RETURNING *;";
                queryRequest.firstName = req.firstName
                queryRequest.lastName = req.lastName
                queryRequest.birthday = req.birthday
                queryRequest.streetAddress = req.streetAddress
                queryRequest.postalCode = req.postalCode
                queryRequest.city = req.city
                queryRequest.email = req.email
                queryRequest.phoneNumber = req.phoneNumber
                queryRequest.customerId = req.customerId
                query@database( queryRequest )( res )
                println@console("update" + valueToPrettyString@stringUtils( res ))()

            }

        }]

        [saveAllAndFlush(req)(res){
            nullProcess // TODO
        }]

        [deleteAllInBatch(req)(res){
            nullProcess // TODO
        }]

        [deleteAllByIdInBatch(req)(res){
            nullProcess // TODO
        }]

        [getById(req)(res){
            for ( customer in global.customers){
                if (req == customer.customerId){
                    res << customer
                }
            }
        }]

    }
}