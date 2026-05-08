{
  flake-parts-lib,
  nixpkgs-lib,
  uv2nix,
  pyproject-nix,
  pyproject-build-systems,
  ...
}:
let
  inherit (flake-parts-lib) importApply;
in
{
  flake.flakeModules.default = importApply ./_module.nix {
    inherit
      flake-parts-lib
      nixpkgs-lib
      uv2nix
      pyproject-nix
      pyproject-build-systems
      ;
  };
}
