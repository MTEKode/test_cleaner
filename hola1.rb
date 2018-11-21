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
    Octokit::Client.new(:login => 'mtoribio', :password => 'FDpb08!!')
  end
end

class GitBranch
  attr_accessor :date, :name, :author
  def initialize(date, name, author)
    @date = date
    @name = name
    @author = author
  end

  def self.parse(string)
    split_string = string.strip.split(' ')
    date = DateTime.parse("#{split_string[0]} #{split_string[1]} +0100")
    name = split_string.last.to_s
    author = "#{split_string[6]} #{split_string[7]}"

    new(date, name, author)
  end

  def self.get_all(merged: true)
    out = `for branch in \`git branch -r #{merged ? '--merged' : '--no-merged'} | grep -v HEAD\`; do echo -e \`git show --format="%ci %cr %an" $branch | head -n 1\` \\t$branch; done | sort -r`
    out.split("\n").map do |branch|
      parse(branch)
    end
  end

  def self.clear_old
    get_all(merged: false).each do |b|
      b.remove if b.can_removed_old?
    end
    clear_local
  end

  def self.clear_local
    `git fetch --all --prune`
  end

  def can_removed_old?
    # branch if !branch[:name].include?('master') && branch[:date]
    !@name.include?('master') && @date > DateTime.parse('Tue, 20 Nov 2018 13:50:17 +0100')
  end

  def remove
    origin, name = @name.split('/')
    `git push https://mtoribio:FDpb08!!@github.com/mtoribio/test_cleaner.git --delete #{name}`
  end
end

# 1 vez al mes:
# * Merged que llevan 1 mes sin actualizar.
# * No merged que llevan 6 meses sin actualizar.
#
