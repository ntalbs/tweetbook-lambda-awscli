const Twit = require('twit')
const config = require('./config')
const T = new Twit(config.oauth_creds)

const aws = require('aws-sdk')
const dynamodb = new aws.DynamoDB.DocumentClient({apiVersion: '2012-08-10'})

const MAX_INDEX = 553

function random() {
  return Math.floor(Math.random() * MAX_INDEX)
}

async function getQuote(id) {
  let param = {
    Key: {
      "_id": id
    },
    TableName: "Quotes"
  }

  let q = await dynamodb.get(param).promise()

  return {
    msg: q.Item.msg,
    src: q.Item.src
  }
}

function tweet(quote) {
  let msg = `${quote.msg}\n${quote.src}`
  return T.post('statuses/update', {status: msg})
}

exports.handler = async (event) => {
  let q = await getQuote(random())
  let t = await tweet(q)

  const response = {
    statusCode: 200,
    quote: q,
    tweetId: t.data.id
  }

  return response;
};
