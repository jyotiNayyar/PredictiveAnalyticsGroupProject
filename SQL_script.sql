/*Retrieve data for analysis*/
select uu.user_id, au.username as artist_name, uu.gender, uu.date_of_birth, 
uu2.region artist_region,ur2."name" as artist_country, ur."name" as artist_city, chipin_account_type, ct.sub_amount,
case when trim(uu.facebook) is null or trim(uu.facebook) = '' then 0 else 1 end as has_facebook_account,
case when trim(uu.instagram) is null or trim(uu.instagram) = '' then 0 else 1 end as has_instagram_account,
case when trim(uu.snapchat) is null or trim(uu.snapchat) = '' then 0 else 1 end as has_snapchat_account,
case when trim(uu.bio) is null or trim(uu.bio) = '' then 0 else 1 end as has_bio,
case when trim(uu.twitter) is null or trim(uu.twitter) = '' then 0 else 1 end as has_twitter,
allow_collaboration, allow_direct_messaging, allow_comments, verified,
uul.profile_likes, uuc.profile_comments, uuv.profile_views,
ss.name as song_name, ss.duration as song_duration, dg.tag as song_genre,
ssl.song_likes, ssc.song_comments, ss.no_plays, ss.no_retracks , ss.downloads_count,ssv.song_views
from users_userprofile uu 
left join (SELECT *
  FROM (SELECT *,
               ROW_NUMBER() OVER (PARTITION BY user_id,name ORDER BY updated_at DESC) ranked_order
          FROM studio_song where deleted = false and state='complete') a
 WHERE a.ranked_order = 1) ss 
on uu.user_id = ss.user_id
left join studio_song_tags sst 
on ss.id = sst.song_id	
left join discover_genres dg
on sst.genres_id = dg.id
left join (select user_id, max(region) as region, max(city_id) as city_id, max(country_id) as country_id from users_userlocation group by user_id)uu2 
on uu.user_id = uu2.user_id
left join users_registrationcity ur 
on uu2.city_id = ur.id
left join users_registrationcountry ur2
on uu2.country_id = ur2.id
left join 
(select artist_id, count(user_id) as profile_likes from users_userlikes group by artist_id) uul
on uu.user_id = uul.artist_id
left join 
(select song_id, count(user_id) as song_likes from studio_songlikes group by song_id) ssl
on ss.id = ssl.song_id
left join 
(select user_id, count(created_by_id) as profile_comments from users_userprofilecomment group by user_id) uuc
on uu.user_id = uuc.user_id
left join 
(select song_id, count(created_by_id) as song_comments from studio_songcomment group by song_id) ssc
on ss.id = ssc.song_id
left join 
(select user_id, count(viewed_by_id) as profile_views from users_userprofileview group by user_id) uuv
on uu.user_id = uuv.user_id
left join 
(select song_id, count(viewed_by_id) as song_views from studio_songprofileview group by song_id) ssv
on ss.id = ssv.song_id
left join auth_user au
on uu.user_id = au.id
left join studio_publisher sp 
on uu.rights_publisher_id = sp.id 
left join studio_rightssociety sr 
on uu.rights_society_id = sr.id
left join 
(select made_for_id, 
sum(case when currency = 'usd' then amount*0.83
when currency = 'eur' then amount*0.88
else amount end) sub_amount 
from chipin_transaction 
where status = 'paid' 
group by made_for_id) ct 
on uu.user_id = ct.made_for_id
where user_type = 'creator'
order by uu.user_id


/*For analysing artist genres*/
select uu.user_id, au.username as artist_name, dg.tag, uul.profile_likes
from users_userprofile uu
left join auth_user au
on uu.user_id = au.id
left join users_usergenretags uu2 
on uu.user_id = uu2.user_id 
left join discover_genres dg 
on uu2.tag_id = dg.id
left join 
(select artist_id, count(user_id) as profile_likes from users_userlikes group by artist_id) uul
on uu.user_id = uul.artist_id
where user_type = 'creator'
and dg.tag_type = 'genres'
order by uu.user_id




