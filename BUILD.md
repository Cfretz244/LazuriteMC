# Building & Installing the Quadz Drone Mod (Mac) — Step by Step

This guide walks you through building the Quadz FPV drone mod for **Minecraft 26.1.2**
on a Mac, **starting from a completely fresh computer** — no programming tools, no
copy of the project, nothing.

It's written for someone who has **never used Terminal or run a command before**. Every
step tells you exactly what to type and what you should expect to see. Take it slow; you
can't break anything by following along.

> ⏱️ **Time:** plan for about 30–60 minutes, most of which is the computer downloading
> things on its own while you wait.

---

## Table of contents

1. [A few things to know first](#1-a-few-things-to-know-first)
2. [Open the Terminal](#2-open-the-terminal)
3. [Install Homebrew (the "app store" for tools)](#3-install-homebrew-the-app-store-for-tools)
4. [Install Git and Java](#4-install-git-and-java)
5. [Download the project](#5-download-the-project)
6. [Build the mod](#6-build-the-mod)
7. [Install the mod into Minecraft](#7-install-the-mod-into-minecraft)
8. [(Optional) Just run a test client instead](#8-optional-just-run-a-test-client-instead)
9. [Troubleshooting](#9-troubleshooting)

---

## 1. A few things to know first

- **"Terminal"** is a built-in Mac app where you type commands instead of clicking
  buttons. We'll use it for most of this guide. It looks intimidating but you'll just be
  copying and pasting.
- **Copy/paste is your friend.** For every command in this guide, copy the whole line,
  click into the Terminal window, paste, and press **Return** (the Enter key).
- **You only press Return once per command.** After you press Return, the computer does
  the work. Sometimes it finishes instantly; sometimes it takes several minutes and prints
  a lot of text. **That text is normal** — you don't need to read or understand it.
- **Wait for the prompt to come back.** When a command is finished, Terminal shows your
  prompt again — a line ending in `$` or `%` with a blinking cursor, waiting for the next
  command. If you don't see that yet, the command is still running. Just wait.
- **Don't close the Terminal window** in the middle of a step.

If something goes wrong, jump to [Troubleshooting](#9-troubleshooting) at the bottom.

---

## 2. Open the Terminal

1. Press **Command (⌘) + Space** to open Spotlight search.
2. Type **`Terminal`**.
3. Press **Return**.

A window with a mostly-empty background and some text will open. That's it — leave this
window open; we'll use it for the next several steps.

---

## 3. Install Homebrew (the "app store" for tools)

**Homebrew** is a free tool that installs other tools for us. We need it to install Java
and Git.

Copy this entire line, paste it into Terminal, and press **Return**:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

What will happen:

- It may ask for your **Mac login password**. Type it and press Return. **You won't see
  the characters appear as you type — that's normal for password prompts.** Just type it
  and press Return.
- It may say "Press RETURN to continue". Press **Return**.
- It will print a lot of text and take a few minutes. Wait until your prompt comes back.

### Important: finish the Homebrew setup

When Homebrew finishes, it usually prints a short section titled **"Next steps"** with one
or two commands it asks you to run. **You must run those.** They look something like this
(yours may differ slightly — use the ones *your* screen shows):

```sh
echo >> ~/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Copy each line shown on **your** screen, paste, and press Return.

> If your screen did **not** show a "Next steps" section, you can safely run the three
> lines above anyway — they do no harm.

**Now close the Terminal window completely and open a new one** (repeat
[Step 2](#2-open-the-terminal)). This makes sure Homebrew is ready to use.

To confirm it worked, type this and press Return:

```sh
brew --version
```

You should see something like `Homebrew 4.x.x`. If you see that, you're good. If you see
`command not found`, see [Troubleshooting](#9-troubleshooting).

---

## 4. Install Git and Java

**Git** downloads the project; **Java** (specifically version 25) is what builds and runs
the mod. Install both at once. Copy, paste, press Return:

```sh
brew install git openjdk@25
```

This will download and install for a few minutes. Wait for your prompt to return.

> You don't need to set anything up for Java afterward — the build script finds it
> automatically. You also don't need to memorize where it went.

---

## 5. Download the project

This downloads the project (and all of its sub-pieces) into a folder in your home
directory. Copy, paste, press Return:

```sh
git clone --recurse-submodules https://github.com/Cfretz244/LazuriteMC.git
```

> The `--recurse-submodules` part matters — it pulls in six smaller projects that the mod
> is built from. (If you happen to forget it, the build script in the next step fixes it
> for you automatically, so don't worry too much.)

This prints progress lines and takes a minute or two. When it's done and your prompt is
back, move *into* the project folder by running:

```sh
cd LazuriteMC
```

`cd` means "change directory" — think of it as double-clicking into the folder. Your
Terminal prompt will now show `LazuriteMC` somewhere in it. **Keep this Terminal window in
this folder for the next step.**

---

## 6. Build the mod

This is the big one. One command builds everything. Copy, paste, press Return:

```sh
./build.sh
```

What to expect:

- **This takes a while the first time** — often 10–30 minutes — because the computer
  downloads a large set of build tools and Minecraft files. This is completely normal and
  only happens once; future builds are much faster.
- It will print a *lot* of text and may appear to pause on lines like `> Building...` or
  show download bars. **As long as text is moving or the cursor is sitting there without
  your prompt back, it's still working.** Don't touch anything.
- ☕ This is a great time to get a coffee.

### How you know it worked

When it finishes successfully, the very last thing it prints looks like this:

```
Done. Install these into your mods/ folder (plus Fabric API and GeckoLib 5.5.1+ from Modrinth):
-rw-r--r--  ...  quadz-2.0.0.jar
-rw-r--r--  ...  rayon-fabric-1.7.2+26.1.2.jar
```

Those two `.jar` files are the mod. They were placed in a folder named **`dist`** inside
the project. To open that folder in Finder so you can see them, run:

```sh
open dist
```

A Finder window opens showing two files:

- `quadz-2.0.0.jar`
- `rayon-fabric-1.7.2+26.1.2.jar`

**Leave this Finder window open** — you'll grab these files in the next step.

> If the build stopped with a wall of red text instead of the "Done." message, see
> [Troubleshooting](#9-troubleshooting). A good first thing to try is running it again
> with: `./build.sh --clean`

---

## 7. Install the mod into Minecraft

The two files you just built are **Fabric mods** for **Minecraft 26.1.2 (Java Edition)**.
To play with them, you need three things: Minecraft itself, the "Fabric Loader," and a few
mod files together in one folder.

### 7a. Make sure Minecraft 26.1.2 has been run once

In the regular **Minecraft Launcher**, make sure you've launched **Minecraft 26.1.2**
(Java Edition) at least once. You can quit out as soon as you reach the main menu. This
just makes sure that version exists on your computer.

### 7b. Install Fabric Loader

"Fabric Loader" is what lets Minecraft run mods.

1. Go to **<https://fabricmc.net/use/installer/>** in your web browser.
2. Download the installer (the **"Download installer (Universal/.JAR)"** link).
3. Open the downloaded file.
   - If your Mac says it can't open it because it's from an unidentified developer:
     **right-click** the file → choose **Open** → click **Open** again in the dialog.
4. In the installer window:
   - Make sure the **"Client"** tab is selected.
   - Set **Minecraft Version** to **26.1.2**.
   - Leave the other options at their defaults.
   - Click **Install**.
5. Close the installer.

This creates a new profile in your Minecraft Launcher called something like
**"fabric-loader-26.1.2"**.

### 7c. Open your mods folder

Minecraft looks for mods in a special folder. Open it by going back to **Terminal** and
running:

```sh
mkdir -p ~/Library/Application\ Support/minecraft/mods && open ~/Library/Application\ Support/minecraft/mods
```

This creates the `mods` folder if it doesn't exist and opens it in Finder. (An empty
window is expected if this is your first time.)

### 7d. Put four files into the mods folder

You need **four** `.jar` files in that `mods` folder:

1. **`quadz-2.0.0.jar`** — drag it from the `dist` Finder window (from Step 6) into the
   `mods` window.
2. **`rayon-fabric-1.7.2+26.1.2.jar`** — drag it from `dist` into `mods` too.
3. **Fabric API** — download from **<https://modrinth.com/mod/fabric-api>**. On that page,
   make sure you pick the version for **Minecraft 26.1.2**, download it, then drag the
   downloaded `.jar` into the `mods` folder.
4. **GeckoLib (version 5.5.1 or newer)** — download from
   **<https://modrinth.com/mod/geckolib>**. Again pick the version for **Minecraft
   26.1.2**, download it, and drag the `.jar` into the `mods` folder.

> 💡 On Modrinth, to get the right file: click the mod's **"Versions"** tab, then use the
> filters to select game version **26.1.2** and loader **Fabric**. Download the top result.

When you're done, the `mods` folder should contain **four** `.jar` files.

### 7e. Play

1. Open the **Minecraft Launcher**.
2. Near the bottom, switch the profile dropdown to **"fabric-loader-26.1.2"**.
3. Click **Play**.

Once you're in a world in **Creative mode**, the drones should appear in the creative
inventory, and the FPV goggles should work. 🎉

---

## 8. (Optional) Just run a test client instead

If you only want to *see the mod working* without setting up the real Minecraft Launcher
and copying files around, there's a shortcut. After the build in Step 6 has finished
successfully, run these two commands in Terminal:

```sh
cd Quadz
./gradlew runClient
```

This launches a special test version of Minecraft with the entire mod already loaded — no
Fabric Loader, no copying files, nothing else to install. The first launch takes a few
minutes.

> ⚠️ Two things matter here:
> - You must run `cd Quadz` **first**, so you're inside the `Quadz` folder before running
>   `./gradlew runClient`.
> - This only works **after** Step 6 (`./build.sh`) has completed at least once.
>
> When you want to go back to building or to the main project folder later, run `cd ..` to
> step back out of the `Quadz` folder.

---

## 9. Troubleshooting

**"command not found: brew" after installing Homebrew**
You probably skipped the "Next steps" / "finish the setup" part of
[Step 3](#3-install-homebrew-the-app-store-for-tools). Re-run the three `eval`/`echo` lines
from that step, then close and reopen Terminal.

**"command not found: git" or "command not found: java"**
Run `brew install git openjdk@25` again ([Step 4](#4-install-git-and-java)) and wait for it
to fully finish.

**The build (`./build.sh`) stopped with lots of red error text**
1. Make sure you're in the right folder: run `cd ~/LazuriteMC` and try again.
2. Try a clean rebuild: `./build.sh --clean` (this is slower but fixes most stale-file
   issues).
3. Make sure Java 25 installed: run `brew install openjdk@25` again.
If it still fails, copy the **last 20–30 lines** of the red text and send them to whoever
gave you this guide — that's exactly what they need to help.

**"permission denied: ./build.sh"**
Run this once, then try `./build.sh` again:
```sh
chmod +x build.sh
```

**I closed Terminal / came back later and want to build again**
Open a new Terminal, then run:
```sh
cd ~/LazuriteMC
./build.sh
```
You do **not** need to reinstall Homebrew, Git, or Java — those stay installed.

**I want the very latest version of the project before building again**
```sh
cd ~/LazuriteMC
git pull
git submodule update --init --recursive
./build.sh
```

**Minecraft crashes on launch with the mods installed**
Almost always this means one of the four files is the wrong version or missing. Double-check
that all four `.jar` files in your `mods` folder are the **26.1.2 / Fabric** versions, and
that both the Quadz and Rayon jars from `dist` are present.
