package jolie.jot;

import jsdt.core.types.BasicType;
import jolie.runtime.Value;
import jsdt.core.cardinality.Multi;
import java.util.stream.Collectors;
import jsdt.core.cardinality.Single;

public class FindTestOperationsResponse_services extends BasicType<Void> {

    public FindTestOperationsResponse_services(Multi<FindTestOperationsResponse_services_beforeEach> beforeEach, Multi<FindTestOperationsResponse_services_tests> tests, Multi<FindTestOperationsResponse_services_afterEach> afterEach, Multi<FindTestOperationsResponse_services_beforeAll> beforeAll, Multi<FindTestOperationsResponse_services_afterAll> afterAll, Single<FindTestOperationsResponse_services_name> name) {
        super(null);
        this.beforeEach = beforeEach;
        this.tests = tests;
        this.afterEach = afterEach;
        this.beforeAll = beforeAll;
        this.afterAll = afterAll;
        this.name = name;
    }

    public static FindTestOperationsResponse_services parse(Value value) {
        if (value != null) {
            Multi<FindTestOperationsResponse_services_beforeEach> beforeEach = Multi.of(value.getChildren("beforeEach").stream().map(FindTestOperationsResponse_services_beforeEach::parse).collect(Collectors.toList()));
            Multi<FindTestOperationsResponse_services_tests> tests = Multi.of(value.getChildren("tests").stream().map(FindTestOperationsResponse_services_tests::parse).collect(Collectors.toList()));
            Multi<FindTestOperationsResponse_services_afterEach> afterEach = Multi.of(value.getChildren("afterEach").stream().map(FindTestOperationsResponse_services_afterEach::parse).collect(Collectors.toList()));
            Multi<FindTestOperationsResponse_services_beforeAll> beforeAll = Multi.of(value.getChildren("beforeAll").stream().map(FindTestOperationsResponse_services_beforeAll::parse).collect(Collectors.toList()));
            Multi<FindTestOperationsResponse_services_afterAll> afterAll = Multi.of(value.getChildren("afterAll").stream().map(FindTestOperationsResponse_services_afterAll::parse).collect(Collectors.toList()));
            Single<FindTestOperationsResponse_services_name> name = Single.of(FindTestOperationsResponse_services_name.parse(value.getChildren("name").get(0)));
            return new FindTestOperationsResponse_services(beforeEach, tests, afterEach, beforeAll, afterAll, name);
        } else {
            return null;
        }
    }

    public Value toValue() {
        Value value = super.toValue();
        this.beforeEach().addChildenIfNotEmpty("beforeEach", value);
        this.tests().addChildenIfNotEmpty("tests", value);
        this.afterEach().addChildenIfNotEmpty("afterEach", value);
        this.beforeAll().addChildenIfNotEmpty("beforeAll", value);
        this.afterAll().addChildenIfNotEmpty("afterAll", value);
        this.name().addChildenIfNotEmpty("name", value);
        return value;
    }

    private final Multi<FindTestOperationsResponse_services_beforeEach> beforeEach;

    public Multi<FindTestOperationsResponse_services_beforeEach> beforeEach() {
        return beforeEach;
    }

    private final Multi<FindTestOperationsResponse_services_tests> tests;

    public Multi<FindTestOperationsResponse_services_tests> tests() {
        return tests;
    }

    private final Multi<FindTestOperationsResponse_services_afterEach> afterEach;

    public Multi<FindTestOperationsResponse_services_afterEach> afterEach() {
        return afterEach;
    }

    private final Multi<FindTestOperationsResponse_services_beforeAll> beforeAll;

    public Multi<FindTestOperationsResponse_services_beforeAll> beforeAll() {
        return beforeAll;
    }

    private final Multi<FindTestOperationsResponse_services_afterAll> afterAll;

    public Multi<FindTestOperationsResponse_services_afterAll> afterAll() {
        return afterAll;
    }

    private final Single<FindTestOperationsResponse_services_name> name;

    public Single<FindTestOperationsResponse_services_name> name() {
        return name;
    }
}
