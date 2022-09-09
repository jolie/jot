from values import Values

type AssertionRequest {
	actual:undefined
	expected:undefined
}

interface AssertionsInterface {
RequestResponse:
	equals(AssertionRequest)(void) throws AssertionError(string) //(ValueDiff)
}

service Assertions {
	execution: concurrent

	embed Values as values

	inputPort Input {
		location: "local"
		interfaces: AssertionsInterface
	}

	init {
		install( default => nullProcess )
	}

	main {
		equals( request )() {
			if( !equals@values( { fst -> request.expected, snd -> request.actual } ) ) {
				throw( AssertionError, "Bloody hell!" ) //, diff@values( request ) )
			}
		}
	}
}