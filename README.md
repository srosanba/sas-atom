# Overview

Atom is a free text editor from GitHub. Much like TextPad, UltraEdit, and other text editors, there are many ways to customize Atom to play nicely with SAS. Continue reading if you're interested in learning more.

# Contents

1. <a href="#Install Atom">Install Atom</a>
1. <a href="#Editor Settings">Editor Settings</a>
1. <a href="#Package Settings">Package Settings</a>
1. <a href="#Adding Packages">Adding Packages</a>

<a name="Install Atom"/>

# Install Atom

If you'd like a little hand-holding, check out the Atom tuturials on YouTube from [LevelUpTuts](https://www.youtube.com/watch?v=WWwBQQOGllo&list=PLLnpHn493BHHf0w8uGu9NM8LPf498ZvL_).

On the other hand, you could skip the tutorials and go straight to the [download page](https://atom.io/).

Once Atom has been installed, use `File > Add Project Folder` to open a folder containing a SAS program. This should add a tree on the left side of Atom. From this tree, double-click on an individual SAS program to open it in Atom.

<a name="Editor Options"/>

# Editor Settings

Most of the default editor options are what you want. To change editor settings, select `File > Settings`. Options are sorted alphabetically. Here are a few options that I would recommend changing from the default.

1. Enable `Scroll Past End`.
1. Enable `Show Indent Guide`.
1. Set `Tab Length = 3`.
1. Set `Tab Type = soft`.

<a name="Package Settings"/>

# Package Settings

Packages allow you to extend the base functionality of Atom. Several packages come pre-installed. Each package has its own settings. Let's practice editing package settings. Select `File > Settings > Packages`. In the search box, type the package name and press Enter.

1. `autocomplete-plus`
   1. To disable autocomplete, select `Settings`. Disable `Show Suggestions on Keystroke`.

<a name="Adding Packages"/>

# Adding Packages

To get the most out of Atom for SAS, you will want to install the following packages. The more you install the nicer Atom will work for you.

1. `language-sas`
   1. This package adds SAS syntax highlighting. Once you've installed it the SAS file that you have open should look a little different.
1. `sublime-style-column-selection`
   1. This package allows you to edit multiple lines simultaneously.
      1. Use the Control key to create cursors in multiple random locations.
      1. Use the Alt key to create multiple cursors at the same location in several consecutive lines.
1. `atom-shell-commands`
   1. This package allows you to submit SAS jobs from within Atom.
      1. It requires you to edit your Atom `config` file, which is a `cson` file (next step). In `cson` files spaces matter, so you must copy/paste the lines **exactly** as presented. You have been warned!
   1. Once the package has been installed, open your config file by selecting `File > Config`. Open the `atom-shell-commands.cson` file included in this repository. Select all and copy/paste the commands at the end/bottom of the Atom `config.cson` file. Save and close `config.cson`.
   1. Test these updates by navigating to your SAS program and pressing `ctrl-shift-5`. This should result in some command-prompt-like lines being generated near the bottom of your Atom editor. After 10-15 seconds you should see a message indicating `[Finished in xx.xx seconds]`.
1. `related`
   1. This package allows you to open your LOG and LST files.
   1. Once the package has been installed, from the top menu select `Packages > Related > Edit related patterns`. Open the `related.cson` file included in this repository. Select all and copy/paste the commands at the end/bottom of the Atom `related-patterns.cson` file. Save and close `related-patterns.cson`.
   1. Test these updates by navigating to your SAS program and pressing `ctrl-shift-r`. This should result in a list including your LOG and LST file. Use the up/down arrows to select the file of interest and press Enter.
      1. Note: this feature only works if the SAS program has been opened as part of a project folder (i.e., if you can see the SAS/LOG/LST files in the tree at left). If you attempt the `ctrl-shift-r` command on a program which is not visible in the tree you will lock up Atom. You have been warned!
1. `file-watcher`
   1. This packages allows your LOG and LST files to update automatically.
   1. Once the package has been installed, select `Settings`. I would recommend you enable `Prompt on Change`.
   1. Test this update by opening your SAS, LOG, and LST files. Then run the SAS program. You should get some pop-ups.
