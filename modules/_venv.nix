{
  lib,
  pkgs,
  workspaceRoot,
  pythonPackage,
  pyprojectOverridesPath,

  uv2nix,
  pyproject-nix,
  pyproject-build-systems,
  ...
}:
let
  pkg-name = import ./_package-name.nix { inherit workspaceRoot; };
  inherit pythonPackage;
  hacks = pkgs.callPackage pyproject-nix.build.hacks { };
  workspace = uv2nix.lib.workspace.loadWorkspace { inherit workspaceRoot; };

  pyprojectOverlay = workspace.mkPyprojectOverlay {
    sourcePreference = "wheel";
  };
  editableOverlay = workspace.mkEditablePyprojectOverlay {
    root = "$REPO_ROOT";
  };

  pyprojectOverrides =
    if pyprojectOverridesPath != null then
      (import pyprojectOverridesPath {
        inherit pythonPackage hacks pkgs;
      })
    else
      (_final: _prev: { });

  pythonSet =
    (pkgs.callPackage pyproject-nix.build.packages {
      python = pythonPackage;
    }).overrideScope
      (
        lib.composeManyExtensions [
          pyproject-build-systems.overlays.wheel
          pyprojectOverlay
          pyprojectOverrides
        ]
      );
  editablePythonSet = pythonSet.overrideScope editableOverlay;
in
{
  pkg = pythonSet.${pkg-name};
  venv = pythonSet.mkVirtualEnv "${pkg-name}-env" workspace.deps.default;
  venvAll = pythonSet.mkVirtualEnv "${pkg-name}-env-all" workspace.deps.all;
  editableVenv = editablePythonSet.mkVirtualEnv "${pkg-name}-dev-env" workspace.deps.all;
}
