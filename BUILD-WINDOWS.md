# Building & Installing the Quadz Drone Mod (Windows) — Step by Step

This guide walks you through building the Quadz FPV drone mod for **Minecraft 26.1.2** on a
**Windows 10 or Windows 11 PC**, starting from a completely fresh computer — no programming
tools, no copy of the project, nothing.

It's written for someone who has **never used a command line before**. Every step tells you
exactly what to type and what you should expect to see.

> ⚠️ **Heads-up: this guide is untested.** The mod was built and verified on a Mac. These
> Windows instructions are our best understanding of what *should* work, but nobody has run
> them end-to-end yet. If you hit a wall, that's not your fault — note where it failed and
> send it back to whoever gave you this guide. The
> [Troubleshooting](#9-troubleshooting) section covers the most likely snags.

> ⏱️ **Time:** plan for about 30–60 minutes, most of which is the computer downloading
> things on its own while you wait.

---

## Table of contents

1. [A few things to know first](#1-a-few-things-to-know-first)
2. [Install Git (this also gives us "Git Bash")](#2-install-git-this-also-gives-us-git-bash)
3. [Install Java 25](#3-install-java-25)
4. [Open Git Bash](#4-open-git-bash)
5. [Tell the build where Java is](#5-tell-the-build-where-java-is)
6. [Download the project](#6-download-the-project)
7. [Build the mod](#7-build-the-mod)
8. [Install the mod into Minecraft](#8-install-the-mod-into-minecraft)
9. [(Optional) Just run a test client instead](#9-optional-just-run-a-test-client-instead)
10. [Troubleshooting](#10-troubleshooting)

---

## 1. A few things to know first

- We're going to use a program called **Git Bash**, which gets installed in Step 2. It's a
  window where you type commands instead of clicking buttons. It looks intimidating but
  you'll mostly just copy and paste.
- **Copy/paste is your friend.** For every command in this guide, copy the whole line, then
  paste it into Git Bash. **Pasting is different from other Windows apps:** in Git Bash you
  paste by **right-clicking** in the window (or pressing **Shift + Insert**). Ctrl+V does
  *not* work there. After pasting, press **Enter**.
- **You only press Enter once per command.** After that, the computer does the work.
  Sometimes it finishes instantly; sometimes it takes several minutes and prints a lot of
  text. **That text is normal** — you don't need to read or understand it.
- **Wait for the prompt to come back.** When a command finishes, you'll see a line ending
  with a `$` and a blinking cursor, waiting for your next command. If you don't see that
  yet, it's still working. Just wait.
- **Watch out for the User Account Control popup.** When you install things, Windows may
  show a blue/yellow popup asking *"Do you want to allow this app to make changes?"* — click
  **Yes**.

If something goes wrong, jump to [Troubleshooting](#10-troubleshooting) at the bottom.

---

## 2. Install Git (this also gives us "Git Bash")

**Git** downloads the project. Its installer also includes **Git Bash**, the command window
we'll use for everything else.

1. Go to **<https://git-scm.com/download/win>** in your web browser.
2. The download for **64-bit Git for Windows Setup** should start automatically (or click
   that link).
3. Open the downloaded file (it'll be named something like `Git-2.xx.x-64-bit.exe`).
4. Click **Yes** if Windows asks for permission.
5. **You can click "Next" through every screen of the installer and then "Install" — the
   default options are all fine.** Don't worry about the many checkboxes; the defaults work.
6. When it finishes, **uncheck** "View Release Notes" if it's there, and click **Finish**.

That's it. Git and Git Bash are now installed.

---

## 3. Install Java 25

**Java version 25** is the engine that builds and runs the mod. We'll use a free version
called **Eclipse Temurin**.

1. Go to **<https://adoptium.net/temurin/releases/?version=25&os=windows&arch=x64>** in your
   browser.
2. Look for **JDK 25** for **Windows x64**, and download the **`.msi`** installer (the
   `.msi` is the easy installer; avoid the `.zip`).
3. Open the downloaded `.msi` file and click **Yes** if asked for permission.
4. Click **Next** through the installer. **On the "Custom Setup" screen, there's an option
   to "Set JAVA_HOME variable" — if you see it, click the little dropdown next to it and
   choose "Will be installed on local hard drive."** This makes a later step easier. (If you
   don't see that option or aren't sure, that's okay — Step 5 covers it either way.)
5. Click **Next** → **Install** → **Finish**.

> 📝 **Remember roughly where it installed.** It's almost always a folder like:
> `C:\Program Files\Eclipse Adoptium\jdk-25.0.x.x-hotspot`
> The exact numbers (`25.0.x.x`) will vary. We'll need this folder in Step 5.

---

## 4. Open Git Bash

1. Click the **Start** menu (Windows logo, bottom-left).
2. Type **`Git Bash`**.
3. Click the **Git Bash** app that appears.

A window with a dark or light background and a `$` prompt opens. **Leave this window open**
— we'll use it for the rest of the guide.

> Reminder: to paste into this window, **right-click** (not Ctrl+V).

---

## 5. Tell the build where Java is

On Windows, the build needs to be told where Java 25 lives. We do this by setting something
called `JAVA_HOME`.

First, let's find the exact folder name, since the version numbers vary. Copy this command,
right-click to paste into Git Bash, and press **Enter**:

```sh
ls "/c/Program Files/Eclipse Adoptium/"
```

This lists what's inside the Adoptium folder. You should see one entry, something like
`jdk-25.0.2.7-hotspot`. **Note the exact name.**

Now set `JAVA_HOME` to that folder. Take the command below, **replace
`jdk-25.0.x.x-hotspot` with the exact name you just saw**, then paste and press Enter:

```sh
export JAVA_HOME="/c/Program Files/Eclipse Adoptium/jdk-25.0.x.x-hotspot"
```

Check that it worked by running:

```sh
"$JAVA_HOME/bin/java" -version
```

You should see output that includes `version "25` somewhere. If you do, Java is set up
correctly. ✅

> ⚠️ **Important:** this setting only lasts as long as this Git Bash window stays open. If
> you close Git Bash and come back later, you'll need to run that `export JAVA_HOME=...` line
> again before building. (To avoid that, see *"Make JAVA_HOME permanent"* in
> [Troubleshooting](#10-troubleshooting).)

---

## 6. Download the project

This downloads the project (and all of its sub-pieces) into your user folder. Paste and
press Enter:

```sh
git clone --recurse-submodules https://github.com/Cfretz244/LazuriteMC.git
```

> The `--recurse-submodules` part matters — it pulls in six smaller projects that the mod is
> built from. (If you forget it, the build script in the next step fixes it for you
> automatically.)

This prints progress lines for a minute or two. When your prompt is back, move *into* the
project folder:

```sh
cd LazuriteMC
```

`cd` means "change directory" — like double-clicking into the folder. Your prompt will now
show `LazuriteMC` in it. **Keep this window in this folder for the next step.**

---

## 7. Build the mod

One command builds everything. Paste and press Enter:

```sh
./build.sh
```

What to expect:

- **This takes a while the first time** — often 10–30 minutes — because the computer
  downloads a large set of build tools and Minecraft files. This is normal and only happens
  once; future builds are much faster.
- It prints a *lot* of text and may seem to pause on lines like `> Building...` or show
  download bars. **As long as text is moving, or the cursor sits there without your `$`
  prompt back, it's still working.** Don't touch anything.
- ☕ Great time for a coffee.

### How you know it worked

When it finishes successfully, the last thing it prints looks like this:

```
Done. Install these into your mods/ folder (plus Fabric API and GeckoLib 5.5.1+ from Modrinth):
... quadz-2.0.0.jar
... rayon-fabric-1.7.2+26.1.2.jar
```

Those two `.jar` files are the mod. They were placed in a folder named **`dist`** inside the
project. To open that folder in Windows File Explorer, run:

```sh
explorer dist
```

A File Explorer window opens showing two files:

- `quadz-2.0.0.jar`
- `rayon-fabric-1.7.2+26.1.2.jar`

**Leave this window open** — you'll grab these files in the next step.

> If the build stopped with a wall of red text instead of "Done.", see
> [Troubleshooting](#10-troubleshooting). A good first thing to try is running it again with:
> `./build.sh --clean`

---

## 8. Install the mod into Minecraft

The two files you just built are **Fabric mods** for **Minecraft 26.1.2 (Java Edition)**. To
play, you need Minecraft itself, the "Fabric Loader," and a few mod files together in one
folder.

### 8a. Make sure Minecraft 26.1.2 has been run once

In the regular **Minecraft Launcher**, launch **Minecraft 26.1.2 (Java Edition)** at least
once. You can quit as soon as you reach the main menu. This makes sure that version exists on
your PC.

### 8b. Install Fabric Loader

"Fabric Loader" is what lets Minecraft run mods.

1. Go to **<https://fabricmc.net/use/installer/>** in your browser.
2. Download the **Windows `.EXE`** installer.
3. Open the downloaded file.
   - Windows may show a blue **"Windows protected your PC"** box. If so, click
     **"More info"**, then **"Run anyway"**. (This warning is just because the file is new,
     not because it's harmful.)
   - Click **Yes** if asked for permission.
4. In the installer window:
   - Make sure the **"Client"** tab is selected.
   - Set **Minecraft Version** to **26.1.2**.
   - Leave the other options at their defaults.
   - Click **Install**.
5. Close the installer.

This creates a new profile in your Minecraft Launcher called something like
**"fabric-loader-26.1.2"**.

### 8c. Open your mods folder

Minecraft looks for mods in a special folder. Open it like this:

1. Press **Windows key + R** together. A small "Run" box appears.
2. Type exactly: **`%APPDATA%\.minecraft`**
3. Press **Enter**.

A File Explorer window opens. Look for a folder named **`mods`**.

- **If there's no `mods` folder, create one:** right-click in an empty area → **New** →
  **Folder** → name it exactly **`mods`** → press Enter.

Open the `mods` folder.

### 8d. Put four files into the mods folder

You need **four** `.jar` files in that `mods` folder:

1. **`quadz-2.0.0.jar`** — drag it from the `dist` File Explorer window (from Step 7) into
   the `mods` window.
2. **`rayon-fabric-1.7.2+26.1.2.jar`** — drag it from `dist` into `mods` too.
3. **Fabric API** — download from **<https://modrinth.com/mod/fabric-api>**. Pick the
   version for **Minecraft 26.1.2 / Fabric**, download it, then drag the downloaded `.jar`
   into the `mods` folder.
4. **GeckoLib (version 5.5.1 or newer)** — download from
   **<https://modrinth.com/mod/geckolib>**. Pick the version for **Minecraft 26.1.2 /
   Fabric**, download it, then drag the `.jar` into the `mods` folder.

> 💡 On Modrinth, to get the right file: click the mod's **"Versions"** tab, then use the
> filters to select game version **26.1.2** and loader **Fabric**. Download the top result.

When you're done, the `mods` folder should contain **four** `.jar` files.

### 8e. Play

1. Open the **Minecraft Launcher**.
2. Near the bottom, switch the profile dropdown to **"fabric-loader-26.1.2"**.
3. Click **Play**.

Once you're in a world in **Creative mode**, the drones should appear in the creative
inventory, and the FPV goggles should work. 🎉

---

## 9. (Optional) Just run a test client instead

If you only want to *see the mod working* without setting up the Minecraft Launcher and
copying files, there's a shortcut. After Step 7 has finished successfully **and in the same
Git Bash window** (so `JAVA_HOME` is still set), run:

```sh
cd Quadz
./gradlew runClient
```

This launches a special test version of Minecraft with the entire mod already loaded — no
Fabric Loader, no copying files. The first launch takes a few minutes.

> ⚠️ Three things matter here:
> - `JAVA_HOME` must still be set ([Step 5](#5-tell-the-build-where-java-is)). If you opened
>   a fresh Git Bash window, run the `export JAVA_HOME=...` line again first.
> - You must run `cd Quadz` **first**, before `./gradlew runClient`.
> - This only works **after** Step 7 (`./build.sh`) has completed at least once.
>
> To go back to the main project folder later, run `cd ..`.

---

## 10. Troubleshooting

**Pasting doesn't work in Git Bash**
Use **right-click** to paste (or **Shift + Insert**), not Ctrl+V.

**"bash: ./build.sh: No such file or directory" or "Permission denied"**
You're probably not in the project folder. Run `cd ~/LazuriteMC` and try again. If it still
says permission denied, run `chmod +x build.sh` once, then `./build.sh`.

**"error: JDK 25 not found" when running ./build.sh**
`JAVA_HOME` isn't set in this window. Re-do [Step 5](#5-tell-the-build-where-java-is) — run
the `export JAVA_HOME="..."` line (with your exact folder name), then `./build.sh` again.

**The `ls "/c/Program Files/Eclipse Adoptium/"` command shows nothing or an error**
Java didn't install where expected. Open the Start menu, search "Add or remove programs",
and confirm **"Eclipse Temurin JDK"** is listed. If it's installed somewhere else, use that
path in the `export JAVA_HOME=...` command instead. If it's not listed at all, redo
[Step 3](#3-install-java-25).

**The build (`./build.sh`) stopped with lots of red error text**
1. Make sure `JAVA_HOME` is set (see above) and you're in `~/LazuriteMC`.
2. Try a clean rebuild: `./build.sh --clean` (slower, fixes most stale-file issues).
If it still fails, copy the **last 20–30 lines** of red text and send them to whoever gave
you this guide — that's exactly what they need to help.

**Make JAVA_HOME permanent (so you don't re-type it each time)**
1. Press **Windows key**, type **"environment variables"**, click **"Edit the system
   environment variables"**.
2. Click **"Environment Variables…"**.
3. Under **"User variables"**, click **New…**.
4. Variable name: `JAVA_HOME`. Variable value: the **Windows-style** path to your JDK, e.g.
   `C:\Program Files\Eclipse Adoptium\jdk-25.0.x.x-hotspot` (use your exact folder name —
   note this uses backslashes `\`, not the `/c/...` form).
5. Click **OK** on every window. **Close and reopen Git Bash** for it to take effect. Now
   you can skip the `export JAVA_HOME=...` line in future sessions.

**I closed Git Bash / came back later and want to build again**
Open Git Bash, then run (re-setting Java unless you made it permanent above):
```sh
export JAVA_HOME="/c/Program Files/Eclipse Adoptium/jdk-25.0.x.x-hotspot"
cd ~/LazuriteMC
./build.sh
```
You do **not** need to reinstall Git or Java — those stay installed.

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
