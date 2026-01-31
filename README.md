![Preview](/godot-3d-player-controller-v2.png)

# godot-3d-player-controller-v2
A 3D Player Controller for the Godot game engine.</br>
Click >>[here](https://timothycope.com/godot-3d-player-controller-v2/)<< to try it out using a few example levels.

## Getting Started
1. Copy the contents of this repo's [addons/3d_player_controller_v2](/addons/3d_player_controller_v2/) folder to the `/addons/3d_player_controller_v2` folder of your project.
1. Drag the [Player.tscn](/addons/3d_player_controller_v2/player.tscn) from the "FileSystem" into the "Scene" tree

## Using A Different Character Model
The player's appearance comes from the imported scene, `$Visuals/Character`. It requires a "retargetted" model that is both "rigged" and in a "T-pose".

### Retarget Your Model
[Retargetting](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/retargeting_3d_skeletons.html) the skeleton will allow you to use the provided [Mixamo](https://www.mixamo.com/#/) animations and sets you up to use others like _Quaternius's_ [Universal Animation Library](https://quaternius.com/packs/universalanimationlibrary.html).
1. Open the Godot Editor
1. Click the character model in the FileSystem
1. Click the "Import" tab (at the top-right of the editor)
1. Click the "Advanced..." button
1. In the Scene tree, select the ![Skeleton3D](https://raw.githubusercontent.com/godotengine/godot/refs/heads/master/editor/icons/Skeleton3D.svg) Skeleton3D
1. Click "Retarget" > "Bone Map" > "<empty>" and then select "New" > "BoneMap"
1. Click the new BoneMap
1. Click "Profile" > "⏷" and then select "SkeletonProfileHumanoid"
1. Click the "Reimport" button to apply changes

### Create the Character Scene
1. Click the "Scene" tab (at the top-left of the editor)
1. Create a new ![Node3D](https://raw.githubusercontent.com/godotengine/godot/refs/heads/master/editor/icons/Node3D.svg) 3D Scene
1. Rename the Node3D to your model's name
1. Drag your model into the new Scene tree
1. Select the imported scene and set the "Transform" > "Rotation" > "y" to `180`
	- Godot's "forward" direction is -Z ([source](https://docs.godotengine.org/en/stable/tutorials/3d/introduction_to_3d.html#coordinate-system))
	- The model is imported as a child of the scene root so that when added to another scene the transform isn't reset and the character stays facing forward
1. Save the scene

#### [Optional] Add Animations to Model
The [Setup Character](/addons//3d_player_controller_v2/setup_character.gd) script is called by the player's `_ready()` function and it sets up the animations for you. This next section is so that you can see how they look in the Godot Editor while viewing the `$Visuals/Character` scene. It should not increase your project export size significatly.
1. Add a child ![AnimationPlayer](https://raw.githubusercontent.com/godotengine/godot/refs/heads/master/editor/icons/AnimationPlayer.svg) AnimationPlayer if one is not already present
1. In the Scene tree, click the AnimationPlayer
1. In the Animation Panel, click the "Animation" button and then select "Manage Animations..."
1. Click the "Load Library" button
1. Navigate to `./addons/3d_player_controller/assets/animations`
1. Select all and then click the "Open" button
1. Save the scene

### Use the New Character
You can remove the Node at `$Visuals/Character` and then replace it with your own, in the Editor or during runtime.
- The Beta (QA World)'s [main.gd](/scenes/level_0/main.gd) script show you how in the `_input()` function.

### Swap Animation Sets
This pack comes with [Mixamo](https://www.mixamo.com/#/) animations and sets you up to use _Quaternius's_ [Universal Animation Library](https://quaternius.com/packs/universalanimationlibrary.html) and/or [Universal Animation Library 2](https://quaternius.com/packs/universalanimationlibrary2.html). Change `player.animation_set` to:
    - `0`: "Mixamo"
    - `1`: Quaternius"
