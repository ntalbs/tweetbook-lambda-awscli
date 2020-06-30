#!/usr/bin/env bash

zip -r function.zip .

aws lambda update-function-code --function-name tweetBook --zip-file fileb://function.zip

rm function.zip
