# frozen_literal_string
require 'awesome_print'
require 'date'
require 'active_support/all'
require 'octokit'

class GitTest
  def self.create_branch(n)
    `git checkout master`
    `git pull`
    branch_name = "test_#{n}"
    `git checkout -b #{branch_name}`
    File.new("#{branch_name}.txt", 'w').close
    `git add '#{branch_name}.txt'`
    `git commit -m '#{branch_name} added'`
    `git push`
  end

  def self.task
    repo = 158385880
    c = Octokit::Client.new(:login => 'mtoribio', :password => 'FDpb08!!')
    c.branches(repo).each do |b|
      if b[:name] != 'master'
        b = c.branch(repo, b[:name])
        pr_closed = c.pull_requests(repo, head: "origin:#{b[:name]}", state: 'closed')
        pr_open = c.pull_requests(repo, head: "origin:#{b[:name]}", state: 'open')
        # can delete?
        ap b[:commit][:commit][:author][:date]
        can_be_delete = pr_open.find_index {|pr| pr[:updated_ad].to_date > Date.now - 9.month} != nil ||
            pr_closed.find_index {|pr| pr[:merged_at].to_date > Date.now - 3.week} != nil ||
            pr_closed.count + pr_open.count <= 0 && b[:commit][:commit][:author][:date].to_date > Date.today - 3.week
        ap "#{b[:name]} > #{can_be_delete}"
        c.delete_branch(repo, b[:name]) if can_be_delete
      end
    end
  end
end


# Work flow:
# * Branch con 3 semanas sin actualizar con el pull cerrado.
# * Branch con 9 meses sin actualizar con el pull abierto?
10.times { |a| GitTest.create_branch a }