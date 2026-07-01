# NoDebuffNoLoot (TBC)

![NoDebuffNoLoot Logo](logo.png)

Addon designed to optimize raid performance in World of Warcraft TBC by strictly tracking critical debuffs on bosses.

## What does NoDebuffNoLoot do?

The addon identifies which essential debuffs (such as *Sunder Armor* or *Faerie Fire*) are missing from your target. Unlike other generic trackers, **NoDebuffNoLoot** allows you to assign each debuff to a specific raid player, making the responsibility for maintaining the debuff clear and visible to everyone.

## Information provided by the Addon

* **Dynamic Visual HUD**: A floating panel that shows icons for tracked debuffs customized by order of priority.
  * **Green (ACTIVE)**: The debuff is active and has enough time left (> 5s).
  * **Yellow (PENDING / EXPIRE)**: The debuff is not yet required (delay grace period active) or is about to expire (< 5s). Urgent renewal needed!
  * **Red Glow (MISSING)**: The debuff is strictly required during combat, grace period has expired, and it's missing.
* **Player Identification**: The HUD shows both the **Primary** and **Backup** assigned player's names next to each debuff.
* **Critical Alerts**:
  * **Visual**: The screen borders will pulse **Cyan** if a critical debuff assigned to you is missing during combat.
  * **Audio**: A "Raid Warning" sound will play to ensure you don't miss it.
  * **Chat**: A text log is printed to the chat window for post-combat review.
* **Convenience**:
  * **Minimap Icon**: Quick access to options via Right-Click, and Assignments via Shift-Click.
  * **Lock HUD**: Prevent accidental movement of the frame.
  * **Advanced Filters**: Hide assignments that aren't yours, restrict tracking to Boss encounters only, or show exclusively missing debuffs.

## Chat Commands

| Command | Action |
| :--- | :--- |
| `/ndnl` | Opens the configuration panel (Blizzard Menu). |
| `/ndnlsync` | Forces manual synchronization of assignments with all raid members using the addon. |

## Available Options

From the configuration panel (`/ndnl`), you can access general settings. However, clicking **Open Assignments Panel** gives you access to the core features:

1. **Manage Assignments**: A dynamic grid with autocomplete where you define the `Spell ID/Name`, the `Primary` person responsible, and a `Backup` player.
2. **Priorities**: Reorder rows using `^/v` to dictate HUD order and importance.
3. **Grace Period**: Configure a `Delay` in seconds for each spell to allow the tank/player time to apply it before alarms trigger.
4. **Announce to Raid**: Click the announce button to broadcast all assignments to Raid Warning and whisper individual players their specific roles.

## Tracked Debuffs by Class

| Class | Supported Spells |
| :--- | :--- |
| **Warrior** | Sunder Armor, Thunder Clap, Demoralizing Shout |
| **Druid** | Faerie Fire, Demoralizing Roar |
| **Hunter** | Hunter's Mark, Scorpid Sting |
| **Paladin** | Judgement of Light, Judgement of Wisdom, Judgement of the Crusader |
| **Warlock** | Curse of Elements, Curse of Recklessness, Curse of Weakness |

## Installation

1. Download the repository.
2. Copy the `NoDebuffNoLoot` folder into your `Interface/AddOns/` directory.
3. Ensure the libraries in the `Libs` folder are present.

---
