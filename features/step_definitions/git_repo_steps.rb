Given "I have a git repository with some commits" do
  run("git init && echo content > README && git add README && git commit -m 'initial commit'")
end

Given "I have a git repository activated with gitty" do
  Given "I have a git repository with some commits"
  run("#{BIN_PATH}/git-hook init")
end
