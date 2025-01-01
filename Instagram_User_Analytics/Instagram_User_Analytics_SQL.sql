USE ig_clone;

-- Marketing Analysis
-- 1. Most loyal users (oldest users) 

SELECT 
    *
FROM
    users
ORDER BY created_at
LIMIT 5;

-- 2. Inactive user

SELECT 
    users.id,
    users.username,
    COUNT(DISTINCT (photos.image_url)) AS num_of_photos
FROM
    photos
        RIGHT JOIN
    users ON users.id = photos.user_id
GROUP BY users.id
HAVING num_of_photos = 0;

-- 3. Contest Winner --> User with most likes on single photo

SELECT * FROM (
SELECT 
    users.id AS user_id,
    users.username,
    likes.photo_id,
    COUNT(likes.photo_id) AS photo_likes
FROM
    photos
        RIGHT JOIN
    likes ON likes.photo_id = photos.id
        LEFT JOIN
    users ON users.id = photos.user_id
GROUP BY photos.user_id , likes.photo_id
ORDER BY photo_likes DESC 
 ) as contest_winner
HAVING MAX(contest_winner.photo_likes);

-- ORDER BY max(photo_likes) DESC; 

-- 4. Most Popular Hashtag

SELECT 
    tags.id, tags.tag_name, COUNT(photo_id) AS hashtag_used
FROM
    photo_tags
        LEFT JOIN
    tags ON tags.id = photo_tags.tag_id
GROUP BY tag_id
ORDER BY hashtag_used DESC
LIMIT 5;

-- 5. Best day of the week to launch ad.

SELECT 
    DAYNAME(created_at) AS day_of_week,
    COUNT(users.id) AS users_register
FROM
    users
GROUP BY day_of_week
ORDER BY users_register DESC;  

-- Investor Metrics

-- 1. User Engagement
-- i. Posts per user
SELECT 
    photos.user_id, users.username, COUNT(photos.id) AS posts
FROM
    photos
        LEFT JOIN
    users ON users.id = photos.user_id
GROUP BY photos.user_id
ORDER BY posts DESC;

-- ii. Average posts per user

SELECT 
    CONVERT(posts_per_user , SIGNED) as posts_per_user
FROM
    (SELECT 
        COUNT(DISTINCT (photos.id)) / COUNT(DISTINCT (users.id)) AS posts_per_user
    FROM
        users
    LEFT JOIN photos ON photos.user_id = users.id) AS data;

-- 2. Bots or Fake accounts

SELECT 
    *
FROM
    (SELECT 
        users.id AS user_id,
		users.username,
		COUNT(DISTINCT (likes.photo_id)) AS likes_by_user
    FROM
        users
    RIGHT JOIN likes ON likes.user_id = users.id
    GROUP BY users.id , users.username
    ORDER BY likes_by_user DESC) AS bot_detector
HAVING likes_by_user = (SELECT 
        COUNT(photos.id)
    FROM
        photos)
ORDER BY bot_detector.user_id;