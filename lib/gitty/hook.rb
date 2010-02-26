class Gitty::Hook
  include Gitty::Helpers
  include FileUtils
  attr_accessor :path

  def initialize(options = {})
    options.each do |k,v|
      send("#{k}=", v)
    end
    if installed?
      extend Gitty::Hook::InstalledHookStrategy
    else
      extend Gitty::Hook::AvailableHookStrategy
    end
  end

  def self.available_hooks_search_paths
    Gitty.asset_paths.map { |ap| File.join(ap, "hooks") }
  end

  def self.installed_hooks_search_paths
    [installed_hooks_path(:local), installed_hooks_path(:shared)]
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

  def self.find_all(filters = {})
    paths = installed_hooks_search_paths + available_hooks_search_paths
    candidates = find_all_in_paths(paths)
    filter_candidates(candidates, filters)
  end

  def self.filter_candidates(candidates, filters = {})
    filters.each do |field, value|
      candidates = candidates.select { |c| c.send(field) == value }
    end
    candidates
  end

  def self.find(name, options = {})
    find_all(options.merge(:name => name)).first
  end

  def self.find_all_in_paths(paths)
    paths.map { |hook_path| Dir.glob(File.join(hook_path, "*")) }.flatten.map do |path|
      Gitty::Hook.new(:path => path)
    end
  end

  def self.extract_meta_data(string_or_io)
    io = string_or_io.respond_to?(:readline) ? string_or_io : StringIO.new(string_or_io)
    meta_yaml = ""
    begin
      while line = io.readline
        next unless line.match(/^# (description.+)/)
        meta_yaml = "#{$1}\n"
        break
      end

      while line = io.readline
        break unless line.match(/^#()$/) || line.match(/^# (.*?)$/)
        meta_yaml << "#{$1}\n"
      end
    rescue EOFError
    end
    meta_yaml.empty? ? nil : YAML.load(meta_yaml)
  end

  def installed?
    install_kind ? true : false
  end
  alias installed installed?

  def install_kind
    case
    when path.include?(self.class.installed_hooks_path(:local).to_s) then :local
    when path.include?(self.class.installed_hooks_path(:shared).to_s) then :shared
    end
  end

  def name
    File.basename(path)
  end

  def <=>(other)
    path <=> other.path
  end

  def meta_data
    @meta_data ||= self.class.extract_meta_data(File.read(path))
  end

  module AvailableHookStrategy
    def install(which = :local)
      target_hook_path = existing_directory!(self.class.installed_hooks_path(which))
      target_helper_path = existing_directory!(self.class.installed_helpers_path(which))
      base_directory = self.class.installed_path(which)
      cp(path, target_hook_path + name)
      chmod(0755, target_hook_path + name)
      meta_data["targets"].each do |target|
        ln_sf(
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

    def uninstall
      target_hook_path = path
      base_directory = self.class.installed_path(install_kind)
      meta_data["targets"].each do |target|
        targetd_path = base_directory + "#{target}.d"
        rm_f(targetd_path + name)
        FileUtils.rmdir(targetd_path) if Dir.glob(targetd_path + "*").empty?
      end
      rm(target_hook_path)
      # TODO - clean up helpers
    end
  end

  private :path=
end