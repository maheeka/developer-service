import ballerina/test;
import developer_service.utils;

@test:Config{}
function testGetDeveloperSearchQueryName() {
    map<json> result = utils:getDeveloperSearchQuery("Jane", ());
    map<json> expectedResult = {
        "name" : "Jane"
    };
    test:assertEquals(result, expectedResult);
}

@test:Config{}
function testGetDeveloperSearchQueryAll() {
    map<json> result = utils:getDeveloperSearchQuery("Jane", "Team A");
    map<json> expectedResult = {
        "name" : "Jane",
        "team" : "Team A"
    };
    test:assertEquals(result, expectedResult);
}

// show dataprovider