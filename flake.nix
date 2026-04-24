{
  description = "Flypper Lobster, a Lobster language arcade bird game";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.${system} = {
        default = pkgs.mkShell {
          inputsFrom = [ pkgs.lobster ];

          packages = [
            pkgs.bash
            pkgs.cmake
            pkgs.gnumake
            pkgs.just
            pkgs.lobster
            pkgs.perl
            pkgs.pkg-config
          ];

          LOBSTER_SRC = "${pkgs.lobster.src}";
        };
      };
    };
}
