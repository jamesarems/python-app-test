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
                    python39Packages.virtualenv
                    kube3d
                    nats-server
                    natscli
                    nats-top
                    ];
                env = {
                    PYTHON_APP = "hello-world";
                    NIX_LAB_K8S = "yes";

                };
                processes = {
                  ping.exec = "ping google.com";
                };
                languages.python.enable = true;
                enterShell = ''
                    echo "*************************************************"
                    echo "Welcome to K8S Lab"
                    echo
                    echo "To start K8S server , follow below steps -"
                    echo "Step 1 : lab-nats-cluster"
                    echo "Step 2 : Open New Tab, Run - lab-k8s-cluster-create"
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
                scripts.lab-snowplow-env.exec = ''
                    cd $LAB_DIR/snowplow
                    virtualenv venv
                    source venv/bin/activate
                    pip3 install -r requirements.txt
                '';
                scripts.lab-k8s-cluster-create.exec = ''
                    lab-nats-kv-create
                    k3d cluster create --config k3d-config/k3d-config-1.yaml -p "31000-31050:31000-31050@server:0"
                    k3d cluster create --config k3d-config/k3d-config-2.yaml -p "31051-31100:31051-31100@server:0"
                '';
                scripts.lab-k8s-cluster-delete.exec = ''
                    k3d cluster delete --config k3d-config/k3d-config-1.yaml
                    k3d cluster delete --config k3d-config/k3d-config-2.yaml
                    lab-nats-kv-delete
                '';
                scripts.lab-nats-cluster.exec = ''
                    nats-server --user nats --pass nats -m 8222 -js -c nats/server.conf
                '';
                scripts.lab-nats-kv-create.exec = ''
                    nats --user nats --password nats kv add my-lab-1
                    nats --user nats --password nats kv add my-lab-2
                '';
                scripts.lab-nats-kv-delete.exec = ''
                    nats --user nats --password nats kv del my-lab-1 -f
                    nats --user nats --password nats kv del my-lab-2 -f
                '';
                }
            ];
        };
      }
    );
}