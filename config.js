if (!process.env.TWITTER_CONSUMER_KEY) {
  console.error('No twitter consumer key found.')
  process.exit(1)
} else if (!process.env.TWITTER_CONSUMER_SECRET) {
  console.error('No twitter consumer secret found.')
  process.exit(1)
} else if (!process.env.TWITTER_ACCESS_TOKEN) {
  console.error('No twitter access token found.')
  process.exit(1)
} else if (!process.env.TWITTER_ACCESS_TOKEN_SECRET) {
  console.error('No twitter access token secret found.')
  process.exit(1)
}

exports.oauth_creds = {
  consumer_key: process.env.TWITTER_CONSUMER_KEY,
  consumer_secret: process.env.TWITTER_CONSUMER_SECRET,
  access_token: process.env.TWITTER_ACCESS_TOKEN,
  access_token_secret: process.env.TWITTER_ACCESS_TOKEN_SECRET
}
