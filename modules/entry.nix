{ flake-parts-lib, ... }:
let
  inherit (flake-parts-lib) importApply;
in
{
  flake.flakeModules.default = importApply ./_module.nix {

  };
}
