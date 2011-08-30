require 'optparse'

module Kumade
  class Runner
    class << self
      attr_reader :environment
    end

    def self.run(args=ARGV, out=$stdout)
      @out         = out
      @options     = parse_arguments!(args)
      @environment = args.shift || 'staging'

      deploy
    end

    def self.deploy
      if pretending?
        @out.puts "==> In Pretend Mode"
      end
      @out.puts "==> Deploying to: #{environment}"
      Deployer.new(environment, pretending?, @options[:cedar], clearing_cache?).deploy
      @out.puts "==> Deployed to: #{environment}"
    end

    def self.parse_arguments!(args)
      options = {}
      OptionParser.new do |opts|
        opts.banner = "Usage: kumade <environment> [options]"

        opts.on("-p", "--pretend", "Pretend mode: print what kumade would do") do |p|
          options[:pretend] = p
        end

        opts.on("-c", "--cedar", "Use this if your app is on cedar") do |cedar|
          options[:cedar] = cedar
        end

        opts.on("", "--clear_cache", "Clear the Rails cache after deployment") do |clear_cache|
          options[:clear_cache] = clear_cache
        end

        opts.on_tail('-v', '--version', 'Show version') do
          @out.puts "kumade #{Kumade::VERSION}"
          exit
        end

        opts.on_tail('-h', '--help', 'Show this message') do
          @out.puts opts
          exit
        end
      end.parse!(args)

      options
    end

    def self.pretending?
      @options[:pretend]
    end

    def self.clearing_cache?
      @options[:clear_cache]
    end
  end
end
