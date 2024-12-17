const std = @import("std");

const Token = union(enum) {
    @"mul(",
    number: u64,
    @",",
    @")",
    @"do()",
    @"don't()",
    invalid,

    pub fn digit(self: Token) ?u64 {
        return switch (self) {
            .number => |n| n,
            else => null,
        };
    }
};

const digits = "0123456789";

pub const Tokenizer = struct {
    buffer: []const u8,
    pos: usize = 0,

    pub fn next(self: *Tokenizer) ?Token {
        if (self.buffer.len == self.pos) return null;
        a: switch (self.buffer[self.pos]) {
            'm' => {
                if (std.mem.startsWith(u8, self.buffer[self.pos..], @tagName(Token.@"mul("))) {
                    self.pos += @tagName(Token.@"mul(").len;
                    return .@"mul(";
                }
                self.pos += 1;
                if (self.buffer.len == self.pos) return null;
                continue :a self.buffer[self.pos];
            },
            'd' => {
                inline for (.{ Token.@"do()", Token.@"don't()" }) |token| {
                    if (std.mem.startsWith(u8, self.buffer[self.pos..], @tagName(token))) {
                        self.pos += @tagName(token).len;
                        return token;
                    }
                }
                self.pos += 1;
                if (self.buffer.len == self.pos) return null;
                continue :a self.buffer[self.pos];
            },
            ',' => {
                self.pos += 1;
                return .@",";
            },
            '0'...'9' => {
                const start = self.pos;
                const end = std.mem.indexOfNone(
                    u8,
                    self.buffer[self.pos..],
                    digits,
                ) orelse self.buffer.len;

                self.pos += end;

                return .{ .number = std.fmt.parseInt(u64, self.buffer[start..][0..end], 10) catch unreachable };
            },
            ')' => {
                self.pos += 1;
                return .@")";
            },
            else => {
                self.pos += 1;
                if (self.buffer.len == self.pos) return null;
                return .invalid;
            },
        }
    }
};

pub fn solution1(_: std.mem.Allocator, text: []const u8) !u64 {
    var iter = Tokenizer{ .buffer = text };
    var sum: u64 = 0;
    while (true) {
        // "mul("
        if (iter.next() orelse break != .@"mul(") continue;
        // "mul(239"
        const first = (iter.next() orelse break).digit() orelse continue;
        // "mul(239,"
        if (iter.next() orelse break != .@",") continue;
        // "mul(239,30"
        const second = (iter.next() orelse break).digit() orelse continue;
        // "mul(239,30)"
        if (iter.next() orelse break != .@")") continue;

        sum += first * second;
    }
    return sum;
}

pub fn solution2(_: std.mem.Allocator, text: []const u8) !u64 {
    var iter = Tokenizer{ .buffer = text };

    var sum: u64 = 0;
    var disabled = false;

    const states = [_]std.meta.Tag(Token){ .@"mul(", .number, .@",", .number, .@")" };
    var state_i: usize = 0;

    var first: u64 = 0;
    var second: u64 = 0;

    while (iter.next()) |token| {
        if (state_i == states.len) {
            sum += first * second;
            state_i = 0;
        }
        if (disabled or states[state_i] != token) {
            state_i = 0;
        }
        switch (token) {
            .@"do()" => {
                disabled = false;
            },
            .@"don't()" => {
                disabled = true;
            },
            .@"mul(", .@")", .@"," => {
                state_i += 1;
            },
            .number => |num| {
                if (state_i == 1)
                    first = num
                else
                    second = num;

                state_i += 1;
            },
            .invalid => {},
        }
    }
    return sum;
}
