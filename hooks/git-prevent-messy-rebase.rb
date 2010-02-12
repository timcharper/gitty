#!/usr/bin/env ruby

target_branch = ARGV[0]
latest_commit = %x{git rev-list #{target_branch}..HEAD}.split("\n").last
other_branches_with_commit = %x{git branch --contains #{latest_commit}}.split("\n").select { |l| ! /^ *\*/.match(l) }.map {|b| b.strip }
if other_branches_with_commit.empty?
  exit 0
else
  puts "Running this rebase would cause commit #{latest_commit[0..-7]} be rewritten, but it's included in the history of #{other_branches_with_commit * ", "}\n\n\n"
  system("git show #{latest_commit} --pretty=oneline")
  puts "\n\n\n"
  exit 1
end
