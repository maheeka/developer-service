import ballerina/http;
import developer_service.model;
import developer_service.dbservice;

configurable int port = ?;

service /api/v1 on new http:Listener(port) {

    resource function get developers(string? name, string? team, int? page, int? pageSize, string? sort) returns model:Developers|model:Error {
        return dbservice:getDevelopers(name, team, page, pageSize, sort);
    }

    resource function post developers(@http:Payload{} model:Developer payload) 
            returns record {| readonly http:StatusCreated status; model:Developer body; |}|model:Error {
        model:Developer createdDeveloper = dbservice:createDeveloper(payload);
        record {|
            readonly http:StatusCreated status = new;
            model:Developer body; 
        |} response = {body: createdDeveloper};
        return response;
    }

    resource function get developers/[string developerId]() returns string|model:Error {
        model:Developer|model:Error dev = dbservice:getDeveloper(developerId);
        return dev;
    }
    resource function delete developers/[string developerId]() returns http:NoContent|model:Error {
        boolean|model:Error deleteResults = dbservice:deleteDeveloper(developerId);
        if (deleteResults is model:Error) {
            return deleteResults;
        } else {
            http:NoContent resp = {};
            return resp;
        }
    }

    resource function patch developers/[string developerId](@http:Payload {} model:Developer payload) returns model:Developer|model:Error {
        model:Developer|model:Error dev = dbservice:patchDeveloper(developerId, payload);
        return dev;
    }
}
