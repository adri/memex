#!/usr/bin/env bash
# Imports a timeline from Twitter
# Needs twitter-to-sqlite database.
SHARED_FIELDS="
    'provider', 'Twitter',
    'id', 'twitter-' || tweets.id,
    'date_month', strftime('%Y-%m', tweets.created_at),
    'timestamp_utc', datetime(tweets.created_at),
    'timestamp_unix', CAST(strftime('%s', tweets.created_at) AS INT),
    'tweet_full_text', substr(tweets.full_text, json_extract(tweets.display_text_range, '\$[0]'), json_extract(tweets.display_text_range, '\$[1]')),
    'tweet_liked', tweets.favorited,
    'tweet_retweeted', tweets.retweeted,
    'tweet_liked_count', tweets.favorite_count,
    'tweet_retweet_count', tweets.retweet_count,
    'tweet_user_screen_name', users.screen_name,
    'tweet_user_name', users.name,
    'tweet_user_description', users.description,
    'tweet_user_location', users.location,
    'tweet_user_url', users.url,
    'tweet_user_avatar_url', users.profile_image_url,
    'tweet_media', CASE WHEN media.id IS NULL THEN json('[]') ELSE json_group_array(
        json_object(
            'type', media.type,
            'url', media.media_url_https
        )
    ) END,
"

# Merge twitter handle with contacts?
# 1. Tweets I liked or retweeted
sqlite3 "twitter-to-sqlite/twitter.db" -readonly "
SELECT
    json_object(
        $SHARED_FIELDS
        'verb', 'liked'
    ) AS json
FROM tweets
JOIN users ON users.id=tweets.user
LEFT JOIN media_tweets ON media_tweets.tweets_id=tweets.id
LEFT JOIN media ON media.id=media_tweets.media_id
WHERE
	(tweets.favorited = 1 AND tweets.favorite_count != 0)
	OR (tweets.retweeted = 1 AND tweets.retweeted_status IS NULL)
GROUP BY tweets.id
"

# 2. Tweets on my timeline.
# Exclude liked or retweeted because they are imported above.
sqlite3 "twitter-to-sqlite/twitter.db" -readonly "
SELECT
    json_object(
        $SHARED_FIELDS
        'verb', 'read'
    ) AS json
FROM timeline_tweets
JOIN tweets ON timeline_tweets.tweet=tweets.id
JOIN users ON users.id=tweets.user
LEFT JOIN media_tweets ON media_tweets.tweets_id=tweets.id
LEFT JOIN media ON media.id=media_tweets.media_id
WHERE
    tweets.favorited = 0
    AND tweets.retweeted = 0
GROUP BY tweets.id
"
