package jolie.jot;

import jsdt.core.types.BasicType;
import jolie.runtime.Value;
import jsdt.core.cardinality.Multi;
import java.util.stream.Collectors;

public class FindTestOperationsResponse extends BasicType<Void> {

    public FindTestOperationsResponse(Multi<FindTestOperationsResponse_services> services) {
        super(null);
        this.services = services;
    }

    public static FindTestOperationsResponse parse(Value value) {
        if (value != null) {
            Multi<FindTestOperationsResponse_services> services = Multi.of(value.getChildren("services").stream().map(FindTestOperationsResponse_services::parse).collect(Collectors.toList()));
            return new FindTestOperationsResponse(services);
        } else {
            return null;
        }
    }

    public Value toValue() {
        Value value = super.toValue();
        this.services().addChildenIfNotEmpty("services", value);
        return value;
    }

    private final Multi<FindTestOperationsResponse_services> services;

    public Multi<FindTestOperationsResponse_services> services() {
        return services;
    }
}
