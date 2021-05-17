import ballerina/test;
import ballerina/http;
import developer_service.model;

@test:Mock {
    moduleName: "developer_service.dbservice",
    functionName: "getDeveloper"
}
test:MockFunction getDeveloperByIdMockFn = new ();

http:Client clientEndpoint = check new ("http://localhost:8085/api/v1/developers");

@test:Config {}
public function testApiGetDeveloperById() {

    model:Developer dev = {
        "name": "Test",
        "team": "DPE"
    };

    test:when(getDeveloperByIdMockFn).thenReturn(dev);
    http:Response response = checkpanic clientEndpoint->get("/01ebb641-2712-1b90-81c0-9b40f8918b5e");
    test:assertEquals(response.getJsonPayload(), {"name": "Test", "team": "DPE"});
}
