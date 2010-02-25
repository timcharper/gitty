Given "I have a git repository with some commits" do
  run("git init && echo content > README && git add README && git commit -m 'initial commit'")
end

Given "I have a git repository initialized with gitty" do
  Given "I have a git repository with some commits"
  run("git hook init")
end

Given /^the remote "(.+)" points to a bare repository at "(.+)"$/ do |remote, repo_dir|
  repo_dir = interpolate_env_vars!(repo_dir)
  run("git remote add origin '#{repo_dir}'")
  in_current_dir do
    FileUtils.mkdir_p(repo_dir)
    in_dir(repo_dir) do
      run("git init --bare")
    end
  end
end

Then /^the latest commit on ([^ ]+) should contain "(.+)"$/ do |branch, contents|
  run("git show #{branch}")
  last_stdout.should include(contents)
end

When /^I clone "(.+)" as "(.+)"$/ do |source, path|
  source = interpolate_env_vars!(source)
  in_dir(SandboxWorld::TMP_PATH.to_s) do
    run("git clone '#{source}' #{path}")
  end
end



