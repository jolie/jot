package jolie.jot;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import jolie.Interpreter;
import jolie.lang.Constants;
import jolie.lang.parse.SemanticVerifier;
import jolie.lang.parse.ast.InputPortInfo;
import jolie.lang.parse.ast.OperationDeclaration;
import jolie.lang.parse.ast.Program;
import jolie.lang.parse.ast.ServiceNode;
import jolie.lang.parse.util.ParsingUtils;
import jolie.runtime.FaultException;
import jolie.runtime.JavaService;
import jolie.runtime.Value;
import jolie.runtime.embedding.RequestResponse;
import jsdt.core.cardinality.Multi;
import jsdt.core.cardinality.Single;

/**
 * 
 * services* {
 * name:string
 * beforeAll*:string
 * afterAll*:string
 * beforeEach*:string
 * afterEach*:string
 * tests*:string
 * }
 */
public class JotUtils extends JavaService {

        private static final String BEFORE_ALL = "@BeforeAll";
        private static final String BEFORE_EACH = "@BeforeEach";
        private static final String AFTER_ALL = "@AfterAll";
        private static final String AFTER_EACH = "@AfterEach";
        private static final String TEST = "@Test";

        private List<String> extractOperationsByAnnotationProgram(String annotation,
                        List<OperationDeclaration> ops) {
                return ops.stream()
                                .filter(op -> op.getDocumentation().isPresent()
                                                && op.getDocumentation().get().contains(annotation))
                                .map(op -> op.id())
                                .collect(Collectors.toList());
        }

        private InputPortInfo[] extractLocalInputPortInfoFromProgram(Program p) {
                return p.children().stream()
                                .filter(node -> node instanceof InputPortInfo
                                                && ((InputPortInfo) node).location().toString()
                                                                .equals(Constants.LOCAL_LOCATION_KEYWORD))
                                .toArray(InputPortInfo[]::new);
        }

        private ServiceNode[] extractServiceNodeFromProgram(Program p) {
                return p.children().stream()
                                .filter(node -> node instanceof ServiceNode)
                                .toArray(ServiceNode[]::new);
        }

        @RequestResponse()
        public Value findTestOperations(Value value) throws FaultException {
                String sourcePath = value.strValue();
                // parse the source
                // next time, continue from here, parse the source
                Path path = Paths.get(sourcePath);
                Interpreter.Configuration config = this.interpreter().configuration();
                SemanticVerifier.Configuration semanticConfig = new SemanticVerifier.Configuration(
                                config.executionTarget());
                semanticConfig.setCheckForMain(false);
                try (InputStream input = new FileInputStream(path.toFile())) {
                        Program p = ParsingUtils.parseProgram(input, path.toUri(), config.charset(),
                                        config.includePaths(),
                                        config.packagePaths(), config.jolieClassLoader(), config.constants(),
                                        semanticConfig, true);
                        ServiceNode[] services = extractServiceNodeFromProgram(p);

                        List<FindTestOperationsResponse_services> result = new ArrayList<FindTestOperationsResponse_services>();

                        for (ServiceNode service : services) {
                                Single<FindTestOperationsResponse_services_name> name = Single
                                                .of(new FindTestOperationsResponse_services_name(service.name()));
                                InputPortInfo[] localIPs = extractLocalInputPortInfoFromProgram(service.program());
                                List<OperationDeclaration> ops = Arrays.asList(localIPs).stream()
                                                .flatMap(ip -> ip.operations().stream())
                                                .collect(Collectors.toList());
                                List<FindTestOperationsResponse_services_beforeAll> beforeAll = extractOperationsByAnnotationProgram(
                                                BEFORE_ALL, ops).stream()
                                                .map(FindTestOperationsResponse_services_beforeAll::new)
                                                .collect(Collectors.toList());
                                List<FindTestOperationsResponse_services_beforeEach> beforeEach = extractOperationsByAnnotationProgram(
                                                BEFORE_EACH, ops).stream()
                                                .map(FindTestOperationsResponse_services_beforeEach::new)
                                                .collect(Collectors.toList());
                                List<FindTestOperationsResponse_services_afterEach> afterEach = extractOperationsByAnnotationProgram(
                                                AFTER_EACH, ops).stream()
                                                .map(FindTestOperationsResponse_services_afterEach::new)
                                                .collect(Collectors.toList());
                                List<FindTestOperationsResponse_services_afterAll> afterAll = extractOperationsByAnnotationProgram(
                                                AFTER_ALL, ops).stream()
                                                .map(FindTestOperationsResponse_services_afterAll::new)
                                                .collect(Collectors.toList());
                                List<FindTestOperationsResponse_services_tests> tests = extractOperationsByAnnotationProgram(
                                                TEST, ops).stream().map(FindTestOperationsResponse_services_tests::new)
                                                .collect(Collectors.toList());
                                FindTestOperationsResponse_services serviceVal = new FindTestOperationsResponse_services(
                                                Multi.of(beforeEach),
                                                Multi.of(tests), Multi.of(afterEach), Multi.of(beforeAll),
                                                Multi.of(afterAll), name);
                                result.add(serviceVal);
                        }

                        return new FindTestOperationsResponse(Multi.of(result)).toValue();
                } catch (IOException e) {
                        throw new FaultException(sourcePath + " does not exist");
                } catch (Exception e) {
                        e.printStackTrace();
                        throw new FaultException("Unable to parse " + sourcePath, e.getMessage());
                }
        }
}
