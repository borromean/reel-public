# Setting up Reel on someone's Mac — instructions for Claude

You are helping someone set up Reel, a local app that transcribes recordings
(through ElevenLabs) and shows them in the browser, word by word. README.md
explains everything it does; this file is the setup job, written for you.
Work through the steps in order, checking each one before moving on.

Ground rules:

- **Never see an API key.** Don't ask for one in chat, don't write one into a
  file or a command, don't print `.env`. The person pastes keys into Reel's
  ⚙ SETTINGS page in their browser themselves; you only check that they are
  *set* (`/api/settings` says so, without the key) and that a transcription
  works.
- Some steps are interactive (installing the command line tools, signing in
  to Google Drive). Ask the person to do those themselves; for a command, they
  can type `! <command>` in the prompt.
- Reel stores recordings in `~/Reel` and runs only on this Mac, at
  `http://127.0.0.1:8765` (the next free port if that one is taken; the
  startup line says which), bound to localhost, so nobody else on the network
  can reach it.

## 1. Tools and the code

Check what's there first (`command -v python3 git`, `python3 --version`):

- `python3` (3.9 or newer) and `git` come with Apple's command line tools. If
  either is missing, have them run `! xcode-select --install` and click
  through the dialog.
- Clone the repository they gave you into `~/reel` (or where they'd like it):

      git clone <repository URL> ~/reel

  Without git, they can download the ZIP from the repository page instead and
  unzip it there.

## 2. Optional extras

    cd ~/reel && bin/setup.sh

installs numpy (multi-mic recordings, cutting and splitting) and fetches
DeepFilterNet into `bin/` (denoised listening copies). Both are optional:
Reel runs without them. If numpy won't install, say what failed and move on.

## 3. Start Reel and add the keys

Start Reel in the background for now:

    cd ~/reel && python3 transcribe.py --no-browser

and open the page for them with `open http://127.0.0.1:<port>` (port from the
startup line). Reel says on the page that it needs an ElevenLabs key.

Ask where their ElevenLabs key comes from:

- **Their own account** — before creating a key or transcribing anything,
  they must opt out of training: elevenlabs.io → **Terms and Privacy → Data
  use**. The opt-out only covers audio sent *after* it's switched on, so it
  comes first. Then Developers → API keys → create one. Transcription needs a
  paid plan that includes speech to text.
- **A key someone gave them** — fine; the opt-out is the account owner's to
  check.

The Anthropic key (titles and the filler clean-up; optional) comes from
console.anthropic.com → API keys.

They click **⚙ ADD YOUR API KEYS** (or **⚙ SETTINGS**), paste each key and
press SAVE: Reel checks it with the service and says whether it was accepted,
then keeps it in `.env` next to `transcribe.py`. Check, printing only this:

    curl -s http://127.0.0.1:<port>/api/settings | python3 -c "import json,sys; print({k: v['set'] for k, v in json.load(sys.stdin)['keys'].items()})"

## 4. Test a transcription

Make a few seconds of speech and hand it to the running Reel (naming a file
while Reel runs passes it to that Reel):

    say -o /tmp/reel-test.m4a --data-format=aac "This is a test of Reel transcription."
    cd ~/reel && python3 transcribe.py --no-browser /tmp/reel-test.m4a

Poll `curl -s http://127.0.0.1:<port>/api/library` until the test item's
`status` is `ready` (usually under a minute). `error` explains a failure: a
missing or refused key, or ElevenLabs refusing (plan, quota). Then remove it:
`curl -s -X DELETE http://127.0.0.1:<port>/api/item/<id>` (it moves to
`~/Reel/archive`).

## 5. Optional: the Google Drive backup

Ask whether they want their recordings backed up to Google Drive. It works
through Google Drive for desktop: `ls ~/Library/CloudStorage` shows a
`GoogleDrive-…` folder when it's installed and signed in. If not, they install
it from https://www.google.com/drive/download/ and sign in (their part). Then,
in ⚙ SETTINGS, they tick **BACK UP TO GOOGLE DRIVE**; Reel picks the Drive
folder by itself (FOLDER shows which, when there are several accounts) and
backs up straight away. Check:

    curl -s http://127.0.0.1:<port>/api/settings | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['backup'], d['backup_dir'], d['backup_status'])"

`error` in the status says what's wrong; `last` is when the last round
finished. Tell them the backup isn't encrypted (it's as private as their
Drive) and never deletes anything there.

## 6. Hand it over

Stop your background Reel and tell them to start it themselves from now on,
in Terminal:

    cd ~/reel && python3 transcribe.py

It opens the browser and runs until Ctrl-C or the Terminal window closes. Then
tell them how to use it:

- **Recording.** ● RECORD on the page records the Mac's microphone; or drop
  audio files onto the page, or + ADD AUDIO.
- **Several mics, one conversation** (DJI Mic style, one transmitter per
  person: 32-bit float internal recording, clocks synced in the DJI app, loop
  recording off). Plug the transmitters in by USB while Reel runs and it
  copies their new recordings in, then deletes them from the mic once it has
  verified identical copies (`REEL_CLEAR_MIC=0` in `~/reel/.env` keeps them
  on the mic). Or drag *all* the files straight off the cards into
  `~/Reel/inbox/`, names unchanged. Reel matches files from the same
  conversation, aligns and mixes them, and transcribes the mix.
- **Reading.** Click any word to jump there; click a speaker's name to rename
  them; ✂ CLEAN UP FILLER (with an Anthropic key) hides ums and fixes
  mis-heard words. ✎ PROMPT takes a sentence about who usually speaks and
  what about, which helps the clean-up; ✎ TERMS takes names and jargon.
- **Their files and the cloud.** Audio goes to ElevenLabs and transcript text
  to Anthropic for processing; each transcript is deleted from ElevenLabs as
  soon as it's saved locally. Everything else stays in `~/Reel` (and in their
  Drive, if they turned the backup on).
