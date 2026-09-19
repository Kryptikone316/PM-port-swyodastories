## Notes

Thanks to [sp00nznet](https://github.com/sp00nznet/YodaStoriesNG) for reimplementing the Desktop Adventures engine from scratch. It reads the original data file directly, so every playthrough is a genuinely new, always-solvable procedural adventure, same as the 1997 original.

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
