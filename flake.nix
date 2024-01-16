{
  description = "Build LaTeX document with minted";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  
  outputs = { self, nixpkgs, flake-utils }:
    {
      templates.document = {
        path = ./.;
        description = "LaTeX document with minted support";
      };

      lib.latexmk = import ./build-document.nix;

      defaultTemplate = self.templates.document;
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        latex-packages = with pkgs; [
          (texlive.combine {
            inherit (texlive)
              scheme-full
              framed
              titlesec
              cleveref
              multirow
              wrapfig
              tabu
              threeparttable
              threeparttablex
              makecell
              environ
              biblatex
              biber
              fvextra
              upquote
              catchfile
              xstring
              csquotes
              minted
              dejavu
              comment
              footmisc
              xltabular
              ltablex
              ;
          })
          which
          python39Packages.pygments
          (pkgs.inkscape-with-extensions.override {
            inkscapeExtensions = [ pkgs.inkscape-extensions.textext ];
          })
        ];

        dev-packages = with pkgs; [
          texlab
          zathura
          wmctrl
        ];
      in
      rec {
        devShell = pkgs.mkShell {
          buildInputs = [ latex-packages dev-packages ];
        };

        packages = flake-utils.lib.flattenTree {
          document = import ./build-document.nix {
            inherit pkgs;
            texlive = latex-packages;
            shellEscape = true;
            minted = true;
            SOURCE_DATE_EPOCH = toString self.lastModified;
          };
        };

        defaultPackage = packages.document;
      }
    );
}
#Not avlid inside a nix flake but this is how I generated the dependency graph
#nix-store --query --graph $(nix path-info .) | dot -Tsvg -o out.svg

# pkgs.stdenv.mkDerivation {
#   name = "hello-2.12.1";
#   src = self;
#   buildInputs = [ pkgs.gcc pkgs.gcc13 pkgs.gcc10 ];
#   configurePhase = "echo 'int main() { printf(\"Hello World!\"); }' > hello.c";
#   buildPhase = "gcc -o hello ./hello.c";
#   installPhase = "mkdir -p $out/bin; install -t $out/bin hello";
# };
# inkscape = (pkgs.inkscape-with-extensions.override {
#   inkscapeExtensions = [ pkgs.inkscape-extensions.textext ];
# });
