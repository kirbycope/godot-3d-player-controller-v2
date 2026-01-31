# Notes
[Universal Base Characters](https://quaternius.com/packs/universalbasecharacters.html) - August 2025

## License
1. Copy `Universal Base Characters[Standard].zip\License_Standard.txt`
   to `assets\universal_base_characters\License_Standard.txt`

## Models
### Generate the `.import` Files
1. Copy contents of `Universal Base Characters[Standard].zip\Base Characters\Exports\Godot - UE`
  to `assets\universal_base_characters\Base Characters`
1. Copy contents of `Universal Base Characters[Standard].zip\Hairstyles\Origin at 0\glTF (Godot)`
  to `assets\universal_base_characters\Hairstyles\Origin`
1. Copy contents of `C:\Users\kirby\Downloads\quaternius\Universal Base Characters[Standard].zip\Hairstyles\Rigged to Head Bone\glTF (Godot -Unreal)`
  to `assets\universal_base_characters\Hairstyles\Rigged`
1. Open the project in Godot and let it import

### Edit the `.import` Files
This will both update the materials and retarget the skeleton.
1. Open `assets\universal_base_characters\Base Characters` with VSCode
    - Find: `import_script/path=""`
    Replace: `import_script/path="res://assets/universal_base_characters/quaternius_import_script.gd"`
    - Find: `_subreStandards={}`
	Replace: `_subreStandards={"nodes": {"PATH:Armature/Skeleton3D": {"retarget/bone_map": Object(BoneMap,"reStandard_local_to_scene":false,"reStandard_name":"","profile":Object(SkeletonProfileHumanoid,"reStandard_local_to_scene":false,"reStandard_name":"","root_bone":&"Root","scale_base_bone":&"Hips","group_size":4,"bone_size":56,"script":null),"bonemap":null,"bone_map/Root":&"root","bone_map/Hips":&"pelvis","bone_map/Spine":&"spine_01","bone_map/Chest":&"spine_02","bone_map/UpperChest":&"spine_03","bone_map/Neck":&"neck_01","bone_map/Head":&"Head","bone_map/LeftEye":&"","bone_map/RightEye":&"","bone_map/Jaw":&"","bone_map/LeftShoulder":&"clavicle_l","bone_map/LeftUpperArm":&"upperarm_l","bone_map/LeftLowerArm":&"lowerarm_l","bone_map/LeftHand":&"hand_l","bone_map/LeftThumbMetacarpal":&"thumb_01_l","bone_map/LeftThumbProximal":&"thumb_02_l","bone_map/LeftThumbDistal":&"thumb_03_l","bone_map/LeftIndexProximal":&"index_01_l","bone_map/LeftIndexIntermediate":&"index_02_l","bone_map/LeftIndexDistal":&"index_03_l","bone_map/LeftMiddleProximal":&"middle_01_l","bone_map/LeftMiddleIntermediate":&"middle_02_l","bone_map/LeftMiddleDistal":&"middle_03_l","bone_map/LeftRingProximal":&"ring_01_l","bone_map/LeftRingIntermediate":&"ring_02_l","bone_map/LeftRingDistal":&"ring_03_l","bone_map/LeftLittleProximal":&"pinky_01_l","bone_map/LeftLittleIntermediate":&"pinky_02_l","bone_map/LeftLittleDistal":&"pinky_03_l","bone_map/RightShoulder":&"clavicle_r","bone_map/RightUpperArm":&"upperarm_r","bone_map/RightLowerArm":&"lowerarm_r","bone_map/RightHand":&"hand_r","bone_map/RightThumbMetacarpal":&"thumb_01_r","bone_map/RightThumbProximal":&"thumb_02_r","bone_map/RightThumbDistal":&"thumb_03_r","bone_map/RightIndexProximal":&"index_01_r","bone_map/RightIndexIntermediate":&"index_02_r","bone_map/RightIndexDistal":&"index_03_r","bone_map/RightMiddleProximal":&"middle_01_r","bone_map/RightMiddleIntermediate":&"middle_02_r","bone_map/RightMiddleDistal":&"middle_03_r","bone_map/RightRingProximal":&"ring_01_r","bone_map/RightRingIntermediate":&"ring_02_r","bone_map/RightRingDistal":&"ring_03_r","bone_map/RightLittleProximal":&"pinky_01_r","bone_map/RightLittleIntermediate":&"pinky_02_r","bone_map/RightLittleDistal":&"pinky_03_r","bone_map/LeftUpperLeg":&"thigh_l","bone_map/LeftLowerLeg":&"calf_l","bone_map/LeftFoot":&"foot_l","bone_map/LeftToes":&"ball_l","bone_map/RightUpperLeg":&"thigh_r","bone_map/RightLowerLeg":&"calf_r","bone_map/RightFoot":&"foot_r","bone_map/RightToes":&"ball_r","script":null)}}}`
1. Repeat for `assets\universal_base_characters\Hairstyles\Origin`
1. Repeat for `assets\universal_base_characters\Hairstyles\Rigged`
1. Re-Open Godot to re-import
	- This will expand the bone map in the import file, too

## Known Issues Issue(s)
1. `T_Eye_Normal_png.png` needs to be replaced with `T_Eye_Normal.png`
T_Hair_1_Normal_png.png