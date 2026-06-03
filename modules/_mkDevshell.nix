{
  pkgs,
  lib,
  venv,
  pythonPackage,
  ...
}:
(
  {
    withVenv ? true,
    ...
  }:
  let
    virtualenv = venv.editableVenv;
  in
  pkgs.mkShell {
    packages =
      with pkgs;
      [
        uv
        git
        pythonPackage
      ]
      ++ lib.optional withVenv virtualenv;

    env = {
      UV_NO_SYNC = "1";
      UV_PYTHON = pythonPackage.interpreter;
      UV_PYTHON_DOWNLOADS = "never";
    }
    // lib.optionalAttrs pkgs.stdenv.isLinux {
      # LD_LIBRARY_PATH = lib.makeLibraryPath pkgs.pythonManylinuxPackages.manylinux1;
    };

    shellHook =
      if withVenv then
        ''
          unset PYTHONPATH
          export REPO_ROOT=$(git rev-parse --show-toplevel)
          . ${virtualenv}/bin/activate
        ''
      else
        "";
  }
)
