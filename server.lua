extends CharacterBody2D

## --- PLAYER SCRIPT ---
## ... (Comments) ...
##
## -- MODIFIED (FIX): Skill canceling now works during attack windup.
## -- MODIFIED (FIX): Skill canceling now correctly stops the attack's
## -- hitbox timer, preventing race conditions.
## -- MODIFIED (FIX): Skill sequence now awaits the 'hitbox_timer.timeout'
## -- signal directly, ensuring the hit check is reliable.
## -- NEW: Player now auto-flips to face the enemy on hit
## -- and during skill execution.
## -- NEW: Hitbox now rotates to face the player's last 8-way
## -- move direction or the auto-faced target.
## -- NEW: Added "Slam Attack" (Down + M1) with AoE hitbox and cooldown.

# --- Tunable Variables ---
@export var speed: float = 45.0
@export var dash_speed: float = 200.0
@export var dash_duration: float = 0.1
@export var dash_cooldown: float = 0.8
@export var max_health: float = 100.0

# --- ADD THIS ---
@export_group("Effects")
@export var impact_effect: PackedScene
@export var impactcircle_effect: PackedScene


# --- Combat Stats ---
@export_group("M1 Combo")
@export var m1_damage: float = 10.0
@export var m1_knockback_force: float = 1.0
@export var m1_combo_window: float = 1.0 # Time to press next attack (ORIGINAL: 0.5)

@export_group("Flowing Flower Skill")
@export var flower_skill_damage: float = 5.0 # Damage per hit
@export var flower_skill_hits: int = 10
@export var flowerstart_knockback_force: float = 50.0
@export var flowerstart_skill_damage: float = 15.0
@export var flower_skill_hit_delay: float = 0.15 # Time between hits
@export var flower_skill_final_damage: float = 20.0
@export var flower_skill_knockback: float = 2.0
@export var flower_skill_final_knockback: float = 200.0
@export var flower_skill_cooldown: float = 1.0

@export_group("Custom Skill")
@export var custom_skill_cooldown: float = 1.0

@export_group("Custom2 Skill")
# Constants for this skill (you can add these to @export_group("Custom2 Skill"))
@export var CHARGE_TIME: float = 1.2
@export var DASH_SPEED_MULT: float = 1.0 # Dash 3x the normal dash speed
@export var DASH_DURATION: float = 0.1
@export var FLURRY_HITS: int = 4
@export var FLURRY_HIT_DELAY: float = 0.1
@export var FLURRY_DAMAGE: float = 10.0
@export var FINAL_BLAST_DAMAGE: float = 40.0
@export var FINAL_KNOCKBACK: float = 200.0
@export var custom2_skill_cooldown: float = 1.0
# --- END NEW ---

# --- NEW: Slam Attack ---
@export_group("Slam Attack")
@export var slam_damage: float = 25.0
@export var slam_knockback_force: float = 10.0
@export var slam_aoe_radius: float = 5.0 # The radius of the slam in pixels
@export var slam_attack_cooldown: float = 2.0
# --- END NEW ---

# --- ADDED: Camera Variables ---
@export_group("Camera")
@export var camera_smoothing_speed: float = 5.0
@export var camera_default_zoom: float = 1.3 # Default zoom (e.g., 1.0 = normal)
@export var camera_min_zoom_out: float = 0.5 # Max zoom out (e.g., 0.5 = 2x view)
@export var camera_combat_padding: float = 500.0 # Pixels of padding around targets

# --- State Machine ---
enum State { IDLE, MOVE, DASH, ATTACK, SKILL, HITSTUN, DEAD }
var current_state: State = State.IDLE
var current_health: float

# --- Node References ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hitbox: Area2D = $Hitbox
@onready var dash_timer: Timer = $DashTimer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
@onready var combo_timer: Timer = $ComboTimer
@onready var hitstun_timer: Timer = $HitstunTimer
@onready var flower_cooldown_timer: Timer = $FlowerCooldownTimer
@onready var custom_cooldown_timer: Timer = $CustomCooldownTimer
@onready var custom2_cooldown_timer: Timer = $Custom2CooldownTimer
# --- NEW: Slam Timer ---
@onready var slam_cooldown_timer: Timer = $SlamCooldownTimer

@onready var camera: Camera2D = $Camera2D
@onready var hitbox_timer: Timer = $HitboxTimer # <-- Make sure you added this Timer node

# --- Internal Variables ---
var last_facing_direction: Vector2 = Vector2.RIGHT # Used for flipping
var last_move_direction: Vector2 = Vector2.RIGHT # --- ADDED: For 8-way hitbox
var input_dir: Vector2 = Vector2.ZERO
var combo_count: int = 0
var hit_bodies: Array = [] # Tracks bodies hit in one attack
var is_in_attack_windup: bool = false

var is_custom2_on_cooldown: bool = false
var is_custom_on_cooldown: bool = false
var is_flower_on_cooldown: bool = false
# --- NEW: Slam Cooldown Flag ---
var is_slam_on_cooldown: bool = false

# --- NEW: Skill Target Variables ---
var skill_target: Node2D = null
var is_waiting_for_skill_hit: bool = false

# --- ADDED: Camera Effect Variables ---
var current_shake_intensity: float = 0.0
var current_zoom_punch: float = 1.0 # Multiplier (1.0 = no punch)
var camera_shake_tween: Tween
var camera_zoom_tween: Tween











var is_authority: bool:
	get: return !LowLevelNetworkHandler.is_server && owner_id == ClientNetworkGlobals.id

var owner_id: int

func _enter_tree() -> void:
	ServerNetworkGlobals.handle_player_position.connect(server_handle_player_position)
	ClientNetworkGlobals.handle_player_position.connect(client_handle_player_position)


func _exit_tree() -> void:
	ServerNetworkGlobals.handle_player_position.disconnect(server_handle_player_position)
	ClientNetworkGlobals.handle_player_position.disconnect(client_handle_player_position)


func server_handle_player_position(peer_id: int, player_position: PlayerPosition) -> void:
	if owner_id != peer_id: return

	global_position = player_position.position

	PlayerPosition.create(owner_id, global_position).broadcast(LowLevelNetworkHandler.connection)


func client_handle_player_position(player_position: PlayerPosition) -> void:
	if is_authority || owner_id != player_position.id: return

	global_position = player_position.position










func _ready() -> void:
	current_health = max_health
	# Connect signals
	dash_timer.timeout.connect(_on_dash_timer_timeout)
	dash_cooldown_timer.timeout.connect(_on_dash_cooldown_timer_timeout)
	combo_timer.timeout.connect(_on_combo_timer_timeout)
	hitstun_timer.timeout.connect(_on_hitstun_timer_timeout)
	flower_cooldown_timer.timeout.connect(_on_flower_cooldown_timer_timeout)
	custom_cooldown_timer.timeout.connect(_on_custom_cooldown_timer_timeout)
	custom2_cooldown_timer.timeout.connect(_on_custom2_cooldown_timer_timeout)
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	animated_sprite.animation_finished.connect(_on_animation_finished)
	
	# --- NEW: Connect Slam Timer ---
	slam_cooldown_timer.timeout.connect(_on_slam_cooldown_timer_timeout)

	# --- MODIFIED: Connect the hitbox timer ---
	hitbox_timer.timeout.connect(deactivate_hitbox)

	# Hitbox should be disabled until we attack
	hitbox.monitoring = false
	hitbox.monitorable = false

	# --- ADDED: Initialize Camera ---
	if camera:
		camera.position_smoothing_enabled = true
		camera.position_smoothing_speed = camera_smoothing_speed
		camera.zoom = Vector2(camera_default_zoom, camera_default_zoom)
	else:
		print("WARNING: Player script missing Camera2D child node.")


func _physics_process(delta: float) -> void:
	if !is_authority: return
	
	
	match current_state:
		State.IDLE:
			handle_idle_state(delta)
		State.MOVE:
			handle_move_state(delta)
		State.DASH:
			handle_dash_state(delta)
		State.ATTACK:
			handle_attack_state(delta)
		State.SKILL:
			handle_skill_state(delta)
		State.HITSTUN:
			handle_hitstun_state(delta)
		State.DEAD:
			velocity = Vector2.ZERO

	move_and_slide()
	
	PlayerPosition.create(owner_id, global_position).send(LowLevelNetworkHandler.server_peer)


func _process(delta: float) -> void:
	_update_camera(delta)


func _update_camera(delta: float) -> void:
	if not camera:
		return

	var target_zoom = Vector2(camera_default_zoom, camera_default_zoom)
	var target_position = global_position

	if skill_target != null and is_instance_valid(skill_target):
		target_position = (global_position + skill_target.global_position) / 2.0
		var viewport_size = get_viewport_rect().size
		var distance_vec = (global_position - skill_target.global_position).abs()
		var required_width = distance_vec.x + camera_combat_padding
		var required_height = distance_vec.y + camera_combat_padding
		var zoom_x = viewport_size.x / required_width
		var zoom_y = viewport_size.y / required_height
		var new_zoom_level = min(zoom_x, zoom_y)
		new_zoom_level = clamp(new_zoom_level, camera_min_zoom_out, camera_default_zoom)
		target_zoom = Vector2(new_zoom_level, new_zoom_level)

	camera.global_position = target_position

	var final_target_zoom = target_zoom * current_zoom_punch
	camera.zoom = camera.zoom.lerp(final_target_zoom, delta * camera_smoothing_speed * 1.5)

	var shake_offset = Vector2.ZERO
	if current_shake_intensity > 0.0:
		shake_offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * current_shake_intensity

	camera.offset = camera.offset.lerp(shake_offset, delta * 20.0)


func trigger_camera_effects(shake_amount: float, zoom_punch_scale: float, duration: float) -> void:
	if not camera:
		return

	if camera_shake_tween and camera_shake_tween.is_valid():
		camera_shake_tween.kill()

	camera_shake_tween = create_tween()
	camera_shake_tween.tween_property(self, "current_shake_intensity", 0.0, duration)\
					.from(shake_amount)\
					.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	if camera_zoom_tween and camera_zoom_tween.is_valid():
		camera_zoom_tween.kill()

	camera_zoom_tween = create_tween()
	camera_zoom_tween.tween_property(self, "current_zoom_punch", zoom_punch_scale, duration * 0.3)\
					.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	camera_zoom_tween.tween_property(self, "current_zoom_punch", 1.0, duration * 0.7)\
					.set_delay(duration * 0.3)


# --- State Handling Functions ---

func handle_idle_state(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, speed * delta * 20.0)
	animated_sprite.play("idle")

	input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir != Vector2.ZERO:
		current_state = State.MOVE
		return

	check_for_actions()


func handle_move_state(delta: float) -> void:
	input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if input_dir != Vector2.ZERO:
		velocity = input_dir.normalized() * speed
		update_animation_and_flip(input_dir)
		last_move_direction = input_dir.normalized() # --- ADDED: Store the 8-way direction
	else:
		current_state = State.IDLE
		return

	check_for_actions()


func handle_dash_state(delta: float) -> void:
	pass


# --- MODIFIED: Fixed skill canceling logic ---
func handle_attack_state(delta: float) -> void:
	velocity = Vector2.ZERO

	# --- MODIFIED: Skill cancel check now has priority ---
	# Allow canceling an attack (even windup) into a skill
	if Input.is_action_just_pressed("skill1") and not is_flower_on_cooldown:
		start_flower_skill()
		return # Exit attack state, enter skill state

	if Input.is_action_just_pressed("skill2") and not is_custom_on_cooldown:
		start_customskill()
		return # Exit attack state, enter skill state
		
	if Input.is_action_just_pressed("skill3") and not is_custom2_on_cooldown:
		start_custom2skill()
		return # Exit attack state, enter skill state
	
	# --- NEW: Allow canceling into Slam Attack ---
	if Input.is_action_just_pressed("attack") and Input.is_action_pressed("ui_down") and not is_slam_on_cooldown:
		start_slam_attack()
		return
	# --- END NEW ---

	# --- FIX: Block *new attacks* while windup is running ---
	if is_in_attack_windup:
		return

	if Input.is_action_just_pressed("attack"):
		if combo_count < 4:
			start_m1_combo()


func handle_skill_state(delta: float) -> void:
	velocity = Vector2.ZERO


func handle_hitstun_state(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, velocity.length() * 2.5 * delta)


# --- Action Checks ---

func check_for_actions() -> void:
	# DASH
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer.is_stopped():
		start_dash()
		return

	# --- MODIFIED: Check for skill FIRST for priority ---
	if Input.is_action_just_pressed("skill3") and not is_custom2_on_cooldown:
		start_custom2skill()
		return
	
	if Input.is_action_just_pressed("skill2") and not is_custom_on_cooldown:
		start_customskill()
		return

	if Input.is_action_just_pressed("skill1") and not is_flower_on_cooldown:
		start_flower_skill()
		return

	# --- NEW: Check for Slam Attack (Down + M1) ---
	if Input.is_action_just_pressed("attack") and Input.is_action_pressed("ui_down") and not is_slam_on_cooldown:
		start_slam_attack()
		return
	# --- END NEW ---

	# ATTACK (M1)
	if Input.is_action_just_pressed("attack"):
		start_m1_combo()
		return


# --- Movement and Animation ---

func update_animation_and_flip(direction: Vector2) -> void:
	animated_sprite.play("run")

	if direction.x != 0:
		last_facing_direction.x = direction.x

	if last_facing_direction.x < 0:
		animated_sprite.flip_h = true
	elif last_facing_direction.x > 0:
		animated_sprite.flip_h = false


func start_dash() -> void:
	current_state = State.DASH
	animated_sprite.play("dash")

	# --- MODIFIED: Get fresh input for 8-way dash ---
	var dash_input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var dash_vector: Vector2

	if dash_input != Vector2.ZERO:
		dash_vector = dash_input.normalized()
	else:
		# No input, dash in the last direction we moved
		dash_vector = last_move_direction
	
	last_move_direction = dash_vector # Store this as the new last direction
	# --- END MODIFICATION ---

	velocity = dash_vector * dash_speed

	dash_timer.start(dash_duration)
	dash_cooldown_timer.start(dash_cooldown)

	collision_shape.disabled = true


func _on_dash_timer_timeout() -> void:
	velocity = Vector2.ZERO
	collision_shape.disabled = false
	if current_state == State.DASH:
		current_state = State.IDLE


func _on_dash_cooldown_timer_timeout() -> void:
	print("Dash ready")


## --- ADDED: Auto-Flip Logic ---
# Helper function to flip the sprite to face a target node
func _face_target(target_node: Node2D) -> void:
	if not is_instance_valid(target_node):
		return

	var direction_to_target = (target_node.global_position - global_position).normalized()

	# --- ADDED: Update the hitbox direction ---
	if direction_to_target != Vector2.ZERO:
		last_move_direction = direction_to_target
	# --- END ADDED ---

	# Use a small threshold to prevent flipping if target is almost centered
	if direction_to_target.x > 0.1:
		animated_sprite.flip_h = false
		last_facing_direction.x = 1
	elif direction_to_target.x < -0.1:
		animated_sprite.flip_h = true
		last_facing_direction.x = -1
## --- END Auto-Flip Logic ---


# --- M1 Combo System ---

func start_m1_combo() -> void:
	current_state = State.ATTACK
	velocity = Vector2.ZERO
	combo_timer.stop()

	combo_count = (combo_count % 4) + 1

	animated_sprite.play("attack" + str(combo_count))

	is_in_attack_windup = true
	
	var attack_delay = 0.0
	match combo_count:
		1:
			attack_delay = 0.1
		2:
			attack_delay = 0.1
		3:
			attack_delay = 0.1
		4:
			attack_delay = 0.2

	await get_tree().create_timer(attack_delay).timeout

	is_in_attack_windup = false

	if current_state != State.ATTACK:
		return

	if combo_count == 4:
		activate_hitbox(m1_damage * 1.5, m1_knockback_force * 150, 0.2, "m1_combo_4")
	else:
		activate_hitbox(m1_damage, 0, 0.15, "m1_combo_hit")

	combo_timer.start(m1_combo_window)


func _on_combo_timer_timeout() -> void:
	combo_count = 0


func _on_animation_finished() -> void:
	var anim_name = animated_sprite.animation

	if anim_name.begins_with("attack") and current_state == State.ATTACK:
		current_state = State.IDLE


# --- Flowing Flower Skill ---

# --- MODIFIED: Added full cleanup logic ---
func start_flower_skill() -> void:
	# --- ADDED: Ensure ALL combo logic is reset when skill starts ---
	combo_count = 0
	combo_timer.stop()
	is_in_attack_windup = false

	# --- THIS IS THE CRITICAL FIX ---
	# Stop any pending hitbox timer (e.g., from a canceled attack)
	hitbox_timer.stop()
	# And force the hitbox to clean up *immediately*
	deactivate_hitbox()
	# --- END FIX ---

	current_state = State.SKILL
	is_flower_on_cooldown = true
	flower_cooldown_timer.start(flower_skill_cooldown)

	run_flower_skill_sequence()


# --- MODIFIED: Awaits the correct timer ---
func run_flower_skill_sequence() -> void:
	# 1. First Punch
	skill_target = null
	is_waiting_for_skill_hit = true # Open the hit window

	animated_sprite.play("skill_flower_start")
	

	# Activate the hitbox for 0.2s
	activate_hitbox(flowerstart_skill_damage, flowerstart_knockback_force, 0.4, "skill_flower_start")
	
	
	
	
	if current_state != State.SKILL:
		return


	# --- MODIFIED: Wait for the hitbox timer to finish ---
	# This guarantees we wait for the *entire* hit window
	# before checking if we got a target.
	await hitbox_timer.timeout
	# --- END MODIFICATION ---

	# At this point, deactivate_hitbox() has fired,
	# and is_waiting_for_skill_hit is now false.
	# We can safely check if skill_target was set.
	
	await get_tree().create_timer(0.6).timeout

	# 2. Check for Hit and Dash
	if skill_target != null and is_instance_valid(skill_target):
		trigger_camera_effects(20.0, 1.3, 0.2)
		animated_sprite.play("dash")

		var target_pos = skill_target.global_position
		var direction = (target_pos - global_position).normalized()
		var target_pos_with_offset = target_pos - direction * 0.0

		## --- ADDED: Auto-Flip Logic ---
		_face_target(skill_target)
		## --- END Auto-Flip Logic ---

		var tween = create_tween()
		tween.tween_property(self, "global_position", target_pos_with_offset, 0.2)\
				.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

		await tween.finished

		# 3. The Flurry
		if current_state != State.SKILL: return

		animated_sprite.play("skill_flower_flurry")

		for i in flower_skill_hits:
			if current_state != State.SKILL or not (skill_target != null and is_instance_valid(skill_target)):
				break

			## --- ADDED: Auto-Flip Logic ---
			# Face target at the start of each flurry hit
			_face_target(skill_target)
			## --- END Auto-Flip Logic ---

			activate_hitbox(flower_skill_damage, 30, 0.05, "skill_flower_flurry")

			var flurry_tween = create_tween()
			var flurry_target_pos = skill_target.global_position
			var flurry_direction = (flurry_target_pos - global_position).normalized()
			if flurry_direction == Vector2.ZERO:
				flurry_direction = Vector2.RIGHT

			var desired_pos = flurry_target_pos - flurry_direction * 0.0

			flurry_tween.tween_property(self, "global_position", desired_pos, flower_skill_hit_delay * 0.9)\
						.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

			await get_tree().create_timer(flower_skill_hit_delay).timeout

		# 4. The Finisher
		if current_state != State.SKILL: return

		## --- ADDED: Auto-Flip Logic ---
		_face_target(skill_target)
		## --- END Auto-Flip Logic ---

		animated_sprite.play("skill_flower_finish")
		await get_tree().create_timer(0.2).timeout

		if current_state != State.SKILL: return

		activate_hitbox(flower_skill_final_damage, flower_skill_final_knockback, 0.2, "skill_flower_finish")
		var flurry_tween = create_tween()
		var flurry_target_pos = skill_target.global_position
		var flurry_direction = (flurry_target_pos - global_position).normalized()
		if flurry_direction == Vector2.ZERO:
			flurry_direction = Vector2.RIGHT

		var desired_pos = flurry_target_pos - flurry_direction * 0.0

		flurry_tween.tween_property(self, "global_position", desired_pos, flower_skill_hit_delay * 0.9)\
					.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		trigger_camera_effects(40.0, 1.2, 0.2)
		await get_tree().create_timer(0.3).timeout

	else:
		# This 'else' block runs if the first hit missed
		await get_tree().create_timer(0.2).timeout

	# 5. Cleanup
	skill_target = null
	# is_waiting_for_skill_hit is already false
	if current_state == State.SKILL:
		current_state = State.IDLE


func _on_flower_cooldown_timer_timeout() -> void:
	is_flower_on_cooldown = false
	print("Flower Skill Ready")


# -- skill2

func start_customskill() -> void:
	# --- ADDED: Ensure ALL combo logic is reset when skill starts ---
	combo_count = 0
	combo_timer.stop()
	is_in_attack_windup = false
	hitbox_timer.stop()
	deactivate_hitbox()
	current_state = State.SKILL
	is_custom_on_cooldown = true
	custom_cooldown_timer.start(custom_skill_cooldown)

	customskill()


# --- MODIFIED: Awaits the correct timer ---
func customskill() -> void:
	# 1. First Punch
	skill_target = null
	is_waiting_for_skill_hit = true # Open the hit window

	animated_sprite.play("skill_customkick")

	await get_tree().create_timer(0.1).timeout # Skill windup

	if current_state != State.SKILL:
		return

	# Activate the hitbox for 0.2s
	activate_hitbox(flowerstart_skill_damage, 50, 0.4, "skill_custom_start")
	await hitbox_timer.timeout
	
	await get_tree().create_timer(0.6).timeout

	if skill_target != null and is_instance_valid(skill_target):
		animated_sprite.play("dash_custom")
		var target_pos = skill_target.global_position
		var direction = (target_pos - global_position).normalized()
		var target_pos_with_offset = target_pos - direction * 1.0

		## --- ADDED: Auto-Flip Logic ---
		_face_target(skill_target)
		## --- END Auto-Flip Logic ---

		var tween = create_tween()
		tween.tween_property(self, "global_position", target_pos_with_offset, 0.2)\
				.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		await tween.finished

		## --- ADDED: Auto-Flip Logic ---
		_face_target(skill_target)
		## --- END Auto-Flip Logic ---

		animated_sprite.play("skill_customkick")
		activate_hitbox(flowerstart_skill_damage, 50, 0.4, "skill_custom_start")
		await hitbox_timer.timeout
		
		
		await get_tree().create_timer(0.6).timeout
		

	else:
		# This 'else' block runs if the first hit missed
		await get_tree().create_timer(0.2).timeout




	if skill_target != null and is_instance_valid(skill_target):
		var target_pos = skill_target.global_position
		var direction = (target_pos - global_position).normalized()
		var target_pos_with_offset = target_pos - direction * 1.0

		## --- ADDED: Auto-Flip Logic ---
		_face_target(skill_target)
		## --- END Auto-Flip Logic ---

		var tween = create_tween()
		tween.tween_property(self, "global_position", target_pos_with_offset, 0.2)\
				.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		await tween.finished

		## --- ADDED: Auto-Flip Logic ---
		_face_target(skill_target)
		## --- END Auto-Flip Logic ---

		animated_sprite.play("slam")
		activate_hitbox(flowerstart_skill_damage, 200, 0.4, "skill_custom_start")
		await hitbox_timer.timeout

	else:
		# This 'else' block runs if the first hit missed
		await get_tree().create_timer(0.2).timeout



	# Cleanup Reset IDle
	skill_target = null
	# is_waiting_for_skill_hit is already false
	if current_state == State.SKILL:
		current_state = State.IDLE

func _on_custom_cooldown_timer_timeout() -> void:
	is_custom_on_cooldown = false
	print("Custom Skill Ready")


# -- skill3 (Custom 2 Skill)

func start_custom2skill() -> void:
	# --- ADDED: Ensure ALL combo logic is reset when skill starts ---
	combo_count = 0
	combo_timer.stop()
	is_in_attack_windup = false
	hitbox_timer.stop()
	deactivate_hitbox()
	# --- END CLEANUP ---
	
	current_state = State.SKILL
	is_custom2_on_cooldown = true
	custom2_cooldown_timer.start(custom2_skill_cooldown)

	# Start the main skill sequence
	custom2skill()


func custom2skill() -> void:
	skill_target = null
	
	# --- STAGE 1: Charge Up & Target Search ---
	# Play a dramatic charge animation
	animated_sprite.play("kickcustom") # TODO: Create this animation
	
	# Open a brief, large hit window to find a target *before* the charge ends
	# This hitbox is ONLY for finding the target, not for damage.
	is_waiting_for_skill_hit = true
	activate_hitbox(0.0, 100.0, CHARGE_TIME, "skill_custom2_start") # 0 damage
	
	await get_tree().create_timer(CHARGE_TIME).timeout

	# Clean up target hitbox and check if a target was found
	deactivate_hitbox() # Resets is_waiting_for_skill_hit = false
	
	if current_state != State.SKILL: return
	
	# --- STAGE 2: Dash to Target (Lock-On) ---
	if skill_target != null and is_instance_valid(skill_target):
		animated_sprite.play("dash")
		_face_target(skill_target)
		
		var target_pos = skill_target.global_position
		var direction = (target_pos - global_position).normalized()
		# Position slightly behind the target for the flurry
		var target_pos_with_offset = target_pos - direction * 0.0 

		var tween = create_tween()
		tween.tween_property(self, "global_position", target_pos_with_offset, DASH_DURATION)\
				.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		
		
		await tween.finished
		
		if current_state != State.SKILL: return
		
		# --- STAGE 3: Flurry of Attacks ---
		animated_sprite.play("skill_flower_flurry") # TODO: Create this animation
		
		for i in FLURRY_HITS:
			if current_state != State.SKILL or not is_instance_valid(skill_target):
				break

			_face_target(skill_target)
			
			# Flurry Hitbox
			activate_hitbox(FLURRY_DAMAGE, 1.0, 0.05, "skill_custom2_flurry_hit")
			# Short, sharp camera effect for the dash
			trigger_camera_effects(10.0, 1.3, 0.1)
			
			# Small move towards the target during the flurry
			var flurry_target_pos = skill_target.global_position
			var flurry_direction = (flurry_target_pos - global_position).normalized()
			if flurry_direction == Vector2.ZERO: flurry_direction = last_facing_direction
			
			var desired_pos = global_position + flurry_direction * 5.0 # Nudge forward
			
			var flurry_tween = create_tween()
			flurry_tween.tween_property(self, "global_position", desired_pos, FLURRY_HIT_DELAY * 0.9)\
						.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			
			await get_tree().create_timer(FLURRY_HIT_DELAY).timeout
		
		# --- STAGE 4: Final Blast (The Kamehameha!) ---
		if current_state != State.SKILL or not is_instance_valid(skill_target):
			skill_target = null
			if current_state == State.SKILL: current_state = State.IDLE
			return

		_face_target(skill_target)
		animated_sprite.play("flurrycustom") # TODO: Create this animation
		
		# Blast Windup
		await get_tree().create_timer(0.2).timeout
		
		# Activate a large, powerful hitbox for the final blow
		activate_hitbox(FINAL_BLAST_DAMAGE, FINAL_KNOCKBACK, 0.3, "skill_custom2_blast_hit")
		trigger_camera_effects(50.0, 1.7, 0.1) # Huge shake and zoom-in
		
		await hitbox_timer.timeout # Wait for the blast's duration
		
		await get_tree().create_timer(0.9).timeout
		

	else:
		# If no target was found during the charge, the skill fails to launch fully
		animated_sprite.play("idle")
		await get_tree().create_timer(0.3).timeout # Wait for the failed charge animation

	# --- STAGE 5: Cleanup & Return to IDLE ---
	skill_target = null
	if current_state == State.SKILL:
		current_state = State.IDLE

func _on_custom2_cooldown_timer_timeout() -> void:
	is_custom2_on_cooldown = false
	print("Custom2 Skill (KJ Skill) Ready")


# --- NEW: Slam Attack ---

func start_slam_attack() -> void:
	# --- ADDED: Ensure ALL combo logic is reset when skill starts ---
	combo_count = 0
	combo_timer.stop()
	is_in_attack_windup = false
	hitbox_timer.stop()
	deactivate_hitbox()
	# ---

	current_state = State.SKILL
	is_slam_on_cooldown = true
	slam_cooldown_timer.start(slam_attack_cooldown)

	run_slam_attack_sequence()


func run_slam_attack_sequence() -> void:
	# 1. Windup (Jump up slightly)
	# --- TODO: Replace "skill_flower_start" with your own slam windup animation ---
	animated_sprite.play("slam")
	
	# Add a small hop
	velocity.y = -100
	
	await get_tree().create_timer(0.2).timeout # Windup time

	if current_state != State.SKILL: return

	# 2. The Slam (Move down fast, create hitbox)
	# --- TODO: Replace "kick" with your own slam down animation ---
	animated_sprite.play("slam")
	velocity.y = 300 # Slam down fast
	
	await get_tree().create_timer(0.1).timeout # Time to slam
	
	if current_state != State.SKILL: return

	# 3. Impact
	velocity = Vector2.ZERO # Stop all movement
	trigger_camera_effects(3.0, 1.32, 0.2) # Big camera shake

	# --- This is the AoE (Area of Effect) logic ---
	# We will temporarily change the hitbox's shape to a circle
	var hitbox_shape_node: CollisionShape2D = $Hitbox.get_node("CollisionShape2D")
	if not hitbox_shape_node:
		print("ERROR: Player Hitbox is missing CollisionShape2D child.")
		return

	var original_shape = hitbox_shape_node.shape
	
	# Create a new CircleShape for the slam
	var slam_shape = CircleShape2D.new()
	slam_shape.radius = slam_aoe_radius # Use the exported variable
	
	# Temporarily set the new shape
	hitbox_shape_node.shape = slam_shape
	
	# Activate the hitbox. Rotation doesn't matter since it's a circle.
	activate_hitbox(slam_damage, slam_knockback_force, 0.15, "slam_attack")
	
	# Wait for the hitbox to finish
	await hitbox_timer.timeout
	
	# --- CRITICAL: Restore the original shape ---
	hitbox_shape_node.shape = original_shape
	
	# 4. Cleanup
	if current_state == State.SKILL:
		current_state = State.IDLE

func _on_slam_cooldown_timer_timeout() -> void:
	is_slam_on_cooldown = false
	print("Slam Attack Ready")

# --- END NEW ---

# --- MODIFIED: Effect Spawning with Direction ---

func _spawn_impact_effect(spawn_position: Vector2, attack_direction: Vector2 = Vector2.ZERO) -> void:
	if impact_effect:
		var effect_instance = impact_effect.instantiate()
		effect_instance.global_position = spawn_position
		
		if attack_direction != Vector2.ZERO:
			effect_instance.rotation = attack_direction.angle()
			
			# --- END ADD ---
			
		get_parent().add_child(effect_instance)

func _spawn_circleimpact_effect(spawn_position: Vector2, attack_direction: Vector2 = Vector2.ZERO) -> void:
	if impactcircle_effect:
		var effect_instance = impactcircle_effect.instantiate()
		effect_instance.global_position = spawn_position
		
		if attack_direction != Vector2.ZERO:
			effect_instance.rotation = attack_direction.angle()
			
			# --- END ADD ---
			
		get_parent().add_child(effect_instance)

# --- Combat: Dealing and Taking Damage ---

# --- MODIFIED: Uses dedicated HitboxTimer and 8-way rotation ---
func activate_hitbox(damage: float, knockback: float, duration: float, attack_id: String = "default") -> void:
	# Stop any previous deactivation timer
	hitbox_timer.stop()

	hitbox.set_meta("damage", damage)
	hitbox.set_meta("knockback_force", knockback)
	hitbox.set_meta("attack_id", attack_id)

	hit_bodies.clear()

	# --- MODIFIED: Rotate the entire Hitbox node ---
	# This uses the 8-way direction to aim the hitbox.
	# It assumes your CollisionShape2D is at a position like (2, 0).
	# --- We skip rotation for the slam, as it's a circle ---
	if attack_id != "slam_attack":
		hitbox.rotation = last_move_direction.angle()
	else:
		hitbox.rotation = 0 # Reset rotation for the circular slam
	# --- END MODIFICATION ---

	hitbox.monitoring = true

	# Use our dedicated timer
	hitbox_timer.start(duration)


# --- MODIFIED: Cleaned up logic ---
func deactivate_hitbox() -> void:
	hitbox.monitoring = false
	hit_bodies.clear()
	hitbox.set_meta("attack_id", "default")

	# --- MODIFIED: This is now the ONLY place this flag is set to false ---
	# This signals that the "window of opportunity" for the skill is over.
	is_waiting_for_skill_hit = false


# --- MODIFIED: Cleaned up logic ---
func _on_hitbox_body_entered(body) -> void:
	if body == self: return

	## --- ADDED: Auto-Flip Logic ---
	# Always flip to face the target you hit
	# (Skip for slam, it's an AoE)
	var current_attack_id = hitbox.get_meta("attack_id", "default")
	if current_attack_id != "slam_attack":
		_face_target(body)
	## --- END Auto-Flip Logic ---

	# --- MODIFIED: We no longer set 'is_waiting_for_skill_hit' to false here ---
	# We just set the target. The flag will be reset when the timer runs out.
	if is_waiting_for_skill_hit:
		# Check for the initial skill hit that *designates* the target
		if current_attack_id == "skill_flower_start" or current_attack_id == "skill_custom_start" or current_attack_id == "skill_flower_finish" or current_attack_id == "skill_custom2_start" or current_attack_id == "skill_custom2_blast_hit":
			skill_target = body
		# is_waiting_for_skill_hit = false # <-- REMOVED


	if body.has_method("take_damage"):
		var damage = hitbox.get_meta("damage", 0.0)
		var knockback = hitbox.get_meta("knockback_force", 0.0)

		var knockback_direction = (body.global_position - global_position).normalized()
		if knockback_direction == Vector2.ZERO:
			# --- MODIFIED: Use last_move_direction as fallback ---
			knockback_direction = last_move_direction
		
		if knockback_direction == Vector2.ZERO:
			# --- (Ultimate fallback if last_move_direction is also zero) ---
			knockback_direction = Vector2.RIGHT

		body.take_damage(damage, knockback_direction, knockback)

		if not hit_bodies.has(body):
			match current_attack_id:
				"m1_combo_hit":
					trigger_camera_effects(3, 1.3, 0.1)
				"m1_combo_4":
					trigger_camera_effects(20.0, 1.3, 0.2)
				"skill_flower_start":
					trigger_camera_effects(40.0, 1.2, 0.2)
					_spawn_circleimpact_effect(body.global_position, knockback_direction)
				"skill_flower_flurry":
					trigger_camera_effects(10.0, 1.45, 0.1)
				"skill_custom_start":
					trigger_camera_effects(40.0, 1.3, 0.2) # Zoom out/focus
					_spawn_circleimpact_effect(body.global_position, knockback_direction)
					_spawn_impact_effect(body.global_position, knockback_direction)
				"skill_custom2_start":
					trigger_camera_effects(40.0, 1.3, 0.1) # Zoom out/focus
					_spawn_circleimpact_effect(body.global_position, knockback_direction)
				"skill_custom2_blast_hit":
					_spawn_circleimpact_effect(body.global_position, knockback_direction)
				"skill_flower_finish":
					_spawn_circleimpact_effect(body.global_position, knockback_direction)
					
					

		hit_bodies.append(body)


func take_damage(damage: float, knockback_dir: Vector2, knockback_force: float) -> void:
	if current_state == State.DEAD: return

	if current_state == State.DASH:
		print("DASHED (Invincible)")
		return

	current_health -= damage
	print("Player Health: ", current_health)

	current_state = State.HITSTUN
	velocity = knockback_dir * knockback_force
	animated_sprite.play("hit")
	hitstun_timer.start(0.3)

	combo_count = 0
	combo_timer.stop()
	is_in_attack_windup = false

	# --- ADDED: Force hitbox cleanup on taking damage ---
	hitbox_timer.stop()
	deactivate_hitbox()
	# ---

	skill_target = null
	# is_waiting_for_skill_hit is reset by deactivate_hitbox()

	if current_health <= 0:
		die()


func _on_hitstun_timer_timeout() -> void:
	if current_state == State.HITSTUN:
		current_state = State.IDLE


func die() -> void:
	current_state = State.DEAD
	animated_sprite.play("death")
	collision_shape.disabled = true
	set_physics_process(false)
	print("Player has died.")

                                                                                                                                                                            
                                                                                                                                                                            
                                                                                                                                                                            
                                                                                                                                                                            

                                                                                                                                                                            
                                                                                                                                                                            
                                                                                                                                                                            # dummy.gd
extends CharacterBody2D

## --- DUMMY SCRIPT ---
## A simple CharacterBody2D for testing attacks.
## It takes damage, gets knocked back, and has a health bar (in text).

## REQUIRED SCENE SETUP (Node Tree):
# - Dummy (CharacterBody2D, with this script)
#   - AnimatedSprite2D
#   - CollisionShape2D
#   - HitstunTimer (Timer, one_shot=true)
#   - HealthLabel (Label)

## REQUIRED ANIMATIONS (on AnimatedSprite2D):
# - "idle"
# - "hit"
# - "death"

@export var max_health: float = 10000.0
var current_health: float

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitstun_timer: Timer = $HitstunTimer
@onready var health_label: Label = $HealthLabel

var in_hitstun: bool = false

func _ready() -> void:
	current_health = max_health
	hitstun_timer.timeout.connect(_on_hitstun_timer_timeout)
	update_health_label()

func _physics_process(delta: float) -> void:
	if not in_hitstun:
		# No gravity, no movement
		velocity = Vector2.ZERO
	else:
		# Apply friction to knockback
		velocity = velocity.move_toward(Vector2.ZERO, velocity.length() * 2.0 * delta)
	
	move_and_slide()


# This is the function the PLAYER'S hitbox will call
func take_damage(damage: float, knockback_dir: Vector2, knockback_force: float) -> void:
	if current_health <= 0: return # Already dead
		
	current_health -= damage
	print("Dummy Health: ", current_health)
	update_health_label()
	
	# Apply knockback
	velocity = knockback_dir * knockback_force
	
	# Enter hitstun
	in_hitstun = true
	hitstun_timer.start(0.2) # 0.2s hitstun
	animated_sprite.play("hit")
	
	play_hit_effect()
	
	if current_health <= 0:
		die()


func _on_hitstun_timer_timeout() -> void:
	in_hitstun = false
	if current_health > 0:
		animated_sprite.play("idle")

func play_hit_effect():
	# Create a simple "hit flash" by modulating the sprite red and back
	var tween = create_tween()
	# Set to red instantly
	animated_sprite.modulate = Color.RED
	# Tween back to white over 0.2 seconds
	tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.2)

func update_health_label() -> void:
	#health_label.text = "HP: %d / %d" % [current_health, max_health]
	pass


func die() -> void:
	print("Dummy defeated")
	animated_sprite.play("death")
	# In a real game, you might start a fade-out timer
	set_physics_process(false)
	queue_free()

                                                                                                                                                                            
