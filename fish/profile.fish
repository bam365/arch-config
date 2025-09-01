set -U fish_greeting ''

set -gx BUN_INSTALL "$HOME/.bun"
# Node version manager
set -gx FNM_INSTALL "$HOME/.fnm"


set -gx PATH $HOME/.local/bin \
             $HOME/.ghcup/bin \
             $HOME/.cabal/bin \
             $HOME/.dotnet/tools \
             $HOME/.cargo/bin \
             $HOME/.nix-profile/bin \
             $FNM_INSTALL \
             $BUN_INSTALL \
             $PATH

# Opam
test -r $HOME/.opam/opam-init/init.fish && . $HOME/.opam/opam-init/init.fish > /dev/null 2> /dev/null || true

# Initialize FNM
if type -q fnm
    fnm env --use-on-cd --shell fish | source
end
