# Story formula (kid-safe)

Two formats. **Default: the family/school comedy story** of the user's reference shorts
(`references/reference-shorts.md`). The "In this world..." concept story (flookus) is the
second option. Both obey the hook rule below.

## THE HOOK: the first 2 seconds (mandatory, every short)
The user's rule: the first 2 seconds decide whether a viewer stays, so something that grabs
attention must be on screen and in the audio from frame 1. Never open on a slow wide
establishing shot, black, a logo, a title card or "Hi guys".
- **Line 1 is the hook** and starts at about 0.1 s (`lead_in` 0.1 in script.json). It is the
  most surprising, funny or dramatic sentence of the story, or a question it answers:
  "My grandma just got kicked out of cooking class.", "A grown-up just stole my baby
  sister's swing!", "In this world, you get a pet cloud on your tenth birthday."
  Keep it under ~8 words if possible; it must land inside 2 s.
- **Shot 1 (0-2 s) is the hook shot**: a close-up of the strongest moment of the story, a
  big expression (shocked, angry, dizzy, laughing) with a fast camera push-in, or a
  flash-forward to the climax ("cold open"), then cut back to the start.
- **Motion in the first frame**: the camera is already moving (push-in or whip) and the
  character is mid-gesture. No frozen first frame.
- **Sound at 0.0 s**: a short sting or whoosh under the first word (render.sh `HOOK_SFX`),
  music already playing.
- **First caption word on screen at 0.1 s** (captions follow the narration automatically
  once line 1 starts immediately).
- A cut to a new shot by ~2 s at the latest; then normal 1-2 s pacing.
- Check it: the frame at 0.0 s, 0.5 s, 1.0 s and 2.0 s of the final render must each show a
  face or action plus a caption word (`check_hook.sh`).

## Format A (default): family/school comedy (the reference shorts)
First-person kid narrator telling a funny, slightly absurd thing that happened with family
or at school; recurring cast (grandma, little sister, baby, chef dad, parent in glasses,
a rude "Karen", a teacher). Titles like "I Signed Up For Cooking Class", "A Karen Tried to
Steal My Baby Sister's Swing", "A Food Critic Came to Our Restaurant".

| Share | Beat | Example ("I Signed Up For Cooking Class") |
|---|---|---|
| 0-5% | **Hook**: the funniest / most shocking moment, said first | "I accidentally joined a cooking class full of grandmas." |
| 5-20% | **Setup**: who, where, the plan | "I just wanted to learn to make pancakes for my mom's birthday." |
| 20-45% | **Escalation**: 2-3 comic beats, each with a reaction close-up | grandmas judge the narrator's whisking; one copies their recipe |
| 45-70% | **Problem**: it goes wrong | the batter explodes, flour everywhere, the narrator is dizzy |
| 70-90% | **Twist / reversal** | the strict grandma turns out to be the head chef's mom and loves it |
| 90-100% | **Punchline or sweet ending + button line** | "Now I have twelve grandmas. And none of them can whisk." |

- Kid-safe conflict only: rude adults get comic comeuppance, nobody is hurt; no bullying
  played for laughs, no danger to kids.
- Lines are short and visual; almost every line gets a reaction face.

## Format B: "In this world..." concept story (flookus)

Source research: `/var/mnt/sda3/Roblox_Shorts/RESEARCH_flookus.md` (37 Shorts of @flookus,
Nov 2026). Read it when planning a new series or if the user asks why the format works.

### Why this format
On flookus, 2-2.5 min narrated "In this world..." stories had a median of ~760K views, against
~160K for short skits. What drives retention: the premise in the first sentence, steady
narration with no gaps, open loops that only pay off late, a twist at ~70%, and a last line
that calls back to the first. flookus talks at 240-275 wpm, but our viewers (kids) said 233
wpm was too fast, so we narrate at about 200.

### Beats (scale the times to the target length)
| Share of length | Beat | Pet Cloud example (43 s test) |
|---|---|---|
| 0-6% | **Premise**, said as line 1 = the title | "In this world, on your tenth birthday, you get your very own pet cloud." |
| 6-25% | **"You see..."** 2-4 quick, concrete, funny examples | Maya's cloud waters tomatoes; Leo's snows in July; Mr Patel's rains on his bald head |
| 25-45% | **"But mine..."** the narrator breaks the pattern | tiny, grey, never rains; "the broken cloud" |
| 45-65% | **Open loop / the event** | the summer it stopped raining, every cloud disappears |
| 65-85% | **Twist** that recasts the start | the tiny cloud grows: it was saving every drop |
| 85-95% | **Climax / payoff** | it rains, the whole town dances |
| 95-100% | **Callback last line** | "Everyone gets a cloud on their birthday. But the whole town got mine." |

Full-length (2-2.5 min) adds a secret or rule as an open loop, short dialogue lines in the
event, and a choice or sacrifice before the payoff.

## Writing rules
- One kid narrator, first person, who also says the dialogue. No intro, no outro, no
  "subscribe".
- Pace: 190-210 words per minute (narrate.py speed 0.96). Word budget: about 3.3 words per
  second of target length (45 s ~ 150 words; 2:20 ~ 460 words). Short sentences; each one
  should be showable.
- Every sentence should map to a picture, because each one becomes a 1.5-3 s shot.
- **Kid-safe & wholesome** (keep stories family-friendly, though YouTube upload is set to **"No, it's not made for kids"**): wonder, family, friendship and a twist; no death,
  gore, real danger to kids or scary imagery. Swap flookus-style deaths for loss, drought,
  being lost, being laughed at, and similar kid-sized stakes.
- Avoid lines Pocket TTS swallows: very short questions ("But mine?" was heard as "Bye-bye"),
  abbreviations (write "Mister", "Doctor"), and digits (write "sixty").
- Plain, original premises only. No real brands, Roblox games, or copyrighted characters.

## script.json
Write the sentences into `<short_dir>/script.json` (see `scripts/narrate.py` header). The
number after each sentence is the pause after it in seconds: 0.1 normal, 0.25-0.35 at a beat
change (lets young viewers catch up), 0.6 after the last line. Set `"lead_in": 0.1` so the
hook line starts immediately (the narrate.py default is now 0.1).
