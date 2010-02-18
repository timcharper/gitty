Then "the following hooks are setup to run all shared and local hooks" do |table|
  table.raw.map(&:first).each do |hook|
    in_current_dir do
      unless File.executable?(".git/hooks/#{hook}")
        raise(Spec::Expectations::ExpectationNotMetError, "expected .git/hooks/#{hook} to be executable")
      end
    end
  end
end
  
