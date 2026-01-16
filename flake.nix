{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        ruby
        # native dependencies
        gcc
        gnumake
        pkg-config
        zlib
        openssl
        libyaml
        gmp
        readline
        rustc
        # Feel free to change this
        fish
      ];

      nativeBuildInputs = [ pkgs.pkg-config ];

      # Set the default shell
      env = {
        SHELL = "${pkgs.fish}/bin/fish";
      };

      shellHook = ''
        # Launch fish and set environment inside fish.
        # If you change the shell modify this as well.
        exec fish -C '
          # Set local gem directory
          set -gx GEM_HOME $PWD/.gem;
          set -gx PATH $GEM_HOME/bin $PATH;


          # Configure bundler to use local gem path
          bundle config set path $GEM_HOME

          # Install Rails if missing
          if not type -q rails
            echo "Rails not found. Installing Rails..."
            gem install rails
          end

          # Install missing gems with extensions
          if not test -d "$GEM_HOME/gems"
            echo "Installing Ruby gems..."
            bundle install
          end

          # Show versions
          echo "Ruby version: $(ruby --version)"
          echo "Rails version: $(rails --version)"
          direnv deny
        '
      '';
    };
  };
}
