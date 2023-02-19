{
  description = "Python application flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/22.11";
    flake-utils.url = "github:numtide/flake-utils";
    devenv.url = "github:cachix/devenv";
  };

  outputs = { self, nixpkgs, devenv, flake-utils} @inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {inherit system;};
      in
      {
        devShells.default = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [
                {
                packages = with pkgs; [ 
                    python39Full
                    python39Packages.poetry
                    ];
                env = {
                    PYTHON_APP = "hello-world";
                };
                languages.python.enable = true;
                enterShell = ''
                    echo "Welcome to Python Flask app Dev Shell"
                    echo
                    echo "Check lab-* commands to know more"
                '';
                scripts.lab-run-program.exec = ''
                    lab-run-init
                    poetry run flaskapp
                '';
                scripts.lab-run-init.exec = ''
                    poetry init -n --name flaskapp
                    poetry add $( cat flaskapp/requirements.txt )
                '';
                }
            ];
        };
      }
    );
}