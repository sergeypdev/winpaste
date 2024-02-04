Windows has clip.exe, but doesn't have paste.exe. This tool aims to remedy that situation.

I use it as a neovim clipboard provider on windows like this:
```lua
if vim.fn.has "win32" == 1 then
  vim.g.clipboard = {
    name = "WindowsClipboard",
    copy = {
      ['+'] = 'clip.exe',
      ['*'] = 'clip.exe',
    },
    paste = {
      ['+'] = 'winpaste.exe',
      ['*'] = 'winpaste.exe',
    },
    cache_enabled = 0,
  }
end
```

## Building

1. Install [zig 0.12](https://ziglang.org/download/)
2. run `zig build -Doptimize=ReleaseSafe`

Exe will be in zig-out/bin/winpaste.exe
