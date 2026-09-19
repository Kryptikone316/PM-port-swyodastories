## Notes

Thanks to [sp00nznet](https://github.com/sp00nznet/YodaStoriesNG) for reimplementing the Desktop Adventures engine from scratch. It reads the original data file directly, so every playthrough is a genuinely new, always-solvable procedural adventure, same as the 1997 original.

## Game Data

This port ships no game content. You need `yodesk.dta` from your own legal copy of *Star Wars: Yoda Stories* (1997, LucasArts). It sits alongside the original `Yodesk.exe` on the install media or in an installed copy.

Copy it to `swyodastories/Yoda/yodesk.dta` (the `Yoda` folder is already there, just empty). The first four bytes of a valid file are the ASCII tag `VERS`; if you see `SZDD` instead, the file is still SZDD-compressed and needs decompressing first (Microsoft's own `EXPAND.EXE`, still bundled with Windows, reads the format natively).

## Sound (optional)

The game plays fine with no sound at all. If you want sound effects, copy the `SFX` folder from your own copy of the game (it sits right next to `YODESK.DTA`) to `swyodastories/Yoda/SFX`, keeping the original folder name and filenames as-is. Nothing else to configure - the game finds them automatically on the next launch.

## Controls

| Key | Action |
|--|--|
| D-Pad / Left Stick | Move |
| A | Action / Talk / Use selected item |
| B | Dismiss dialogue |
| X | Travel (use X-Wing) |
| Y | Show objective |
| L1 / R1 | Toggle weapon |
| L2 / R2 | Cycle inventory (selects which item A uses) |
| Start | Restart |
| Select | Quit |

## Compile

```bash
git clone https://github.com/sp00nznet/YodaStoriesNG.git
cd YodaStoriesNG

dotnet publish src/YodaStoriesNG.Engine/YodaStoriesNG.Engine.csproj \
  -c Release -r linux-arm64 \
  --self-contained true \
  -p:PublishSingleFile=false \
  -p:DebugType=none \
  -o publish
```

Delete `publish/libSDL2.so` before packaging; the target device already ships its own SDL2 and the bundled copy would shadow it.
