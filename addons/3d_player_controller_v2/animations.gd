extends Node

# Climbing Ladder
const CLIMBING_LADDER := "Climbing_Ladder/mixamo_com"

# Climbing - Mixamo animations
const CLIMBING_UP := "Climbing_Up/mixamo_com"
const CLIMBING_DOWN := "Climbing_Down/mixamo_com"
const CLIMBING_LEFT := "Hanging_Braced_Shimmy_Left/mixamo_com"
const CLIMBING_RIGHT := "Hanging_Braced_Shimmy_Right/mixamo_com"
# Climbing - Quaternius animations
#const CLIMBING_UP := "AnimationLibrary_Godot/Climb_Up"
#const CLIMBING_DOWN := "AnimationLibrary_Godot/Climb_Down"
#const CLIMBING_LEFT := "AnimationLibrary_Godot/Climb_Left"
#const CLIMBING_RIGHT := "AnimationLibrary_Godot/Climb_Right"

# Crawling
const CRAWLING := "Crawling/mixamo_com"
const CRAWLING_HOLDING_RIFLE := "Crouching_Walking_Holding_Rifle/mixamo_com"
const CRAWLING_AIMING_RIFLE := "Crouching_Walking_Aiming_Rifle/mixamo_com"
const CRAWLING_FIRING_RIFLE := "Crouching_Firing_Rifle/mixamo_com"
# Crawling - Quaternius animations
#const CRAWLING := "AnimationLibrary_Godot/Crawl"

# Crouching 
const CROUCHING_IDLE := "Crouching/mixamo_com"
const CROUCHING_HOLDING_RIFLE := "Crouching_Holding_Rifle/mixamo_com"
const CROUCHING_AIMING := "Crouching_Aiming_Rifle/mixamo_com"
const CROUCHING_FIRING := "Crouching_Firing_Rifle/mixamo_com"
# Crouching - Quaternius animations
#const CROUCHING_IDLE := "AnimationLibrary_Godot/Crouch_Idle"

# Driving
const DRIVING := "Driving/mixamo_com"
# Driving - Quaternius animations
#const DRIVING := "AnimationLibrary_Godot/Driving"

# Falling
const FALLING := "Falling/mixamo_com"
const FALLING_HOLDING_RIFLE := "Falling_Holding_Rifle/mixamo_com"
# Falling - Quaternius animations
#const FALLING := "AnimationLibrary_Godot/Jump"

# Flying
const FLYING := "Flying/mixamo_com"
const FLYING_FAST := "Flying_Fast/mixamo_com"

# Hanging
const HANGING := "Hanging/mixamo_com"
const HANGING_SHIMMY_LEFT := "Hanging_Shimmy_Left/mixamo_com"
const HANGING_SHIMMY_RIGHT := "Hanging_Shimmy_Right/mixamo_com"
const HANGING_BRACED := "Hanging_Braced/mixamo_com"
const HANGING_BRACED_SHIMMY_LEFT := "Hanging_Braced_Shimmy_Left/mixamo_com"
const HANGING_BRACED_SHIMMY_RIGHT := "Hanging_Braced_Shimmy_Right/mixamo_com"

# Jumping
const JUMPING := "Falling/mixamo_com"
const JUMPING_HOLDING_RIFLE := "Falling_Holding_Rifle/mixamo_com"
# Jumping - Quaternius animations
#const JUMPING := "AnimationLibrary_Godot/Jump_Start"

# Mantling
const MANTLING_BRACED := "Hanging_Braced_To_Crouch/mixamo_com"
const MANTLING_HANGING := "Hanging_Climb_To_Standing/mixamo_com"
# Mantling - Quaternius animations
#const MANTLING_BRACED := "AnimationLibrary_Godot/ClimbLedge"
#const MANTLING_HANGING := "AnimationLibrary_Godot/ClimbLedge"

# Navigating
const NAVIGATING := RUNNING

# Paragliding
const PARAGLIDING := HANGING

# Pushing
const PUSHING := "Standing_Pushing/mixamo_com"
# Pushing - Quaternius animations
#const PUSHING := "AnimationLibrary_Godot/Push"
#const PUSHING_START := "AnimationLibrary_Godot/Push_Enter"
#const PUSHING_STOP := "AnimationLibrary_Godot/Push_Exit"

# Reacting
const REACTING_LOW_LEFT := "Standing_Reaction_Low_Left/mixamo_com"
const REACTING_LOW_RIGHT := "Standing_Reaction_Low_Right/mixamo_com"
const REACTING_HIGH_LEFT := "Standing_Reaction_High_Left/mixamo_com"
const REACTING_HIGH_RIGHT := "Standing_Reaction_High_Right/mixamo_com"
# Reacting - Quaternius animations
#const REACTING_LOW_LEFT := "AnimationLibrary_Godot/Hit_Stomach"
#const REACTING_LOW_RIGHT := "AnimationLibrary_Godot/Hit_Stomach"
#const REACTING_HIGH_LEFT := "AnimationLibrary_Godot/Hit_Shoulder_L"
#const REACTING_HIGH_RIGHT := "AnimationLibrary_Godot/Hit_Shoulder_R"

# Rolling
const ROLLING := "Rolling/mixamo_com"
# Rolling - Quaternius animations
#const ROLLING := "AnimationLibrary_Godot/Roll"

# Running
const RUNNING := "Running/mixamo_com"
const RUNNING_HOLDING_RIFLE := "Running_Holding_Rifle/mixamo_com"
const RUNNING_AIMING_RIFLE := "Running_Aiming_Rifle/mixamo_com"
const RUNNING_FIRING_RIFLE := "Running_Firing_Rifle/mixamo_com"
# Running - Quaternius animations
#const RUNNING := "AnimationLibrary_Godot/Jog_Fwd"
#const RUNNING_STRAFE_LEFT := "AnimationLibrary_Godot/Jog_Fwd_L"
#const RUNNING_STRAFE_RIGHT := "AnimationLibrary_Godot/Jog_Fwd_R"
#const RUNNING_BACKWARDS := "AnimationLibrary_Godot/Jog_Bwd"
#const RUNNING_BACKWARDS_STRAFE_LEFT := "AnimationLibrary_Godot/Jog_Bwd_L"
#const RUNNING_BACKWARDS_STRAFE_RIGHT := "AnimationLibrary_Godot/Jog_Bwd_R"

# Sitting
const SITTING := "Sitting/mixamo_com"
# Sitting - Quaternius animations
#const SITTING := "AnimationLibrary_Godot/Sitting_Idle"
#const SITTING_START := "AnimationLibrary_Godot/Sitting_Enter"
#const SITTING_STOP := "AnimationLibrary_Godot/Sitting_Exit"

# Skateboarding
const SKATEBOARDING := "Skateboarding/mixamo_com"
const SKATEBOARDING_FAST := "Skateboarding_Fast/mixamo_com"
const SKATEBOARDING_SLOW := "Skateboarding_Slow/mixamo_com"

# Sliding
const SLIDING := "Running_Slide/mixamo_com"

# Sprinting
const SPRINTING := "Sprinting/mixamo_com"
const SPRINTING_HOLDING_RIFLE := "Sprinting_Holding_Rifle/mixamo_com"
# Sprinting - Quaternius animations
#const SPRINTING := "AnimationLibrary_Godot/Sprint"
#const SPRINTING_START := "AnimationLibrary_Godot/Sprint_Enter"
#const SPRINTING_STOP := "AnimationLibrary_Godot/Sprint_Exit"

# Standing
const FISHING_CASTING := "Standing_Fishing_Cast/mixamo_com"
const FISHING_IDLE := "Standing_Fishing_Idle/mixamo_com"
const FISHING_REELING := "Standing_Fishing_Reel/mixamo_com"
const BLOCKING_1H_LEFT := "Standing_Blocking_1H_Left/mixamo_com"
const BLOCKING_1H_RIGHT := "Standing_Blocking_1H_Right/mixamo_com"
const BLOCKING_2H := "Standing_Blocking_2H/mixamo_com"
const HOLDING_1H_LEFT := "Standing_Holding_1H_Left/mixamo_com"
const HOLDING_1H_RIGHT := "Standing_Holding_1H_Right/mixamo_com"
const HOLDING_2H := "Standing_Holding_2H/mixamo_com"
const KICKING_LEFT := "Standing_Kicking_Left/mixamo_com"
const KICKING_RIGHT := "Standing_Kicking_Right/mixamo_com"
const PUNCHING_LEFT := "Standing_Punching_Left/mixamo_com"
const PUNCHING_RIGHT := "Standing_Punching_Right/mixamo_com"
const HOLDING_RIFLE := "Standing_Holding_Rifle/mixamo_com"
const RIFLE_AIMING := "Standing_Aiming_Rifle/mixamo_com"
const RIFLE_FIRING := "Standing_Firing_Rifle/mixamo_com"
const STANDING_IDLE := "Standing/mixamo_com"
const SWINGING_1H_LEFT := "Standing_Swinging_1H_Left/mixamo_com"
const SWINGING_1H_RIGHT := "Standing_Swinging_1H_Right/mixamo_com"
const SWINGING_2H := "Standing_Swinging_2H/mixamo_com"
const THROWING_LEFT := "Standing_Throwing_Left/mixamo_com"
const THROWING_RIGHT := "Standing_Throwing_Right/mixamo_com"
const TURNING_LEFT := "Standing_Left_Turn/mixamo_com"
const TURNING_RIGHT := "Standing_Right_Turn/mixamo_com"
# Standing - Quaternius animations
#const KICKING_RIGHT := "AnimationLibrary_Godot/Kick"
#const PUNCHING_LEFT := "AnimationLibrary_Godot/Punch_Jab"
#const PUNCHING_RIGHT := "AnimationLibrary_Godot/Punch_Cross"
#const STANDING_IDLE := "AnimationLibrary_Godot/Idle"
#const SWINGING_1H_RIGHT := "AnimationLibrary_Godot/Sword_Attack_Standing"
#const TURNING_LEFT := "AnimationLibrary_Godot/Turn90_L"
#const TURNING_RIGHT := "AnimationLibrary_Godot/Turn90_R"

# Swimming
const SWIMMING := "Swimming/mixamo_com"
const WADING := "Swimming_Treading_Water/mixamo_com"
# Swimming - Quaternius animations
#const SWIMMING := "AnimationLibrary_Godot/Swim_Fwd"
#const WADING := "AnimationLibrary_Godot/Swim_Idle"

# Walking
const WALKING := "Walking/mixamo_com"
const WALKING_HOLDING_RIFLE := "Walking_Holding_Rifle/mixamo_com"
const WALKING_HOLDING_AIMING := "Walking_Aiming_Rifle/mixamo_com"
const WALKING_FIRING_RIFLE := "Walking_Firing_Rifle/mixamo_com"
# Walking - Quaternius animations
#const WALKING := "AnimationLibrary_Godot/Walk"
