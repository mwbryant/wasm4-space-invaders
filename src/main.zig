const w4 = @import("wasm4.zig");
const std = @import("std");
const math = std.math;

const smiley = [8]u8{
    0b11000011,
    0b10000001,
    0b00100100,
    0b00100100,
    0b00000000,
    0b00100100,
    0b10011001,
    0b11000011,
};

const bullet_sprite = [1]u8{
    0b00000000 };
const bullet_width = 1;
const bullet_height = 4;
const bullet_flags = w4.BLIT_1BPP; 

// ship
const ship_width = 20;
const ship_height = 21;
const ship_flags = 1; // BLIT_2BPP
const ship = [105]u8{ 0x55,0x55,0x14,0x55,0x55,0x55,0x42,0x96,0x81,0x55,0x55,0x52,0x96,0x85,0x55,0x55,0x56,0x96,0x95,0x55,0x55,0x50,0x00,0x05,0x55,0x65,0x40,0x00,0x01,0x59,0x75,0x00,0x00,0x00,0x5d,0x74,0x00,0x00,0x00,0x1d,0xfc,0x00,0x00,0x00,0x3f,0xfc,0x00,0x00,0x00,0x3f,0xfc,0x00,0x00,0x00,0x3f,0xf0,0x00,0x00,0x00,0x0f,0x00,0x00,0x14,0x00,0x00,0x00,0x04,0x55,0x10,0x00,0x00,0x04,0x55,0x10,0x00,0x00,0x04,0x55,0x10,0x00,0x00,0x35,0x55,0x5c,0x00,0x00,0x35,0x55,0x5c,0x00,0x00,0x35,0x55,0x5c,0x00,0x00,0x35,0x55,0x5c,0x00,0x40,0xd5,0x55,0x57,0x01 };

// enemy
const enemy_width = 8;
const enemy_height = 8;
const enemy_flags = 1; // BLIT_2BPP
const enemy_sprite = [16]u8{ 0x28,0x28,0x55,0x55,0x55,0x55,0x55,0x55,0x16,0x94,0x15,0x54,0x05,0x50,0x0c,0x30 };

const Enemy = struct {
    x: i16, y: i16, alive: bool
};

const enemy_spacing = 9;
const x_offset = 14;
var enemies = [24]Enemy{
    Enemy {.x = enemy_width + enemy_spacing - x_offset, .y = 3, .alive= true},
    Enemy {.x = (enemy_width + enemy_spacing)*2 - x_offset , .y = 3, .alive= true},
    Enemy {.x = (enemy_width + enemy_spacing)*3 - x_offset , .y = 3, .alive= true},
    Enemy {.x = (enemy_width + enemy_spacing)*4 - x_offset, .y = 3, .alive= true},
    Enemy {.x = (enemy_width + enemy_spacing)*5 - x_offset, .y = 3, .alive= true},
    Enemy {.x = (enemy_width + enemy_spacing)*6 - x_offset, .y = 3, .alive= true},
    Enemy {.x = (enemy_width + enemy_spacing)*7 - x_offset, .y = 3, .alive= true},
    Enemy {.x = (enemy_width + enemy_spacing)*8 - x_offset, .y = 3, .alive= true},

    Enemy {.x = enemy_width + enemy_spacing - x_offset, .y = enemy_height + enemy_spacing + 3, .alive= true},
    Enemy {.x = (enemy_width + enemy_spacing)*2 - x_offset , .y =enemy_height + enemy_spacing + 3, .alive= true},
    Enemy {.x = (enemy_width + enemy_spacing)*3 - x_offset , .y =enemy_height + enemy_spacing + 3, .alive= true},
    Enemy {.x = (enemy_width + enemy_spacing)*4 - x_offset, .y =enemy_height + enemy_spacing + 3, .alive= true},
    Enemy {.x = (enemy_width + enemy_spacing)*5 - x_offset, .y =enemy_height + enemy_spacing + 3, .alive= true},
    Enemy {.x = (enemy_width + enemy_spacing)*6 - x_offset, .y =enemy_height + enemy_spacing + 3, .alive= true},
    Enemy {.x = (enemy_width + enemy_spacing)*7 - x_offset, .y =enemy_height + enemy_spacing + 3, .alive= true},
    Enemy {.x = (enemy_width + enemy_spacing)*8 - x_offset, .y =enemy_height + enemy_spacing + 3, .alive= true},

    Enemy {.x = enemy_width + enemy_spacing - x_offset, .y =     (enemy_height + enemy_spacing )*2 + 3, .alive= true},
    Enemy {.x = (enemy_width + enemy_spacing)*2 - x_offset , .y =(enemy_height + enemy_spacing )*2 + 3, .alive= true},
    Enemy {.x = (enemy_width + enemy_spacing)*3 - x_offset , .y =(enemy_height + enemy_spacing )*2 + 3, .alive= true},
    Enemy {.x = (enemy_width + enemy_spacing)*4 - x_offset, .y = (enemy_height + enemy_spacing )*2 + 3, .alive= true},
    Enemy {.x = (enemy_width + enemy_spacing)*5 - x_offset, .y = (enemy_height + enemy_spacing )*2 + 3, .alive= true},
    Enemy {.x = (enemy_width + enemy_spacing)*6 - x_offset, .y = (enemy_height + enemy_spacing )*2 + 3, .alive= true},
    Enemy {.x = (enemy_width + enemy_spacing)*7 - x_offset, .y = (enemy_height + enemy_spacing )*2 + 3, .alive= true},
    Enemy {.x = (enemy_width + enemy_spacing)*8 - x_offset, .y = (enemy_height + enemy_spacing )*2 + 3, .alive= true},
};

const Bullet = struct {
    x: i16, y: i16, alive: bool
};

var enemy_x_movement: i16 = 1;

const x_timer_reset = 5;
const x_direction_timer_reset = x_timer_reset * 29;

var enemy_x_timer: i16 = x_timer_reset;
var enemy_x_change_direction_timer: i16 = x_direction_timer_reset;

var bullets = [8]Bullet{
    Bullet {.x = 0, .y = 0, .alive=false},
    Bullet {.x = 0, .y = 0, .alive=false},
    Bullet {.x = 0, .y = 0, .alive=false},
    Bullet {.x = 0, .y = 0, .alive=false},
    Bullet {.x = 0, .y = 0, .alive=false},
    Bullet {.x = 0, .y = 0, .alive=false},
    Bullet {.x = 0, .y = 0, .alive=false},
    Bullet {.x = 0, .y = 0, .alive=false},
    };

var x: i16 = 80;
const y: u16 = 160 - ship_height - 10;

var bullet_y : i16 =160;
var gun_cooldown: i16 = 0;

var lost = false;
var not_played = true;

export fn update() void {
    w4.PALETTE.* = .{
        0x746f76, // Grey
        0x951f15, // Red
        0xca3f14, // Orange
        0x1e1994, // Blue
    };
    if(lost) {
    w4.PALETTE.* = .{
        0x951f15, // Red
        0x746f76, // Grey
        0xca3f14, // Orange
        0x1e1994, // Blue
    };
        w4.DRAW_COLORS.* = 0b0000_0000_0000_0011;
        if (not_played) {
        w4.tone(100 | 2000 << 16, 60, 100, w4.TONE_NOISE | w4.TONE_MODE2);
        not_played = false;
        }
        w4.text("Loser!", 60, 10);
        w4.text("SKILL ISSUE!", 35, 20);
        return;
    }

    const gamepad = w4.GAMEPAD1.*;
    if (gamepad & w4.BUTTON_LEFT != 0) {
        x -= 1;
    }
    if (gamepad & w4.BUTTON_RIGHT != 0) {
        x += 1;
    }
    x = math.clamp(x, 0, 160-ship_width);

    gun_cooldown -= 1;
    if (gamepad & w4.BUTTON_1 != 0 and gun_cooldown < 0) {
        for (bullets) |bullet, index| {
            if (!bullet.alive) {
            //w4.tone(800, 5, 100, w4.TONE_TRIANGLE);
            w4.tone(800 | 200 << 16, 5, 100, w4.TONE_TRIANGLE);
                gun_cooldown = 15;
                bullets[index].alive = true;
                bullets[index].x = x + 18;
                bullets[index].y = y + 2;
                break;
            }
        }
        for (bullets) |bullet, index| {
            if (!bullet.alive) {
                gun_cooldown = 15;
                bullets[index].alive = true;
                bullets[index].x = x + 1;
                bullets[index].y = y + 2;
                break;
            }
        }
    }

    //DRAW_COLORS = COL3_COL2_COL1_COL0
    w4.DRAW_COLORS.* = 0b0010_0011_0000_0100;
    w4.blit(&ship, x, y, ship_width, ship_height, ship_flags);

    w4.DRAW_COLORS.* = 0b0000_0000_0000_0011;
    for (bullets) |bullet, index| {
        if (bullet.alive) {
            bullets[index].y -= 4;
            if (bullets[index].y < 0) {
                bullets[index].alive = false;
            }
            w4.blit(&bullet_sprite, bullet.x, bullet.y, bullet_width, bullet_height, bullet_flags);
        }
    }

    w4.DRAW_COLORS.* = 0b0010_0011_0100_0000;

    enemy_x_timer -= 1;
    enemy_x_change_direction_timer -= 1;
    var y_move: i16 = 0;
    if (enemy_x_change_direction_timer <= 0) {
        enemy_x_movement = -enemy_x_movement;
        y_move = 5;
        enemy_x_change_direction_timer = x_direction_timer_reset;
    }

    var alive = false;
    for (enemies) |enemy| {
        alive = alive or enemy.alive;
    }

    //if(!alive) {
    w4.DRAW_COLORS.* = 0b0000_0000_0000_0010;
    if(!alive) {
        w4.text("You're Winner", 31, 40);
        if (not_played) {
        w4.tone(100 | 2000 << 16, 60, 100, w4.TONE_TRIANGLE | w4.TONE_MODE2);
        not_played = false;
        }
        return;
    }

    for (enemies) |enemy, enemy_index| {
        for (bullets) |bullet, index| {
            if (enemy.alive and bullet.alive) {
            if (bullet.x > enemy.x and bullet.x < enemy.x + enemy_width
             and bullet.y > enemy.y and bullet.y < enemy.y + enemy_height){
            w4.tone(800 | 200 << 16, 20, 70, w4.TONE_NOISE);
                 bullets[index].alive = false;
                 enemies[enemy_index].alive = false;
             }
            }

        }
        if (enemy_x_timer <= 0) {
        enemies[enemy_index].x += enemy_x_movement;
        enemies[enemy_index].y += y_move;
        if (enemy.alive and enemies[enemy_index].y > 120) {
            lost = true;
        }
        }
        if (enemy.alive) {
            w4.DRAW_COLORS.* = 0b0010_0011_0100_0000;
            w4.blit(&enemy_sprite, enemy.x, enemy.y, enemy_width, enemy_height, enemy_flags);
        }
    }
    if(enemy_x_timer <= 0) {
        enemy_x_timer = x_timer_reset;
    }
}
