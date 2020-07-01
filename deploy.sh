#!/usr/bin/env bash

# This will create tweet-book lambda function. The following environment variables should be set before running this script.
#
# - TWITTER_CONSUMER_KEY
# - TWITTER_CONSUMER_SECRET
# - TWITTER_ACCESS_TOKEN
# - TWITTER_ACCESS_TOKEN_SECRET
#
# The IAM role used here is created manually.

LAMBDA_FUNCTION_NAME='tweet-book'
DESCRIPTION='Very simple lambda function that fetch a quote from DynamoDB and tweet it.'

function update-lambda {
    aws lambda update-function-code --function-name $LAMBDA_FUNCTION_NAME --zip-file fileb://function.zip
}

function create-lambda {
    aws lambda create-function \
        --function-name $LAMBDA_FUNCTION_NAME \
        --description "$DESCRIPTION" \
        --runtime nodejs12.x \
        --zip-file fileb://function.zip \
        --handler index.handler \
        --role arn:aws:iam::884307244203:role/tweet-book-role
}

zip -r function.zip . -x "*.sh" -x ".git/*" -x "README.md" -x "*.zip"

update-lambda

if [ $? -ne 0 ]; then
    echo -e "\e[33mCreate function $LAMBDA_FUNCTION_NAME\e[0m"
    create-lambda
fi

aws lambda update-function-configuration --function-name $LAMBDA_FUNCTION_NAME --environment "Variables={TWITTER_CONSUMER_KEY=$TWITTER_CONSUMER_KEY,TWITTER_CONSUMER_SECRET=$TWITTER_CONSUMER_SECRET,TWITTER_ACCESS_TOKEN=$TWITTER_ACCESS_TOKEN,TWITTER_ACCESS_TOKEN_SECRET=$TWITTER_ACCESS_TOKEN_SECRET}"

rm function.zip
