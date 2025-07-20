drop table if exists likes;
drop table if exists comments;
drop table if exists photo_tags;
drop table if exists caption_tags;
drop table if exists hashtags_posts;
drop table if exists followers;
drop table if exists hashtags;
drop table if exists posts;
drop table if exists users;


create table users
(
    id serial primary key,
    username varchar(50) not null,
    bio varchar(100),
    avatar varchar(100),
    phone varchar(20),
    email varchar(40),
    password varchar(50),
    status varchar(15),
    created_at timestamp not null default CURRENT_TIMESTAMP,
    updated_at timestamp not null default CURRENT_TIMESTAMP,
    check(coalesce(phone, email) is not null) -- either phone or email is must. Needed for login.
);

create table posts
(
    id serial primary key,
    caption varchar(250),
    url varchar(200) not null,
    user_id int not null references users(id) on delete cascade,
    lat real check(lat is null OR (lat between -90 and 90)), 
	lng real check(lng is null OR (lng between -180 and 180)),
    created_at timestamp not null default CURRENT_TIMESTAMP,
    updated_at timestamp not null default CURRENT_TIMESTAMP
);

create table comments
(
    id serial primary key,
    contents varchar(250) not null,
    user_id int not null references users(id) on delete cascade,
    post_id int not null references posts(id) on delete cascade,
    created_at timestamp not null default CURRENT_TIMESTAMP,
    updated_at timestamp not null default CURRENT_TIMESTAMP
);

create table likes
(
    id serial primary key,
    user_id int not null references users(id) on delete cascade,
    post_id int references posts(id) on delete cascade,
    comment_id int references comments(id) on delete cascade,
    created_at timestamp not null default CURRENT_TIMESTAMP,
    unique(user_id, post_id, comment_id), -- a user can cast only one like per post/comment
    check(
        coalesce(post_id::bool::int, 0) + coalesce(comment_id::bool::int, 0) = 1 -- either comment or post
    )
);

create table photo_tags
(
    id serial primary key,
    post_id int not null references posts(id) on delete cascade,
    user_id int not null references users(id) on delete cascade,
    created_at timestamp not null default CURRENT_TIMESTAMP,
    updated_at timestamp not null default CURRENT_TIMESTAMP,
    x int not null,
    y int not null,
    unique(user_id, post_id)
);

create table caption_tags
(
    id serial primary key,
    post_id int not null references posts(id) on delete cascade,
    user_id int not null references users(id) on delete cascade,
    created_at timestamp not null default CURRENT_TIMESTAMP,
    unique(user_id, post_id)
);

create table hashtags
(
    id serial primary key,
    title varchar(50) not null unique,
    created_at timestamp not null default CURRENT_TIMESTAMP
);

create table hashtags_posts
(
    id serial primary key,
    hashtag_id int not null references hashtags(id) on delete cascade,
    post_id int not null references posts(id) on delete cascade,
    unique(hashtag_id, post_id)
);

create table followers
(
    id serial primary key,
    leader_id int not null references users(id) on delete cascade,
    follower_id int not null references users(id) on delete cascade,
    created_at timestamp not null default CURRENT_TIMESTAMP,
    unique(leader_id, follower_id),
    check(leader_id != follower_id) -- a user cannot follow themself
);

