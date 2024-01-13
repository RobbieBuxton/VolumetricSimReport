{
  description = "A flake for building Hello World";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {

    defaultPackage.x86_64-linux =
      let
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
      in
      pkgs.stdenv.mkDerivation {
        name = "hello-2.12.1";
        src = self;
        buildInputs = [ pkgs.gcc pkgs.gcc13 pkgs.gcc10 ];
        configurePhase = "echo 'int main() { printf(\"Hello World!\"); }' > hello.c";
        buildPhase = "gcc -o hello ./hello.c";
        installPhase = "mkdir -p $out/bin; install -t $out/bin hello";
      };


    devShell.x86_64-linux =
      let
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
      in
      pkgs.mkShell {
        buildInputs = [
          (pkgs.inkscape-with-extensions.override {
            inkscapeExtensions = [ pkgs.inkscape-extensions.textext ];
          })
        ];
      };

  };
}
#Not valid inside a nix flake but this is how I generated the dependency graph
#nix-store --query --graph $(nix path-info .) | dot -Tpng -o out.png
