local enemy = ...

-- Mini Mowatulla: a small spider that comes from an egg.
-- This enemy is usually be generated by a bigger one.

local in_shell = nil

function enemy:on_created()

  self:set_life(2)
  self:set_damage(2)
  self:create_sprite("enemies/mini_mowatulla")
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_invincible()

  local sprite = self:get_sprite()
  sprite:set_animation("shell")
  in_shell = true
  sol.timer.start(self, 1000, function()
    self:break_shell()
  end)
end

-- The enemy was stopped for some reason and should restart.
function enemy:on_restarted()

  if in_shell then
    local sprite = self:get_sprite()
    sprite:set_animation("shell")
    local m = sol.movement.create("target")
    m:set_speed(64)
    self:start_movement(m)
  else
    local m = sol.movement.create("path_finding")
    m:set_speed(64)
    self:start_movement(m)
  end
end

-- Starts breaking the shell.
function enemy:break_shell()

  local sprite = self:get_sprite()
  self:stop_movement()
  sprite:set_animation("shell_breaking")
end

--  The animation of a sprite is finished.
function enemy:on_sprite_animation_finished(sprite, animation)

  -- if the shell was breaking, let the mini mowatulla go
  if animation == "shell_breaking" then
    sprite:set_animation("walking")
    self:snap_to_grid()
    self:set_default_attack_consequences()
    in_shell = false
    self:restart()
  end
end
