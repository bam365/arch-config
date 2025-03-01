if status is-login
    source $HOME/.config/fish/profile.fish
end

if status is-interactive
    function fishprof 
        source $HOME/.config/fish/profile.fish
    end
end
