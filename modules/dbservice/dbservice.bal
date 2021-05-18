import ballerina/log;
import ballerina/time;
import ballerina/uuid;
import ballerinax/mongodb;
import developer_service.utils;
import developer_service.model;

type MongoDbConfigNew record {|
    string host;
    int port;
    string username;
    string password;
    string authSource;
    string dbName;
    string collection;
|};

configurable MongoDbConfigNew & readonly mongodb = ?;

mongodb:ClientConfig mongoConfig = {
    host: mongodb.host,
    port: mongodb.port,
    username: mongodb.username,
    password: mongodb.password,
    options: {
        authSource: mongodb.authSource,
        sslEnabled: false,
        serverSelectionTimeout: 5000
    }
};

public function getDevelopers(string? name, string? team, int? page, int? pageSize, string? sort) returns model:Developers|error {
    log:printDebug("Looking for developers..");

    map<json> searchQuery = utils:getDeveloperSearchQuery(name, team);
    map<json> sortQuery = utils:getDeveloperSortQuery(sort);

    log:printDebug("Search query : " + searchQuery.toJsonString());
    log:printDebug("Sort query : " + sortQuery.toJsonString());

    mongodb:Client mongoClient = check new (mongoConfig, mongodb.dbName);
    int totalCount = check mongoClient->countDocuments(mongodb.collection, (), searchQuery);
    map<json>[] jsonDevelopers;

    if (pageSize is int) {
        jsonDevelopers = check mongoClient->find(mongodb.collection, (), searchQuery, sortQuery, <int>pageSize);
    } else {
        jsonDevelopers = check mongoClient->find(mongodb.collection, (), searchQuery, sortQuery);
    }
    mongoClient->close();

    model:Developer[] devList = [];
    foreach var devJson in jsonDevelopers {
        json id = devJson.remove("_id");
        model:Developer|error dev = devJson.fromJsonWithType(model:Developer);
        if (dev is model:Developer) {
            devList.push(dev);
        } else {
            error err = dev;
            log:printError(err.message());
        }
    }

    int foundCount = devList.length();
    boolean hasNext = utils:hasNext(totalCount, foundCount, page, pageSize);
    model:Developers developers = {
        items: devList,
        hasNext: hasNext
    };
    return developers;
}

# Create a developer.
#
# + developer - developer
# + return - created developer with created timestamp and id
public function createDeveloper(model:Developer developer) returns model:Developer|error {
    map<json> developerJson = developer;

    string createdAt = time:utcToString(time:utcNow());
    developerJson["id"] = uuid:createType1AsString();
    developerJson["createdAt"] = createdAt;
    developerJson["updatedAt"] = createdAt;
    
    mongodb:Client mongoClient = checkpanic new (mongoConfig, mongodb.dbName);
    check mongoClient->insert(developerJson, mongodb.collection);
    mongoClient->close();

    model:Developer|error createdDeveloper = developerJson.cloneWithType(model:Developer);
    return createdDeveloper;
}

public function getDeveloper(string developerId) returns model:Developers|model:Error|error {
    mongodb:Client mongoClient = check new (mongoConfig, mongodb.dbName);

    map<json> searchQuery = {"id": developerId};
    map<json>[] searchResults = check mongoClient->find(mongodb.collection, (), searchQuery);
    mongoClient->close();

    if (searchResults.length() == 0) {
        model:Error err = {
            errorType: model:NotFound,
            message: "Developer not found"
        };
        return err;
    }
    map<json> devJson = searchResults[0];
    json id = devJson.remove("_id");

    log:printDebug("Found developer by id " + id.toJsonString());

    model:Developer|error dev = devJson.fromJsonWithType(model:Developer);
    if (dev is model:Developer) {
        return dev;
    } else {
        model:Error err = {errorType: model:InternalServerError};
        return err;
    }
}

public function deleteDeveloper(string developerId) returns boolean|model:Error|error {
    mongodb:Client mongoClient = check new (mongoConfig, mongodb.dbName);

    map<json> deleteQuery = {"id": developerId};
    int deleteResults = check mongoClient->delete(mongodb.collection, (), deleteQuery);
    mongoClient->close();
    if (deleteResults > 0) {
        return true;
    } else {
        model:Error err = {
            errorType: model:NotFound,
            message: "Developer not found"
        };
        return err;
    }
}

public function patchDeveloper(string developerId, model:Developer developer) returns model:Developer|model:Error|error {
    mongodb:Client mongoClient = check new (mongoConfig, mongodb.dbName);

    map<json> updateQuery = {"id": developerId};

    model:Developer|model:Error existingCustomer = check getDeveloper(developerId);
    if (existingCustomer is model:Developer) {
        map<json> newDeveloperJson = developer;
        newDeveloperJson["updatedAt"] = time:utcToString(time:utcNow());
        newDeveloperJson["createdAt"] = existingCustomer["createdAt"];
        newDeveloperJson["id"] = developerId;

        int updatedCount = check mongoClient->update(newDeveloperJson, mongodb.collection, (), updateQuery, false);
        mongoClient->close();

        if (updatedCount > 0) {
            log:printInfo("Modified count with update filter: '" + updatedCount.toString() + "'.");
        } else {
            log:printInfo("Nothing modified with update filter."); 
        }
        return developer;
    } else {
        return existingCustomer;
    }
}
