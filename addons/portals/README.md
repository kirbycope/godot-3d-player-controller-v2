# Portals 3D

This plugin enables you to easily create seamless plugins.

## Documentation

For documentation about `Portal3D`, see the portal script itself. Everything is properly documented
and viewable in the default documentation window. Go to the script editor, click _Search Help_ in
the top bar and search for "Portal3D".

For everything else, there is this README.

## Guides

### Customize portals in the editor

The portal mesh has a custom shader material assigned to it at runtime (defined in
`materials/portal_shader.gdshader`), but in editor, it uses a regular material -- find it at
`materials/editor-preview-portal-material.tres`. You can edit this material to customize how
portals look in the editor (in case the default gray color blends in too much).

### Smooth teleportation

The Portal3D script provides a mechanism for smooth teleportation. In order to be able to create
smooth portal transitions, you need to put a clipping shader onto all meshes that are supposed to
participate in the smooth teleportation.

**How to convert a regular mesh to a clippable one?** Like this:

1. On your material, click the downward arrow menu and select _Convert to ShaderMaterial_
2. Include the shader macros and use them to inject clipping uniforms, the vertex logic
and the fragment logic.

```c
shader_type spatial;

// ...

#include "res://addons/portals/materials/portalclip_mesh.gdshaderinc"

PORTALCLIP_UNIFORMS 

void vertex() {
 // ...
 PORTALCLIP_VERTEX
}

void fragment() {
 // ...
 PORTALCLIP_FRAGMENT
}
```

And that's it! Now look for `DUPLICATE_MESHES_CALLBACK` in the Portal3D script, you are ready to
get going with smooth teleportation!

## Gizmos

This plugin includes couple of custom gizmos. One gives a connected portal an outline and the
second one visualizes portal's front direction. You can configure the color of both gizmos in
_Project Settings / Addons / Portals_ or turn them off altogether.
