from ..jot import Stats
type Test {
    title: string
}

type TestFailed {
    title: string
    error: any
}

type Service {
    title: string
}

interface ReporterInterface {
	OneWay: 
        eventRunBegin(void),
        eventTestPass(Test),
        eventTestFail(TestFailed),
        eventServiceBegin(Service),
        eventServiceEnd(Stats),
        eventRunEnd(void)
}