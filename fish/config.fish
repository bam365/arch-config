if status is-login
    source $HOME/.config/fish/profile.fish
end

if status is-interactive
    function fish_prompt
        string join '' -- (set_color cyan) $USER  ' ' (prompt_pwd) ' ' (fish_git_prompt) 
        string join '' -- (set_color normal) '> '
    end

    function fishprof 
        source $HOME/.config/fish/profile.fish
    end
end
