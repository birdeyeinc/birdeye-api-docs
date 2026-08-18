#!/bin/bash
# Lumis Dental — Seed Reviews Script
# Run this on your local machine: bash create_lumis_reviews.sh
# 19 reviews: 15 negative (1-2 stars), 4 positive (4-5 stars)
# Themes: Wait Time (5), Billing/Insurance (4), Staff Attitude (3), Rough Treatment (3), Positive (4)
# Dates spread across the last 30 days

BASE_URL="https://paidreviews.birdeye.com/review/create/organic?clientIp=null&businessId=1916696"
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

# ── WAIT TIME THEME (5 reviews) ─────────────────────────────────────────────

post_review \
  "Sarah Mitchell" "sarah.mitchell@birdeyetest.com" 1 \
  1784246400000 \
  "I had a 9 AM appointment and wasn't seen until 10:25. Over an hour in the waiting room with zero updates from staff. The receptionist didn't even acknowledge the delay let alone apologize. My time matters too. Will not be coming back."

post_review \
  "David Kim" "david.kim@birdeyetest.com" 2 \
  1784592000000 \
  "Arrived 10 minutes early as they requested. Waited 50 minutes past my appointment time before being called back. When I politely asked how much longer it would be, the front desk seemed annoyed by the question. The dentist was pleasant once I finally got in — but the scheduling here is a real problem."

post_review \
  "Tyler Brooks" "tyler.brooks@birdeyetest.com" 2 \
  1784937600000 \
  "This is the third time in a row I've had to wait 40+ minutes past my scheduled appointment. I get that things occasionally run over but every single visit? They are clearly overbooking patients. A quick text or heads-up would go a long way but there's nothing — you just sit and wait."

post_review \
  "Kevin Park" "kevin.park@birdeyetest.com" 1 \
  1785283200000 \
  "Waited 55 minutes past my appointment. I had specifically blocked time off work for this and nobody came to update me once. When I finally asked the front desk, the response was a shrug. I ended up leaving without being seen. Complete waste of my day."

post_review \
  "Monica Patel" "monica.patel@birdeyetest.com" 2 \
  1785888000000 \
  "Brought my 8-year-old daughter for her first cleaning here. We sat in the waiting room for almost an hour past our appointment. She was already nervous about the dentist — the long wait made her anxiety so much worse by the time we got called back. Kids' appointments especially should be on time."

# ── BILLING / INSURANCE THEME (4 reviews) ────────────────────────────────────

post_review \
  "Robert Nguyen" "robert.nguyen@birdeyetest.com" 1 \
  1784419200000 \
  "I was quoted a specific price, my insurance was verified at check-in, and then six weeks later I received a bill for $420 more than expected. When I called to dispute it I was put on hold for 25 minutes and told they'd look into it. Three weeks later still no resolution. Awful billing department."

post_review \
  "Jason Burke" "jason.burke@birdeyetest.com" 1 \
  1784764800000 \
  "Complete insurance billing nightmare. They confirmed my coverage before treatment on a crown, then sent me a bill for the full amount saying my insurance denied it. I called my insurance company — the claim was submitted with the wrong code. I had to spend weeks going back and forth between both sides to get it sorted. Zero help from the office."

post_review \
  "Tom Watkins" "tom.watkins@birdeyetest.com" 2 \
  1785110400000 \
  "Got a surprise bill two months after my cleaning. Nobody mentioned at checkout that there would be additional fees. When I asked for an itemized breakdown it took two weeks to receive one, and two of the line items didn't match anything that was actually done during my visit. Very concerning."

post_review \
  "Carlos Reyes" "carlos.reyes@birdeyetest.com" 1 \
  1786147200000 \
  "The dentist pushed a treatment plan that would have cost me $2,800 out of pocket. Something felt off so I got a second opinion — I was told only one of the three procedures was actually necessary. I feel like I was being upsold aggressively. The front desk was also rude when I called to cancel. Never going back."

# ── STAFF ATTITUDE THEME (3 reviews) ─────────────────────────────────────────

post_review \
  "Priya Sharma" "priya.sharma@birdeyetest.com" 1 \
  1784332800000 \
  "The front desk staff was dismissive from the moment I walked in. I asked a simple question about paperwork and was met with an eye roll. The dental assistant barely spoke to me during the entire appointment. I understand the office is busy but basic courtesy shouldn't be too much to ask."

post_review \
  "Emily Dawson" "emily.dawson@birdeyetest.com" 2 \
  1785542400000 \
  "Called to reschedule due to a family emergency and the person on the phone was incredibly short with me. When I arrived for my new appointment, there were no notes on why I'd rescheduled and I had to re-explain everything from the start. Felt like I was inconveniencing them just by being a patient."

post_review \
  "Rachel Goldman" "rachel.goldman@birdeyetest.com" 2 \
  1786492800000 \
  "I felt completely rushed through my visit. The hygienist seemed impatient every time I asked a question about my care. I understand they have a full schedule but I'm paying significant money for this service and I expect to be treated like a person, not just a number to get through quickly."

# ── ROUGH TREATMENT / PAIN THEME (3 reviews) ─────────────────────────────────

post_review \
  "Michael Chen" "michael.chen@birdeyetest.com" 1 \
  1785715200000 \
  "Had a filling done here and it was genuinely painful. I raised my hand twice to signal I needed a break and both times the dentist acknowledged it but continued anyway. I was sore for almost a week. Previous fillings at other practices were never like this. Will not be returning."

post_review \
  "Diana Hoffman" "diana.hoffman@birdeyetest.com" 2 \
  1786320000000 \
  "My cleaning was unusually rough and my gums bled far more than they ever have before. When I mentioned it the hygienist said I just needed to floss more. I saw my regular dentist the following week and she noted my gums looked irritated and stressed from the procedure. Not comfortable recommending this place."

post_review \
  "Amanda Torres" "amanda.torres@birdeyetest.com" 1 \
  1786665600000 \
  "My son had a very upsetting experience. He was visibly distressed during the procedure and instead of pausing to help him calm down, they just kept going. He's now scared of dentists in a way he never was before. I understand kids can be difficult but compassion should be part of pediatric dental care."

# ── POSITIVE REVIEWS (4 reviews) ─────────────────────────────────────────────

post_review \
  "Linda Martinez" "linda.martinez@birdeyetest.com" 5 \
  1784505600000 \
  "Genuinely the best dental experience I've had in years. The doctor and hygienist took the time to walk me through everything, checked in frequently, and never made me feel rushed. The office is spotless and all the equipment looks modern. I was dreading this appointment but left feeling great about it."

post_review \
  "Stephanie Wilson" "stephanie.wilson@birdeyetest.com" 4 \
  1785024000000 \
  "Had an urgent crown issue on a Friday and they fit me in the same afternoon. Staff was professional, the dentist did excellent and careful work, and I got a follow-up call the next day to check on me. That kind of attention to the patient goes a long way. Very happy overall."

post_review \
  "Nicole Foster" "nicole.foster@birdeyetest.com" 4 \
  1785628800000 \
  "Clean office, friendly hygienist, and the dentist was thorough without being pushy. I appreciated that she laid out all my options and explained what was truly urgent versus what could wait. Pricing was explained clearly before anything was done. Would recommend to family and friends."

post_review \
  "James Kowalski" "james.kowalski@birdeyetest.com" 5 \
  1786406400000 \
  "I've been coming here for two years and have always had great care. The staff remembers my name, the wait times are usually reasonable, and the quality of work has been consistently good. Had a crown replaced recently and it fits perfectly. Glad I found this place."

echo ""
echo "✓ Done. 19 reviews created for Lumis Dental (businessId: 1916696)"
echo "  15 negative (1-2 stars) | 4 positive (4-5 stars)"
echo "  Themes: Wait Time · Billing/Insurance · Staff Attitude · Rough Treatment"
