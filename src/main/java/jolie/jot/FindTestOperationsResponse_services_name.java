package jolie.jot;

import jsdt.core.types.BasicType;
import jolie.runtime.Value;

public class FindTestOperationsResponse_services_name extends BasicType<String> {

    public FindTestOperationsResponse_services_name(String root) {
        super(root);
    }

    public static FindTestOperationsResponse_services_name parse(Value value) {
        if (value != null && value.isString()) {
            return new FindTestOperationsResponse_services_name(value.strValue());
        } else {
            return null;
        }
    }

    public Value toValue() {
        Value value = super.toValue();
        return value;
    }
}
