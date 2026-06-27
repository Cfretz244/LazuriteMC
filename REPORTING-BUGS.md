# How to Report a Bug

Found something broken while testing the Quadz drone mod? Here's how to tell us, step by
step. **You don't need to know anything technical** — just fill in some boxes on a web page.

The whole thing takes about two minutes, plus a moment to grab the log file (which is the
single most helpful thing you can give us).

---

## Step 1: Grab the log file *first* (do this while it's fresh)

The "log" is a file Minecraft writes that records what happened. It's the most useful thing
you can attach, especially if the game crashed. Grab it **before** you relaunch the game,
because Minecraft overwrites it on the next start.

### On a Mac

1. Open **Finder**.
2. In the very top menu bar, click **Go** → **Go to Folder…**
3. Copy and paste this exactly, then press **Return**:
   ```
   ~/Library/Application Support/minecraft/logs/latest.log
   ```
4. A file called `latest.log` will be highlighted. **Copy it to your Desktop** (drag it out,
   or right-click → Copy, then paste on the Desktop) so it doesn't get overwritten.
5. **If the game fully crashed** (closed itself with an error), also grab the newest file in:
   ```
   ~/Library/Application Support/minecraft/crash-reports/
   ```

### On Windows

1. Press **Windows key + R** together. A small box appears.
2. Type this and press **Enter**:
   ```
   %APPDATA%\.minecraft\logs
   ```
3. Copy the `latest.log` file to your Desktop so it doesn't get overwritten.
4. **If the game crashed**, also check the folder `%APPDATA%\.minecraft\crash-reports`.

### Take a screenshot too (if it's something you can see)

If the bug is visual — a black screen, a glitchy drone, a missing item — a screenshot helps
a lot.

- **Mac:** press **Shift + Command + 4**, then drag a box around the problem. The image lands
  on your Desktop.
- **Windows:** press **Windows key + Shift + S**, drag a box, then paste it into the bug
  report (or save it first).

---

## Step 2: Open the bug report form

1. Go to this page in your web browser:
   **<https://github.com/Cfretz244/LazuriteMC/issues/new/choose>**
2. If you're not signed in to GitHub, it'll ask you to sign in or make a free account. A
   GitHub account is free and takes a minute — you only need it once.
3. Click the green **"Get started"** button next to **🐞 Bug report**.

---

## Step 3: Fill it in

A form appears with a few boxes. Fill in what you can — **it's fine to leave some blank.**

- **What happened?** — describe it in plain words, like you'd text a friend.
- **What were you doing right before?** — a rough list of steps, if you remember.
- **What did you expect instead?** — optional.
- **How bad is it?** / **What computer?** — pick from the dropdowns.
- **Which build?** — if you're not sure, just leave it blank.
- **Log file and/or screenshots** — **drag the `latest.log` file (and any screenshots) from
  your Desktop straight into this box.** This is the important one.

---

## Step 4: Submit

Click the green **"Submit new issue"** button at the bottom. That's it! 🎉

We'll see it, and we may reply right on that page with questions or a fix. You'll get an
email when there's a response — just come back to the same page to read it and reply.

---

## Quick tips

- **One bug per report** is easiest to track. If you find three separate problems, three
  short reports beat one giant one.
- **No bug too small.** "This text is misspelled" and "the game won't launch" are both
  welcome.
- **Not sure if it's a bug?** Report it anyway, or just ask us in Discord.
