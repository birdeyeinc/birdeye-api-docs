#!/bin/bash
# The Food House — Seed Reviews Script
# Run: bash create_foodhouse_reviews.sh
# 20 reviews across 30 days — designed so AI generates a rich, structured survey
# Themes: Food Quality · Wait Time · Order Accuracy · Staff Service · Cleanliness · Value for Money

BASE_URL="https://paidreviews.birdeye.com/review/create/organic?clientIp=null&businessId=1916697"
HEADERS=('-H' 'Content-Type: application/json' '-H' 'Accept: application/json' '-H' 'api_key: organic')

post_review() {
  local nickname="$1"
  local email="$2"
  local rating="$3"
  local date="$4"
  local comment="$5"

  echo "Creating review for $nickname (★$rating)..."
  curl -s -o /dev/null -w "  HTTP %{http_code}\n" --location "$BASE_URL" \
    "${HEADERS[@]}" \
    --data-raw "{
      \"comments\": $(echo "$comment" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read().strip()))'),
      \"overallRating\": $rating,
      \"reviewer\": {
        \"emailId\": \"$email\",
        \"nickName\": \"$nickname\"
      },
      \"reviewDate\": $date,
      \"sourceId\": 100
    }"
  sleep 1
}

# ── FOOD QUALITY THEME (5 reviews) ───────────────────────────────────────────

post_review \
  "Sandra Lee" "sandra.lee@birdeyetest.com" 2 \
  1784246400000 \
  "The pasta I ordered was completely cold by the time it reached the table, and I was sitting less than 10 feet from the kitchen pass. It tasted fine in terms of flavor but eating a cold hot dish is just disappointing. Didn't feel worth the $18 price tag. I really hope they fix the temperature consistency."

post_review \
  "Brian Okafor" "brian.okafor@birdeyetest.com" 1 \
  1784592000000 \
  "My burger was overcooked to the point of being dry and tough — I asked for medium and got something closer to well done. The bun was also stale, almost like it had been sitting out. For a restaurant that's supposed to be known for its burgers, this was a real letdown. The fries were good though."

post_review \
  "Nadia Kowalczyk" "nadia.kowalczyk@birdeyetest.com" 2 \
  1785110400000 \
  "Portion sizes have clearly shrunk since my last visit six months ago but the prices have gone up. My lunch plate was noticeably smaller and I left still hungry. When you're charging $22 for a main course, the value needs to be there. I noticed two other tables making similar comments to each other."

post_review \
  "Derek Huang" "derek.huang@birdeyetest.com" 1 \
  1785715200000 \
  "Ordered the daily special — grilled salmon. It smelled slightly off and had an unusual texture, like it had been sitting for a while before plating. I didn't finish it and let the server know. The manager came over but didn't offer anything beyond an apology. If the freshness of your ingredients isn't there, everything else suffers."

post_review \
  "Chloe Baptiste" "chloe.baptiste@birdeyetest.com" 2 \
  1786320000000 \
  "The salad I ordered had wilted lettuce and the tomatoes were clearly not fresh — soft and slightly discolored. For a dish being marketed as a 'fresh garden salad' the ingredients need to actually be fresh. My friend's soup was good so this might be an inconsistency problem across menu items."

# ── WAIT TIME THEME (4 reviews) ──────────────────────────────────────────────

post_review \
  "Marcus Johnson" "marcus.johnson@birdeyetest.com" 2 \
  1784419200000 \
  "Came in for a quick weekday lunch and waited 35 minutes for a simple sandwich and fries. The restaurant was maybe half full. No one came to update us or acknowledge the delay. I ended up being late back to work. If this is the typical pace, they need to either hire more kitchen staff or manage table expectations better at the door."

post_review \
  "Preethi Subramaniam" "preethi.subramaniam@birdeyetest.com" 1 \
  1784937600000 \
  "Placed an online order with a quoted 20-minute pickup time. Arrived in 25 minutes to be safe and waited another 45 minutes at the counter. The staff acknowledged me once and then seemed to forget I was there. Other walk-in customers were being served. The online ordering system needs to reflect realistic prep times."

post_review \
  "Owen McCarthy" "owen.mccarthy@birdeyetest.com" 2 \
  1785542400000 \
  "Friday dinner rush, I understand it gets busy, but we waited 50 minutes for two plates of food after being seated. No mid-wait update, no offer of complimentary bread, nothing. The food was good when it arrived but by that point our mood had soured. Communication during long waits would make a huge difference."

post_review \
  "Yuki Tanaka" "yuki.tanaka@birdeyetest.com" 2 \
  1786060800000 \
  "The wait times here are genuinely unpredictable. I've visited four times — two were fast and fine, two were frustratingly slow with no explanation. It's hard to recommend a restaurant to friends when you can't predict whether the experience will be 30 minutes or 90 minutes for the same meal. Consistency is the issue."

# ── ORDER ACCURACY THEME (4 reviews) ─────────────────────────────────────────

post_review \
  "Tanya Ferreira" "tanya.ferreira@birdeyetest.com" 1 \
  1784764800000 \
  "I have a dairy allergy and explicitly told the server twice — no cheese, no cream-based sauces. My dish arrived with both. I had to send it back and wait another 20 minutes for a corrected plate. Dietary restrictions are not preferences, they're health issues. The kitchen needs a better process for flagging modifications."

post_review \
  "Anthony Russo" "anthony.russo@birdeyetest.com" 2 \
  1785283200000 \
  "Ordered a takeout bag and didn't check it at the counter — my mistake. Got home to find one of the three items was missing and one was completely wrong (got a chicken dish when I ordered vegetarian). Calling back to report it was fine, they offered a credit, but I'd already eaten something else by then. Double-checking orders before handing them out would help."

post_review \
  "Grace Nwachukwu" "grace.nwachukwu@birdeyetest.com" 2 \
  1785888000000 \
  "The food itself is good when they get it right. But this is the second time my order came out different from what I asked for. I ordered medium spice and got something extremely hot that I couldn't eat. I didn't make a fuss but I really wish order customizations were taken more seriously. A simple read-back from the server would prevent these issues."

post_review \
  "Felipe Carvalho" "felipe.carvalho@birdeyetest.com" 3 \
  1786492800000 \
  "Mixed experience. The food quality was solid and the ambiance is nice. But they got two items on our four-person table order wrong. The server was apologetic and fixed it without any issue, so that part was handled well. I'm giving 3 stars because the good outweighs the bad — but order accuracy needs to be tightened up."

# ── STAFF & SERVICE THEME (3 reviews) ────────────────────────────────────────

post_review \
  "Laura Vance" "laura.vance@birdeyetest.com" 1 \
  1784332800000 \
  "The server who took our order was visibly disinterested — didn't make eye contact, gave one-word answers to questions about the menu, and disappeared for long stretches. We had to flag down another server just to get water refills. Good food can't carry the whole experience when the service makes you feel unwelcome."

post_review \
  "Samuel Adeyemi" "samuel.adeyemi@birdeyetest.com" 2 \
  1785456000000 \
  "Got the impression the staff was having a tough day but it shouldn't show to customers. Server was curt, didn't check back after food arrived, and when I asked for the bill it took 15 minutes. I've had great service here before so I think this was an off night — but it affected the whole visit."

post_review \
  "Jessica Thornton" "jessica.thornton@birdeyetest.com" 5 \
  1786147200000 \
  "Our server Maya was absolutely wonderful — attentive without hovering, genuinely knowledgeable about the menu, and had a great sense of humor. She made a dinner that was already good feel special. This is the kind of service that makes you want to come back. The restaurant should make sure every server operates at this level."

# ── CLEANLINESS & AMBIANCE (2 reviews) ───────────────────────────────────────

post_review \
  "Ingrid Holmberg" "ingrid.holmberg@birdeyetest.com" 2 \
  1785024000000 \
  "The food was decent but I was bothered by the state of the dining area. Our table had residue from the previous diners — it had clearly been wiped but not properly cleaned. The floor near the entrance had visible crumbs and hadn't been swept in a while. The kitchen might be great but cleanliness in the dining room matters too."

post_review \
  "Rohan Desai" "rohan.desai@birdeyetest.com" 5 \
  1786579200000 \
  "Lovely atmosphere — warm lighting, comfortable seating, and the noise level is actually conversation-friendly which is rare. The restaurant felt clean and well-maintained. We came for a birthday dinner and the staff even acknowledged it without us having to make a big deal. Really pleasant evening all around."

# ── VALUE FOR MONEY (2 reviews) ──────────────────────────────────────────────

post_review \
  "Patrick Dolan" "patrick.dolan@birdeyetest.com" 2 \
  1785628800000 \
  "I wanted to like this place more than I did. The food is genuinely tasty but the pricing has crept up significantly. A meal for two with drinks and a starter came to $95 before tip. For a casual dining restaurant without white-tablecloth service, that's hard to justify. I'd come more often if the pricing reflected the casual setting."

post_review \
  "Kezia Oduya" "kezia.oduya@birdeyetest.com" 4 \
  1786665600000 \
  "Great food and I think the value is fair for what you get. Had the lamb special and it was generous on portion and full of flavor. Service was warm and efficient. My only minor note is that the dessert menu is overpriced compared to the mains — $14 for a small slice of cake felt steep. But the overall meal was a solid 4 stars."

# ── FOOD QUALITY – CONTINUED (15 more) ───────────────────────────────────────

post_review \
  "Amy Chen" "amy.chen@birdeyetest.com" 1 \
  1784678400000 \
  "Ordered the grilled chicken and it was visibly undercooked in the center — pink throughout and cold inside. I flagged it immediately and the server said the kitchen would 'check'. A replacement came out but it had been microwaved, dry on the outside and still questionable inside. Serious food safety concern."

post_review \
  "Paul Brennan" "paul.brennan@birdeyetest.com" 2 \
  1784851200000 \
  "Every single dish at our table of four arrived cold. The pasta was clumped together, the soup had a film on top, and the steak had clearly been sitting. The kitchen must be holding plates instead of sending them out as they're ready. Food actually good under the temperature problem but nearly inedible as served."

post_review \
  "Mia Osei" "mia.osei@birdeyetest.com" 1 \
  1785196800000 \
  "Found a long hair wrapped into my pasta. When I brought it up, the server was apologetic but the manager never came over. No discount, no replacement offered — just an apology and a shrug. For a food establishment this is a hygiene failure, not just bad luck."

post_review \
  "James Liu" "james.liu@birdeyetest.com" 2 \
  1785369600000 \
  "The menu photos show generous, beautifully plated dishes. What arrived at the table was noticeably smaller and nowhere near as presentable. The portion looks like it was cut specifically to photograph well and then scaled back. At these prices I expect what I see in the picture."

post_review \
  "Rachel Kim" "rachel.kim@birdeyetest.com" 1 \
  1785801600000 \
  "The tomato soup was essentially warm water with a faint tomato flavor. No seasoning, no richness, tasted like it came from a can and was diluted further. The bread side was stale. Absolutely not worth $12. I couldn't even finish it."

post_review \
  "Danny Patel" "danny.patel@birdeyetest.com" 2 \
  1785974400000 \
  "Ordered the calamari starter and the edges were burnt while the inside was barely cooked — a textbook temperature problem. The dipping sauce was fine. This is a simple dish that shouldn't require finesse, but it still came out wrong. If the kitchen can't get appetizers right, I don't trust the mains."

post_review \
  "Sofia Guerrero" "sofia.guerrero@birdeyetest.com" 2 \
  1786233600000 \
  "The sea bass was rubbery in a way that tells you it was overcooked and probably left sitting. Good seasoning but the texture was off enough that I left most of it. For a $28 fish entrée the execution should be better. Won't order seafood here again."

post_review \
  "Ethan Walsh" "ethan.walsh@birdeyetest.com" 1 \
  1784160000000 \
  "Ordered a molten lava cake and it was completely frozen in the center. Not 'warm lava' frozen — ice crystal frozen. They must have microwaved it from frozen and it didn't heat through. This is the kind of thing that ruins an otherwise acceptable meal. Sent it back."

post_review \
  "Hannah Mbeki" "hannah.mbeki@birdeyetest.com" 2 \
  1784246400000+3600000 \
  "Multiple dishes tasted like they came from a freezer meal rather than a kitchen. The vegetables were mushy in the way frozen veg gets when reheated carelessly. I've been to this restaurant three times and the most recent visit quality has dropped sharply. Something has changed in the kitchen."

post_review \
  "Chris Svensson" "chris.svensson@birdeyetest.com" 3 \
  1784592000000+7200000 \
  "The food quality is very inconsistent — my last visit was great, this one was average at best. The ribeye was cooked right but the sauce was oversalted. My partner's pasta was good. A three-star experience when it should be four or five. Hard to rely on a restaurant when you never know what to expect."

post_review \
  "Natalie Brooks" "natalie.brooks@birdeyetest.com" 4 \
  1784937600000+3600000 \
  "The pulled pork sandwich was outstanding — tender, smoky, and the house slaw gave it a great crunch. Clearly made fresh and cooked low and slow. Paired with the sweet potato fries it was one of the better lunches I've had. Will definitely reorder this."

post_review \
  "Oliver Grant" "oliver.grant@birdeyetest.com" 5 \
  1785283200000+7200000 \
  "The lamb rack with roasted root vegetables was simply one of the best dishes I've had at a casual restaurant. The meat was cooked perfectly, the jus was rich, and the portion was more than generous. I don't give five stars easily but this earned it."

post_review \
  "Maya Foster" "maya.foster@birdeyetest.com" 4 \
  1785628800000+3600000 \
  "Really appreciated that the vegetables in my bowl were clearly fresh — crisp, vibrant, and actually seasoned. So rare to find a restaurant that doesn't treat vegetables as an afterthought. The grain bowl was simple but executed really well."

post_review \
  "Xavier Rodriguez" "xavier.rodriguez@birdeyetest.com" 5 \
  1785888000000+7200000 \
  "Best carbonara I've had outside of Italy. The pasta was cooked al dente, the sauce was rich and silky without being heavy, and the guanciale was crispy. The chef clearly knows what they're doing with this dish. Came back twice in one week specifically for it."

post_review \
  "Zoe Kimura" "zoe.kimura@birdeyetest.com" 4 \
  1786060800000+3600000 \
  "The autumn seasonal menu is a great idea and the butternut squash risotto delivers. Warm, well-balanced flavors and a generous portion. Would love to see more rotating specials like this rather than the same permanent menu items."

# ── WAIT TIME – CONTINUED (12 more) ──────────────────────────────────────────

post_review \
  "Aaron Mills" "aaron.mills@birdeyetest.com" 1 \
  1784332800000+3600000 \
  "We came for my wife's birthday — had a reservation, arrived on time, and waited 95 minutes for our food to arrive after being seated. By the time it came everyone's mood had completely soured. The evening we'd planned was basically ruined. No acknowledgment from the manager, no gesture of goodwill. Unacceptable."

post_review \
  "Beth Connors" "beth.connors@birdeyetest.com" 2 \
  1784419200000+7200000 \
  "Had a reservation for 7pm, wasn't seated until 7:40. When I mentioned the reservation the host said 'we're running a bit behind' and didn't explain further. If you're going to offer reservations they need to mean something. Otherwise just say you're walk-in only."

post_review \
  "Carl Santos" "carl.santos@birdeyetest.com" 1 \
  1784764800000+3600000 \
  "Quoted 15 minutes for a table at the door. Waited 55 minutes. During that wait I watched at least three tables clear and not be seated for 10+ minutes. No urgency from the host team whatsoever. By the time we sat down I'd already decided not to return."

post_review \
  "Diana Chen" "diana.chen@birdeyetest.com" 2 \
  1785110400000+7200000 \
  "Sunday brunch is chaos here. Zero coordination between front of house and kitchen. Our table got seated but then waited 20 minutes before anyone even brought water. When the food finally came one dish was wrong. Brunch should be the easiest service to manage — this wasn't."

post_review \
  "Eric Olafsson" "eric.olafsson@birdeyetest.com" 2 \
  1785542400000+3600000 \
  "Could see our food sitting under the heat lamp for at least 15 minutes before a server picked it up. By the time it reached us the fries were limp and the burger was barely warm. The issue wasn't the kitchen — it was the floor. Someone needs to be watching that pass."

post_review \
  "Fiona MacLeod" "fiona.macleod@birdeyetest.com" 1 \
  1785715200000+7200000 \
  "Ordered online for pickup at 12:30. Got a confirmation. Arrived at 12:35. They hadn't even started my order. Waited 45 more minutes at the counter. The online system clearly doesn't communicate with the kitchen. If you offer pickup ordering, you need to actually prepare orders when they're promised."

post_review \
  "George Adewale" "george.adewale@birdeyetest.com" 2 \
  1786147200000+3600000 \
  "Saturday dinner service is a disaster. Two-hour wait from sitting to clearing. No mid-meal communication, water glasses empty for long stretches, and we had to ask for the bill three times. The food was decent but the experience made it feel not worth the hassle."

post_review \
  "Hannah Soo" "hannah.soo@birdeyetest.com" 2 \
  1786233600000+3600000 \
  "Nobody updated us during a 40-minute wait for food. In that entire time not one server came by to say 'still working on it' or offer bread or water. Just complete silence. A 30-second check-in would change how the wait feels entirely."

post_review \
  "Ian Douglas" "ian.douglas@birdeyetest.com" 1 \
  1786492800000+3600000 \
  "Had a confirmed reservation and they gave our table to a walk-in because we arrived seven minutes late — in traffic. The host told us we'd need to go on the wait list again. When I showed the confirmation email she said 'I'm sorry but we can only hold five minutes.' That policy should be disclosed when you book."

post_review \
  "Julia Strickland" "julia.strickland@birdeyetest.com" 2 \
  1786579200000+3600000 \
  "This is my fourth visit and every single time the wait for food is longer than 40 minutes regardless of how busy the restaurant looks. It's not a capacity problem — I've been here when it's half empty and still waited 45 minutes. Something systemic is wrong with the kitchen throughput."

post_review \
  "Kyle Turner" "kyle.turner@birdeyetest.com" 5 \
  1785456000000+3600000 \
  "Genuinely impressed by how fast service was on a Tuesday lunch. Seated immediately, drink order taken within two minutes, food on the table in under 20 minutes. Everything was fresh and hot. This is how a restaurant should run."

post_review \
  "Lena Park" "lena.park@birdeyetest.com" 4 \
  1785974400000+3600000 \
  "Came with a large group of nine and was genuinely impressed by the efficiency. All dishes came out together within 35 minutes, everything was correct, and the server coordinated it all without seeming stressed. That level of execution for a big table is rare."

# ── ORDER ACCURACY – CONTINUED (10 more) ─────────────────────────────────────

post_review \
  "Miguel Costa" "miguel.costa@birdeyetest.com" 1 \
  1784505600000+3600000 \
  "I have a severe tree nut allergy and noted it on the online order form AND told the server when seated. The dish arrived with crushed walnuts. I was lucky I checked before eating. This is a life-threatening failure, not just inconvenience. A restaurant needs a reliable system for communicating allergen flags to the kitchen."

post_review \
  "Nina Owens" "nina.owens@birdeyetest.com" 2 \
  1784678400000+7200000 \
  "Ordered the mushroom risotto and received the chicken piccata. Different dish, different price, completely different dietary consideration — I'm vegetarian. The server swapped it without fuss but the damage was done and I was now behind everyone else at the table waiting for the right dish."

post_review \
  "Oscar Lindqvist" "oscar.lindqvist@birdeyetest.com" 1 \
  1784851200000+7200000 \
  "Ordered the clearly labeled vegan pasta. It arrived with shredded parmesan and what appeared to be pancetta mixed in. When I asked, the server confirmed there was pancetta. I'm vegan for ethical reasons and this is exactly the kind of carelessness that breaks trust. The kitchen needs to read tickets more carefully."

post_review \
  "Penny Walsh" "penny.walsh@birdeyetest.com" 2 \
  1785196800000+7200000 \
  "Three out of four side dishes were missing from our takeout order. The mains were there, the drinks were there, but no sides. When I called to report it I was offered a future credit which doesn't help when the sides were intended for that meal. Checking orders before bagging them would be a simple fix."

post_review \
  "Quinn Archer" "quinn.archer@birdeyetest.com" 2 \
  1785369600000+7200000 \
  "My online order through the restaurant's own website was almost completely wrong when it arrived. The substitutions were random — I got a salad instead of soup, a chicken dish instead of fish. It looked like someone misread or mixed up tickets. For a restaurant with its own online ordering system this shouldn't happen."

post_review \
  "Ray Nkosi" "ray.nkosi@birdeyetest.com" 2 \
  1785628800000+7200000 \
  "My order was delivered to the wrong table and the other table started eating it before realizing. The server sorted it out but that meant I waited another 20 minutes for a new plate. Simple table number management should prevent this."

post_review \
  "Sara Johansson" "sara.johansson@birdeyetest.com" 3 \
  1785801600000+3600000 \
  "One of our four dishes came out wrong — got the regular version of a dish when I'd ordered the gluten-free version. The server caught it when I mentioned it and the kitchen re-made it quickly. The resolution was handled well, but I shouldn't have had to flag it myself."

post_review \
  "Tomas Herrera" "tomas.herrera@birdeyetest.com" 1 \
  1786060800000+7200000 \
  "Delivery order arrived with half the items missing and the bag seal was broken. The items that did arrive were cold and one container had leaked inside the bag. When I reached out through the app I was told to 'reorder' for a refund — that's not how this should work."

post_review \
  "Uma Patel" "uma.patel@birdeyetest.com" 4 \
  1786320000000+3600000 \
  "Had a complicated order — multiple modifications and one item substitution — and everything came out exactly right. The server even read back the order to confirm before submitting. That level of attention prevents exactly the kind of errors I've seen others complain about."

post_review \
  "Victor Blanc" "victor.blanc@birdeyetest.com" 5 \
  1786665600000+3600000 \
  "Came with a group of twelve with several different dietary requirements. Every single order came out correct — vegan options properly made, one nut allergy clearly handled, and even a very specific 'no garlic' request honored. The kitchen executed perfectly under pressure."

# ── STAFF SERVICE – CONTINUED (10 more) ──────────────────────────────────────

post_review \
  "Wendy Ho" "wendy.ho@birdeyetest.com" 1 \
  1784246400000+7200000 \
  "When I brought a valid complaint about the wrong dish to the manager, she was dismissive and implied it was my fault for 'not being clearer.' I was clear — it was on the ticket. A manager who deflects and argues instead of listening to feedback is a bigger problem than any bad dish."

post_review \
  "Xander Obi" "xander.obi@birdeyetest.com" 2 \
  1784419200000+3600000 \
  "Our server took our order and then seemingly forgot we existed. We went 30 minutes without a check-in, had to ask another server for refills, and waited 15 minutes after finishing to flag someone down for the bill. Service this inattentive isn't rude — it's just absent."

post_review \
  "Yasmin Rahimi" "yasmin.rahimi@birdeyetest.com" 1 \
  1784592000000+3600000 \
  "When I gently told the server the dish wasn't what I'd ordered, he argued with me and said I 'must have misheard.' He eventually swapped it but the defensive attitude throughout was off-putting. Guests should not have to fight to get correct service."

post_review \
  "Zack Malone" "zack.malone@birdeyetest.com" 2 \
  1784764800000+7200000 \
  "The server spent more time chatting with colleagues near the kitchen than checking on tables. Our water sat empty, we had to flag someone down twice, and the server didn't appear to notice or care. I understand restaurant work is demanding but this was a visible indifference to the tables."

post_review \
  "Abby Chen" "abby.chen@birdeyetest.com" 2 \
  1785024000000+3600000 \
  "I asked the server a question about the menu and she spoke to me in a tone that felt condescending — slow and over-explained, as if I couldn't understand a normal response. Might be unintentional, but it left a bad impression. Staff training on how to engage with guests would help."

post_review \
  "Ben Okafor" "ben.okafor@birdeyetest.com" 1 \
  1785283200000+3600000 \
  "Called to make a reservation and the person who answered was dismissive and rushed — gave me no options, was unclear about the process, and hung up before confirming. First interaction with the restaurant and it was already off-putting. Didn't end up booking."

post_review \
  "Clara Davis" "clara.davis@birdeyetest.com" 5 \
  1785456000000+7200000 \
  "Our server noticed my daughter wasn't eating much and asked if something was wrong with her dish — completely unprompted. She swapped it for something else the kitchen made specially. That's a level of attentiveness you can't train easily. It made our whole visit special."

post_review \
  "Diego Morales" "diego.morales@birdeyetest.com" 5 \
  1785715200000+3600000 \
  "The general manager came by our table mid-meal just to check in — not prompted by a complaint, just genuine interest in how we were doing. He knew the menu well enough to recommend a dessert wine and was charming without being over the top. Leadership like that sets the tone for the whole staff."

post_review \
  "Emma Scott" "emma.scott@birdeyetest.com" 4 \
  1785888000000+3600000 \
  "Our server noticed from our reservation notes it was our anniversary and quietly arranged for a small complimentary dessert with a handwritten note. We hadn't asked for anything. That kind of thoughtful service is what separates a restaurant from a great restaurant."

post_review \
  "Frank Osei" "frank.osei@birdeyetest.com" 4 \
  1786406400000+3600000 \
  "The server was exceptionally attentive without being intrusive — water topped up, courses timed perfectly, and he caught a kitchen mistake on an appetizer before it even reached our table. That's the level of floor management that builds loyal regulars."

# ── CLEANLINESS – CONTINUED (7 more) ─────────────────────────────────────────

post_review \
  "Gina Patel" "gina.patel@birdeyetest.com" 1 \
  1784332800000+7200000 \
  "Our cutlery was visibly dirty — dried food on the forks and a water stain pattern on the knife that indicated it had been washed and dried in the machine without actually being cleaned first. Sent them back and the replacements were also not fully clean. Cutlery handling needs attention."

post_review \
  "Hector Ruiz" "hector.ruiz@birdeyetest.com" 1 \
  1784678400000+3600000 \
  "The bathroom was in a genuinely shocking state for a restaurant at this price point. No soap in the dispenser, paper all over the floor, and one toilet wasn't flushing properly. How a restaurant keeps its public bathroom reflects on how seriously it takes overall cleanliness."

post_review \
  "Iris Kim" "iris.kim@birdeyetest.com" 2 \
  1784937600000+7200000 \
  "The menus were sticky throughout — like they'd been wiped with a damp cloth over grease without actually cleaning. Handed mine back and asked for a clean one. The replacement was the same. Small detail but it sets the tone for the whole meal."

post_review \
  "Jake Murphy" "jake.murphy@birdeyetest.com" 1 \
  1785110400000+3600000 \
  "Spotted what was unmistakably a cockroach near the baseboard behind the host stand as we were being seated. I told the host and his response was to say 'we have an exterminator come monthly.' That's not a reassuring answer. This is a health code issue. We left immediately and reported it."

post_review \
  "Karen Zhao" "karen.zhao@birdeyetest.com" 2 \
  1785542400000+7200000 \
  "The seat cushions at our booth had visible food debris and one had what looked like dried sauce that hadn't been cleaned between seatings. We had to ask for a table change. Dining room cleanliness between turns needs to be part of a consistent routine, not optional."

post_review \
  "Leo Nakamura" "leo.nakamura@birdeyetest.com" 5 \
  1786147200000+7200000 \
  "One of the cleanest restaurants I've been to. Floors, tables, bathrooms — all spotless. Even the condiment holders on the table were clean and full. You can tell they take sanitation seriously, which is the kind of thing that makes me want to come back."

post_review \
  "Maria Santos" "maria.santos@birdeyetest.com" 4 \
  1786579200000+7200000 \
  "Pleasantly surprised by how clean the open kitchen looked during a brief view from the counter. Clean surfaces, organized stations, chefs in proper attire. A visible kitchen that looks professional inspires real confidence in the food. They're clearly running a tight operation back there."

# ── VALUE FOR MONEY – CONTINUED (6 more) ─────────────────────────────────────

post_review \
  "Nick Torres" "nick.torres@birdeyetest.com" 2 \
  1784505600000+7200000 \
  "Paid $4.50 for a fountain soda and there were no free refills — I had to pay for each one. That's not clearly stated on the menu. At a sit-down restaurant with entrees at $20+ you at minimum expect beverage refills. Felt like a deliberate nickel-and-diming."

post_review \
  "Olivia Banks" "olivia.banks@birdeyetest.com" 2 \
  1784851200000+3600000 \
  "Found a service charge and a 'kitchen fee' on my bill that weren't disclosed upfront or on the menu. When I asked, the server said they were standard. They might be standard somewhere but they need to be disclosed before I order. Will check the bill in full next time before ordering."

post_review \
  "Pedro Alves" "pedro.alves@birdeyetest.com" 1 \
  1785369600000+3600000 \
  "Desserts are $13-16 for very small plates. The chocolate tart I ordered was about two bites. For that price I expect something that takes more than 90 seconds to eat. The mains are reasonably priced but the dessert menu feels like a separate, exploitative operation."

post_review \
  "Quinn Bishop" "quinn.bishop@birdeyetest.com" 2 \
  1785801600000+7200000 \
  "Left feeling that the price-to-experience ratio is way off for what this restaurant delivers. The food was fine but not remarkable, the service was average, and the atmosphere is nothing special. There are better meals at similar prices within a half-mile. Hard to justify coming back at these rates."

post_review \
  "Rose Martinez" "rose.martinez@birdeyetest.com" 5 \
  1786233600000+7200000 \
  "The happy hour menu is genuinely one of the best deals in the area. Half-price appetizers, $6 cocktails, and everything we ordered during that window was high quality. It didn't feel like happy hour food — it felt like the full menu at a discount. Will be a regular for happy hours."

post_review \
  "Sam Cho" "sam.cho@birdeyetest.com" 4 \
  1786665600000+7200000 \
  "The weekday lunch special — two courses for $19 — is excellent value. Got a soup and a pasta and both were generous portions with good quality. If they offered this on weekends it would be very popular. Great way to try the menu without committing to dinner prices."

# ── ONLINE ORDERING / DELIVERY (6 reviews) ───────────────────────────────────

post_review \
  "Tim Foster" "tim.foster@birdeyetest.com" 1 \
  1784160000000+7200000 \
  "Ordered delivery and the food arrived cold — not slightly cool, but cold enough that it had clearly been sitting for a long time. The delivery window on the app said 30-40 minutes and it arrived in 70. No updates, no apology from the driver. The restaurant needs to control delivery timing more tightly."

post_review \
  "Una Bergstrom" "una.bergstrom@birdeyetest.com" 2 \
  1784678400000+5400000 \
  "The estimated time on the online order was 25 minutes. It took an hour and fifteen. The food when it arrived was edible but this wasn't a one-off — this is the third time a quoted time was off by 40+ minutes. If you can't reliably estimate prep time, either fix the system or quote a higher buffer."

post_review \
  "Val Okeke" "val.okeke@birdeyetest.com" 2 \
  1785196800000+5400000 \
  "The delivery packaging is poor — the bags aren't sealed properly and my soup had partially spilled inside the bag. Anything with liquid needs to be in a sealed container or a proper bag, not balanced in an open bowl with a flimsy lid. The food underneath it was also soaked."

post_review \
  "Will Mayer" "will.mayer@birdeyetest.com" 1 \
  1785715200000+5400000 \
  "My order was cancelled 10 minutes before the quoted pickup time with no explanation — just a refund notification and no message. I'd already driven to the restaurant. When I arrived and asked what happened they said the system canceled it automatically. I still don't know why. No one offered to re-make it."

post_review \
  "Xena Park" "xena.park@birdeyetest.com" 2 \
  1786060800000+5400000 \
  "The online menu shows prices that are different from the in-store menu — the online version is higher on several items with no explanation. When I asked at pickup they said 'the website has a convenience fee.' That needs to be disclosed clearly upfront, not discovered after you've already placed the order."

post_review \
  "Yara Hassan" "yara.hassan@birdeyetest.com" 4 \
  1786492800000+7200000 \
  "Online ordering was smooth — clean interface, accurate item descriptions, and a realistic pickup time that was actually met. Food was packaged well and still hot on arrival. This is how online ordering should work and it's rarer than it should be. Would definitely use it again."

# ── MENU VARIETY / DIETARY OPTIONS (5 reviews) ───────────────────────────────

post_review \
  "Zara Gupta" "zara.gupta@birdeyetest.com" 1 \
  1784332800000+5400000 \
  "The menu claims to have 'vegan-friendly options' but every vegan-labeled dish came with cheese or dairy-based sauce when I asked for details. Two items that looked vegan on the surface contained honey. The labeling needs to be accurate. Marketing toward dietary preferences you haven't actually catered for is misleading."

post_review \
  "Adam Reyes" "adam.reyes@birdeyetest.com" 2 \
  1784764800000+5400000 \
  "As someone with celiac disease, the gluten-free section of the menu is exactly two items — a salad and a grilled chicken plate. When I asked whether there were other items that could be modified, the server wasn't confident and had to go ask the kitchen three separate times. A properly designed GF menu with staff trained on it would make a real difference."

post_review \
  "Bella Johnson" "bella.johnson@birdeyetest.com" 2 \
  1785369600000+5400000 \
  "The menu is almost identical to what it was two years ago when this place opened. No seasonal specials, no rotating items, nothing to come back for if you've already tried everything. Restaurants that evolve their menu give regulars a reason to return. This one seems to be resting on its opening lineup."

post_review \
  "Carlos Wu" "carlos.wu@birdeyetest.com" 3 \
  1785888000000+5400000 \
  "The food is decent but the menu variety is limited for a restaurant that's been open this long. Most dishes follow the same flavor profile — heavy on salt, butter, and cream. Would love to see some lighter options and more international influence. Three stars because the execution is solid even if the range is narrow."

post_review \
  "Diana Osei" "diana.osei@birdeyetest.com" 4 \
  1786320000000+7200000 \
  "Came specifically because I heard they recently added a rotating seasonal section to the menu. The summer grain bowl was excellent — light, flavorful, and clearly made with peak-season produce. If they commit to keeping that section fresh and updated they'll have a great differentiator."

# ── ADDITIONAL GENERAL REVIEWS (9 reviews) ───────────────────────────────────

post_review \
  "Elias Petrov" "elias.petrov@birdeyetest.com" 1 \
  1784246400000+5400000 \
  "Everything that could go wrong did. Long wait, wrong dish, rude server, and then they added a charge we didn't recognize to the bill. Didn't argue because I just wanted to leave. Some restaurants have bad nights — this felt like a bad system."

post_review \
  "Faye Nguyen" "faye.nguyen@birdeyetest.com" 2 \
  1784592000000+5400000 \
  "I've given this restaurant two chances and both times the experience left me disappointed — different problems each time (wait time first visit, wrong order second). The food has potential but the operations aren't reliable enough for me to risk a third visit."

post_review \
  "Gary Morris" "gary.morris@birdeyetest.com" 1 \
  1784937600000+5400000 \
  "Went for what was supposed to be a celebratory dinner and it was the opposite. Food took forever, my partner's dish had to be sent back, and the noise level from the kitchen was distracting the whole meal. When I mentioned the noise a server said 'that's just how it is.' We left without dessert."

post_review \
  "Hana Kobayashi" "hana.kobayashi@birdeyetest.com" 3 \
  1785283200000+5400000 \
  "Entirely average experience. Food was fine, service was adequate, nothing stood out positively or negatively. It's the kind of place you'd go if nothing else was available — not a destination. Three stars feels right because it genuinely lands in the middle of the scale on every dimension."

post_review \
  "Ivan Sousa" "ivan.sousa@birdeyetest.com" 2 \
  1785628800000+5400000 \
  "The Food House gets a lot of buzz locally but based on my visit I don't understand it. The food is mediocre, the service was indifferent, and the pricing doesn't match either. Maybe it's a consistency issue and others have had better visits. Mine was not worth the hype."

post_review \
  "Jade Williams" "jade.williams@birdeyetest.com" 5 \
  1785974400000+7200000 \
  "This is now our go-to neighborhood spot and we've been at least eight times. The food quality has been consistently strong, the staff know us by now, and the menu has enough variety that we haven't gotten bored. Reliable quality is underrated in restaurants — The Food House delivers it."

post_review \
  "Kevin Osei" "kevin.osei@birdeyetest.com" 5 \
  1786233600000+5400000 \
  "Brought a first-time visitor to the city here and it was a great choice. The food was excellent, the service warm and professional, and the atmosphere was lively but not overwhelming. They left saying it was the highlight of the trip. That's the best compliment a restaurant can get."

post_review \
  "Lily Chen" "lily.chen@birdeyetest.com" 4 \
  1786406400000+7200000 \
  "I recommend The Food House to friends specifically for the weekday experience — the service is attentive, the kitchen has time to cook things properly, and the atmosphere is calm enough to have a real conversation. Weekend visits are apparently a different story based on reviews but weekday dinners here are genuinely good."

post_review \
  "Marco Silva" "marco.silva@birdeyetest.com" 5 \
  1786665600000+5400000 \
  "Great family restaurant — brought three generations last Sunday and everyone found something they loved on the menu. The staff was patient with our elderly grandmother who needed a bit more time to decide, and gentle with the kids. The food was consistently good across all seven orders. Will be back."

echo ""
echo "✓ Done. 100 reviews created for The Food House (businessId: 1916697)"
echo "  ~75 negative/mixed (1-3 stars) | ~25 positive (4-5 stars)"
echo ""
echo "  AI Survey Themes These Reviews Will Surface:"
echo "  → Food quality (temperature, freshness, portion size, taste, consistency)"
echo "  → Wait time (dine-in, reservations, online pickup accuracy)"
echo "  → Order accuracy (modifications, dietary restrictions, allergens, missing items)"
echo "  → Staff friendliness, attentiveness, and conflict resolution"
echo "  → Cleanliness (dining room, utensils, bathrooms)"
echo "  → Value for money and pricing transparency"
echo "  → Online ordering and delivery experience"
echo "  → Menu variety and dietary accommodation"
