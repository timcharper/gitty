Given "that I have a git repository with some commits" do
  run("git init && echo content > README && git add README && git commit -m 'initial commit'")
end

