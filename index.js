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
  T.post('statuses/update', {status: msg}, (err, res) => {
    if (err) {
      console.error('--->>>')
      console.error(msg)
      console.error(quote)
      console.dir(err)
    } else {
      console.log('tweet succeed at ', new Date())
      console.log(res.text)
    }
  })
}

exports.handler = async(event) => {
  let quote = await getQuote(random())

  tweet(quote)

  const response = {
    statusCode: 200,
    body: quote
  }

  return response;
};
