{ workspaceRoot, ... }:
let
  pyproject = builtins.fromTOML (builtins.readFile (workspaceRoot + "/pyproject.toml"));
in
pyproject.project.name
