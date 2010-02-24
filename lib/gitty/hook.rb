class Gitty::Hook
  include Gitty::Helpers
  include FileUtils
  attr_accessor :path

  def initialize(options = {})
    options.each do |k,v|
      send("#{k}=", v)
    end
    extend Gitty::Hook::AvailableHookStrategy
  end

  def self.available_hooks_search_paths
    Gitty.asset_paths.map { |ap| File.join(ap, "hooks") }
  end

  def self.installed_path(which = :local)
    Pathname.new(".git/hooks/#{which}")
  end

  def self.installed_hooks_path(which = :local)
    installed_path(which) + "hooks"
  end

  def self.installed_helpers_path(which = :local)
    installed_path(which) + "helpers"
  end

  def self.find_all(kind, filters = {})
    candidates =
      case kind
      when :available
        find_all_in_paths(available_hooks_search_paths)
      end

    filter_candidates(candidates, filters)
  end

  def self.filter_candidates(candidates, filters = {})
    filters.each do |field, value|
      candidates = candidates.select { |c| c.send(field) == value }
    end
    candidates
  end

  def self.find(name, options)
    find_all(options[:kind], :name => name).first
  end

  def self.find_all_in_paths(paths)
    paths.map { |hook_path| Dir.glob(File.join(hook_path, "*")) }.flatten.map do |path|
      Gitty::Hook.new(:path => path)
    end
  end

  def installed

  end

  def name
    File.basename(path)
  end

  def <=>(other)
    path <=> other.path
  end

  def meta_data
    @meta_data ||= Gitty.extract_meta_data(File.read(path))
  end

  module AvailableHookStrategy
    def install(which = :local)
      target_hook_path = existing_directory!(self.class.installed_hooks_path(which))
      target_helper_path = existing_directory!(self.class.installed_helpers_path(which))
      base_directory = self.class.installed_path(which)
      cp(path, target_hook_path + name)
      chmod(0755, target_hook_path + name)
      meta_data["targets"].each do |target|
        ln_s(
          "../hooks/#{name}",
          file_with_existing_directory!(base_directory + "#{target}.d" + name)
        )
      end
      (meta_data["helpers"] || []).each do |helper|
        cp(Gitty.find_asset("helpers/#{helper}"), target_helper_path + helper)
        chmod(0755, target_helper_path + helper)
      end
    end

    def uninstall
      # do nothing
    end
  end

  module InstalledHookStrategy
    def install(which = :local)
      # do nothing
    end
  end

  private :path=
end