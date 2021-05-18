import ballerina/http;
import developer_service.model;
import developer_service.dbservice;
import developer_service.utils;

configurable int port = ?;

service /api/v1 on new http:Listener(port) {

    resource function get developers(string? name, string? team, int? page, int? pageSize, string? sort) returns model:Developers|http:Response {
        model:Developers|model:Error result = dbservice:getDevelopers(name, team, page, pageSize, sort);
        if (result is model:Developers) {
            return result;
        } else {
            return utils:getErrorHttpResponse({});
        }
    }

    resource function post developers(@http:Payload{} model:Developer payload) 
            returns record {| readonly http:StatusCreated status; model:Developer body; |}| http:Response {
        model:Developer|model:Error result = dbservice:createDeveloper(payload);
        if (result is model:Developer) {
            record {|
                readonly http:StatusCreated status = new;
                model:Developer body; 
            |} response = {body: result};
            return response;
        } else {
            return utils:getErrorHttpResponse(result);
        }
    }

    resource function get developers/[string developerId]() returns model:Developer|http:Response {
        model:Developer|model:Error result = dbservice:getDeveloper(developerId);
        if (result is model:Developer) {
            return result;
        } else {
            return utils:getErrorHttpResponse(result);
        }
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

    resource function patch developers/[string developerId](@http:Payload {} model:Developer payload) returns model:Developer|http:Response {
        model:Developer|model:Error result = dbservice:patchDeveloper(developerId, payload);
        if (result is model:Developer) {
            return result;
        } else {
            return utils:getErrorHttpResponse(result);
        }
    }
}
