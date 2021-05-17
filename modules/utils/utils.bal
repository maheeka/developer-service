import ballerina/http;
import ballerina/regex;
import developer_service.model;

public function getDeveloperSearchQuery(string? name, string? team) returns map<json> {
    map<json> searchQuery = {};
    if (name != null) {
        searchQuery["name"] = name;
    }
    if (team != null) {
        searchQuery["team"] = team;
    }
    return searchQuery;
}

public function getDeveloperSortQuery(string? sort) returns map<json> {
    map<json> sortQuery = {};  
    if (sort != null) {
        string[] sortList = regex:split(<string>sort, ","); //TODO:  handle error   
        foreach string sortByItem in sortList {
            string[] sortBy = regex:split(sortByItem, ":");
            if (sortBy.length() == 2) {
                sortQuery[sortBy[0]] = (sortBy[1].equalsIgnoreCaseAscii("desc")) ? -1 : 1;
            }
        }
    }
    return sortQuery;
}

public function hasNext(int totalCount, int foundCount, int? page, int? pageSize) returns boolean {
    if (pageSize == ()) {
        return false;
    }
    int calcPage = (page == ()) ? 1 : <int>page;
    if (foundCount < <int>pageSize) {
        return false;
    }
    int remainingCount = totalCount - (calcPage * <int>pageSize);
    if (remainingCount > 0) {
        return true;
    } else {
        return false;
    }
}

public function wrapError(error e) returns model:Error {
    model:Error err = {
        errorType: "Internal Server Error",
        message: e.message()
    };
    return err;
}

public function getErrorHttpResponse(model:Error err) returns http:Response {
    http:Response errorResponse = new;
    errorResponse.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
    errorResponse.setPayload(err.toJson());
    error? e = errorResponse.setContentType("application/json");
    return errorResponse;
}