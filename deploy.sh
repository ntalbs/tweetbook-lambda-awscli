#!/usr/bin/env bash

# This will create tweet-book lambda function. The following environment variables should be set before running this script.
#
# - TWITTER_CONSUMER_KEY
# - TWITTER_CONSUMER_SECRET
# - TWITTER_ACCESS_TOKEN
# - TWITTER_ACCESS_TOKEN_SECRET
#
# The IAM role used here is created manually.

YELLOW='\e[33m'
RESET='\e[0m'

LAMBDA_NAME='tweet-book'
DESCRIPTION='Very simple lambda function that fetch a quote from DynamoDB and tweet it.'

function echo_yellow {
    echo -e "$YELLOW$1$RESET"
}

function update-lambda {
    aws lambda update-function-code \
        --function-name $LAMBDA_NAME \
        --zip-file fileb://function.zip \
        --output json
    echo_yellow ">>> lambda updated..."
}

function update-lambda-config {
    aws lambda update-function-configuration \
        --function-name $LAMBDA_NAME \
        --environment "Variables={TWITTER_CONSUMER_KEY=$TWITTER_CONSUMER_KEY,TWITTER_CONSUMER_SECRET=$TWITTER_CONSUMER_SECRET,TWITTER_ACCESS_TOKEN=$TWITTER_ACCESS_TOKEN,TWITTER_ACCESS_TOKEN_SECRET=$TWITTER_ACCESS_TOKEN_SECRET}" \
        > /dev/null
    echo_yellow ">>> lambda config updated..."
}

function create-lambda {
    # create lambda function
    LAMBDA_ARN=$(aws lambda create-function \
                     --function-name $LAMBDA_NAME \
                     --description "$DESCRIPTION" \
                     --runtime nodejs12.x \
                     --zip-file fileb://function.zip \
                     --handler index.handler \
                     --role arn:aws:iam::884307244203:role/tweet-book-role \
                     --output json | jq '.FunctionArn')
    echo_yellow ">>> Lambda created... Arn: $LAMBDA_ARN"

    # create trigger: once a day at 6am UTC
    TRIGGER_NAME='trigger-once-a-day'
    RULE_ARN=$(aws events put-rule \
                   --name $TRIGGER_NAME \
                   --schedule-expression 'cron(0 6 * * ? *)' \
                   --output json | jq '.RuleArn' --raw-output)
    echo_yellow ">>> Rule created ... Arn: $RULE_ARN"

    aws lambda add-permission \
        --function-name "$LAMBDA_NAME" \
        --statement-id "$TRIGGER_NAME-event" \
        --action 'lambda:InvokeFunction' \
        --principal events.amazonaws.com \
        --source-arn $RULE_ARN

    aws events put-targets --rule $TRIGGER_NAME --targets "Id"="1","Arn"="$LAMBDA_ARN"
    echo_yellow ">>> Trigger added..."
}

zip -r function.zip . -x "*.sh" -x ".git/*" -x "README.md" -x "*.zip"

aws lambda get-function --function-name $LAMBDA_NAME

if [ $? -eq 0 ]; then
    update-lambda
else
    create-lambda
fi

update-lambda-config

rm function.zip
