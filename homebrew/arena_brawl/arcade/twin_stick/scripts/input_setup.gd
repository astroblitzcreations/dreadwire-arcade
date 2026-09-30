extends RefCounted
## Add namespaced controls only when missing; never overwrite the parent game's actions.
static func install() -> void:
    var keys = {
        "brawl_p1_left": KEY_A, "brawl_p1_right": KEY_D,
        "brawl_p1_up": KEY_W, "brawl_p1_down": KEY_S,
        "brawl_p1_fire": KEY_SPACE,
        "brawl_p2_left": KEY_LEFT, "brawl_p2_right": KEY_RIGHT,
        "brawl_p2_up": KEY_UP, "brawl_p2_down": KEY_DOWN,
        "brawl_p2_aim_left": KEY_J, "brawl_p2_aim_right": KEY_L,
        "brawl_p2_aim_up": KEY_I, "brawl_p2_aim_down": KEY_K,
        "brawl_p2_fire": KEY_U
    }
    for action in keys:
        if InputMap.has_action(action):
            continue
        InputMap.add_action(action, 0.22)
        var event = InputEventKey.new()
        event.physical_keycode = keys[action]
        InputMap.action_add_event(action, event)

static func deadzone(value: Vector2, threshold: float = 0.22) -> Vector2:
    var length = value.length()
    if length <= threshold:
        return Vector2.ZERO
    return value.normalized() * minf(1.0, (length - threshold) / (1.0 - threshold))
