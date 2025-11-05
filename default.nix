{
  sources ? import ./npins,
  system ? builtins.currentSystem,
  pkgs ? import sources.nixpkgs {
    inherit system;
    config = { };
    overlays = [
      ((import (sources.lean4-nix + "/lib/overlay.nix")).readToolchainFile ./lean-toolchain)
    ];
  },
}:
let
  watch-blueprint = pkgs.writeShellScriptBin "watch-blueprint" ''
    rm -rf blueprint/web
    leanblueprint web
    echo "Watching for changes in blueprint/src/..."
    ${pkgs.inotify-tools}/bin/inotifywait -e close_write,moved_to,create -m -r blueprint/src |
      while read -r directory events filename; do
        if [[ "$filename" = *tex ]]; then
          echo "Change detected in $directory$filename"
          rm -rf blueprint/web
          leanblueprint web
        fi
      done
  '';

  # tex = (
  #   pkgs.texlive.combine {
  #     inherit (pkgs.texlive)
  #       scheme-basic
  #       wrapfig
  #       amsmath
  #       ulem
  #       hyperref
  #       capt-of
  #       enumitem
  #       ;
  #   }
  # );
  tex = pkgs.texliveMedium.withPackages (
    ps: with ps; [
      enumitem
      cleveref
    ]
  );

  blueprintBuildInputs = with pkgs; [
    leanblueprint
    tex
    lean.lean-all
  ];

in
{
  shell = pkgs.mkShell {
    buildInputs = with pkgs; [
      leanblueprint
      tex
      elan
      watch-blueprint

      uv
      graphviz
      python3Packages.livereload
    ];
  };

  blueprint.web = pkgs.stdenvNoCC.mkDerivation {
    name = "blueprint-web";
    src = ./.;
    buildInputs = blueprintBuildInputs;

    # lake exe cache get || true
    buildPhase = ''
      leanblueprint web
      mkdir -p $out
      cp -r blueprint/web $out/blueprint
    '';
    # lake -R -Kenv=dev build VekkuliBlueprint:docs
  };

  blueprint.pdf = pkgs.stdenvNoCC.mkDerivation {
    name = "blueprint-pdf";
    src = ./.;
    buildInputs = blueprintBuildInputs ++ [ pkgs.texliveMedium ];

    # lake exe cache get || true
    buildPhase = ''
      leanblueprint pdf
      mkdir -p $out
      cp -r blueprint/print $out/blueprint
    '';
    # lake -R -Kenv=dev build VekkuliBlueprint:docs
  };

  docs = pkgs.lean.buildLeanPackage {
    name = "docs";
    src = ./.;
    roots = [ "VekkuliBlueprint:docs" ];
  };

  formatter = pkgs.nixpkgs-fmt;
}
