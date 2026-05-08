{
  inputs,
  flake-parts-lib,
  ...
}:
let
  inherit (flake-parts-lib) importApply;

in
{
  flake.flakeModules.default = importApply ./_module.nix {
    inherit flake-parts-lib;
    inherit (inputs)
      uv2nix
      pyproject-nix
      pyproject-build-systems
      nixpkgs-lib
      ;
  };
}
