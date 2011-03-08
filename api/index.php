<?php

require("RestUtils.lol");
require("LolstackApi.lol");


$requestData = RestUtils::processRequest();



//send data to Api class to handle call
// $responseData->jsondata is a json encoded response. could be an error.
$responseData = LolstackApi::getResponseObject($requestData);
RestUtils::sendResponse($responseData->code, $responseData->jsondata, 'application/json');




?>