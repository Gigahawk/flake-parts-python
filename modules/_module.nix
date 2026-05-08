{
  flake-parts-lib,
  nixpkgs-lib,
  uv2nix,
  pyproject-nix,
  pyproject-build-systems,
  ...
}:
let
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (nixpkgs-lib.lib)
    mkDefault
    mkOption
    mkIf
    types
    ;
in
{
  config,
  self,
  inputs,
  ...
}:
{
  options.perSystem = mkPerSystemOption (
    { config, pkgs, ... }:
    let
      cfg = config.wrapPython;
      pkg-name = import ./_package-name.nix { inherit (cfg) workspaceRoot; };
      venv = import ./_venv.nix {
        inherit (nixpkgs-lib) lib;
        inherit pkgs;

        inherit (cfg)
          workspaceRoot
          pythonPackage
          pyprojectOverridesPath
          ;

        inherit uv2nix pyproject-nix pyproject-build-systems;
      };
      mkDevshell = import ./_mkDevshell.nix {
        inherit pkgs venv;
        inherit (nixpkgs-lib) lib;
        inherit (cfg) pythonPackage;
      };
      inherit (pkgs.callPackages pyproject-nix.build.util { }) mkApplication;
    in
    {
      options.wrapPython = {
        pythonPackage = mkOption {
          description = ''
            Python package to use
          '';
          type = types.package;
          default = pkgs.python314;
        };
        workspaceRoot = mkOption {
          description = ''
            Path to uv2nix workspaceRoot
          '';
          type = types.path;
        };
        pyprojectOverridesPath = mkOption {
          description = ''
            Pyproject overrides required to build with uv2nix
          '';
          type = types.nullOr types.path;
          default = null;
        };
        # TODO: add an option for a python3Packages style package?
        enableDevshell = mkOption {
          description = ''
            Enable devshell.

            Will be created as devShells.venv and aliased to devShells.default
          '';
          type = types.bool;
          default = true;
        };
        enableUvDevshell = mkOption {
          description = ''
            Enable uv devshell. ()
            This is a fallback shell that does not depend on the venv to allow for modifying
            uv.lock in case the default devshell no longer builds.

            Will be created as devShells.uv
          '';
          type = types.bool;
          default = true;
        };
        enableBinPackage = mkOption {
          description = ''
            Build a package output containing the project entry points.

            Will be created as packages.''${project-name} and aliased to packages.default.
            project-name is the name specified in pyproject.toml
          '';
          type = types.bool;
          default = true;
        };
      };
      config = {
        devShells = rec {
          venv = mkIf cfg.enableDevshell (mkDevshell {
            withVenv = true;
          });
          uv = mkIf cfg.enableUvDevshell (mkDevshell {
            withVenv = false;
          });
          default = mkIf cfg.enableDevshell (mkDefault venv);
        };
        packages =
          let
            app = mkApplication {
              inherit (venv) venv;
              package = venv.pkg;
            };
          in
          {
            ${pkg-name} = mkIf cfg.enableBinPackage app;
            default = mkIf cfg.enableBinPackage (mkDefault app);
          };
      };
    }
  );
}
