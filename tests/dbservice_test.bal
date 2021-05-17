// import developer_service.dbservice;
// import developer_service.model;

// import ballerina/test;

// @test:Mock {
//     moduleName: "ballerinax/mongodb",
//     functionName: "find"
// }
// test:MockFunction find = new();

// @test:Config {
//     enable: true
// }
// public function testDbServiceGetDeveloperById() {

//     model:Developer dev =  {
//         "id" : "123",
//         "name" : "Test",
//         "team" : "DPE"
//     };

//    test:when(find).thenReturn(dev);
//    model:Developer|model:Error actual = dbservice:getDeveloper("123");
//    test:assertEquals(actual, dev);
// }
