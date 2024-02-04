const std = @import("std");
const windows = std.os.windows;

// Only clipboard format we care about
pub const CF_UNICODETEXT: windows.UINT = 13;

pub extern "user32" fn OpenClipboard(hwnd: ?windows.HWND) callconv(windows.WINAPI) windows.BOOL;
pub extern "user32" fn CloseClipboard() callconv(windows.WINAPI) windows.BOOL;
pub extern "user32" fn IsClipboardFormatAvailable(format: windows.UINT) callconv(windows.WINAPI) windows.BOOL;
pub extern "user32" fn GetClipboardData(format: windows.UINT) callconv(windows.WINAPI) ?windows.HANDLE;
pub extern "kernel32" fn GlobalLock(hanlde: windows.HANDLE) callconv(windows.WINAPI) ?*anyopaque;
pub extern "kernel32" fn GlobalUnlock(hanlde: windows.HANDLE) callconv(windows.WINAPI) windows.BOOL;

pub fn main() !void {
    if (IsClipboardFormatAvailable(CF_UNICODETEXT) == 0) {
        return;
    }

    const success = OpenClipboard(null);
    if (success == 0) {
        return error.OpenClipboard;
    }
    defer _ = CloseClipboard();

    const h_data = GetClipboardData(CF_UNICODETEXT) orelse return error.GetClipboardData;
    const raw_data = GlobalLock(h_data) orelse return error.GlobalLock;
    defer _ = GlobalUnlock(h_data);

    const w_data: [*c]const u16 = @alignCast(@ptrCast(raw_data));
    const data = std.mem.span(w_data);
    // Utf8 str
    const string = try std.unicode.utf16leToUtf8Alloc(std.heap.page_allocator, data);

    // Remove carriage return
    const output = try std.mem.replaceOwned(u8, std.heap.page_allocator, string, "\r", "");

    const stdout = std.io.getStdOut();
    try stdout.writeAll(output);
}
