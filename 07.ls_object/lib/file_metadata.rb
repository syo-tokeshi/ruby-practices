# frozen_string_literal: true

require 'etc'

class FileMetadata
  attr_reader :blocks

  def initialize(file_name, path)
    file_with_metadata = File::Stat.new(file_name)
    @blocks = get_blocks(file_with_metadata)
    @mode = get_mode(file_with_metadata)
    @type = get_type(@mode, file_name)
    @permission = get_permission(@mode)
    @nlink = get_nlink(file_with_metadata)
    @user = get_user(file_with_metadata)
    @group = get_group(file_with_metadata)
    @size = get_size(file_with_metadata)
    @mtime = get_mtime(file_with_metadata)
    delete_directory_name(file_name, path) if !path.nil? && FileTest.directory?(path)
    @displayed_file_name = get_displayed_file_name(file_name)
  end

  def metadata
    [@type, @permission, @nlink, @user, @group, @size, @mtime, @file_name].join
  end

  private

  def delete_directory_name(file_name, path)
    file_name.delete!("#{path}/")
  end

  def get_blocks(file)
    file.blocks
  end

  def get_mode(file)
    file.mode.to_s(8).rjust(6, '0')
  end

  def get_type(mode, file_name)
    return 'l' if FileTest.symlink?(file_name)

    {
      '04' => 'd',
      '10' => '-'
    }[mode.slice(0, 2)]
  end

  def get_permission(mode)
    permissions = mode.slice(3, 3).chars.map do |permission|
      {
        '0' => '---',
        '1' => 'x--',
        '2' => 'w--',
        '4' => 'r--',
        '5' => 'r-x',
        '6' => 'rw-',
        '7' => 'rwx'
      }[permission]
    end
    permissions.join
  end

  def get_nlink(file)
    file.nlink.to_s.rjust(4)
  end

  def align_file_attribute(file_attribute, added_space = 1, right_justified_flag: true)
    file_attribute_length = file_attribute.length
    max_length = file_attribute_length + added_space
    if right_justified_flag
      file_attribute.rjust(max_length)
    else
      file_attribute.ljust(max_length)
    end
  end

  def get_user(file)
    align_file_attribute(Etc.getpwuid(file.uid).name)
  end

  def get_group(file)
    align_file_attribute(Etc.getgrgid(file.gid).name, 2)
  end

  def get_size(file)
    file.size.to_s.rjust(6)
  end

  def get_mtime(file)
    file.mtime.strftime('%_m %_d %H:%M')
  end

  def get_displayed_file_name(file)
    return " #{file} -> #{File.readlink(file)}" if FileTest.symlink?(file)

    " #{file}"
  end
end
