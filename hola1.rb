# frozen_literal_string

class GitTest

  def self.create_branch(n)
    branch_name = "test_#{n}"
    `git checkout -b #{branch_name}`
    File.new("#{branch_name}.txt", 'w').close
    `git add '#{branch_name}.txt'`
    `git commit -m '#{branch_name} added'`
    `git push`
  end

end

10.times do |n|
  GitTest.create_branch(n)
end