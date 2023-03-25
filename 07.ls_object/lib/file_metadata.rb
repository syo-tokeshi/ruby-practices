# frozen_string_literal: true

require 'etc'

class FileMetadata
  attr_reader :blocks

  def initialize(file_name)
    file_with_metadata = File::Stat.new(file_name)
    @blocks = file_with_metadata.blocks
    @mode = mode(file_with_metadata)
    @type = type(@mode, file_name)
    @permission = permission(@mode)
    @nlink = nlink(file_with_metadata)
    @user = user(file_with_metadata)
    @group = group(file_with_metadata)
    @size = size(file_with_metadata)
    @mtime = mtime(file_with_metadata)
    @displayed_file_name = displayed_file_name(File.basename(file_name))
  end

  def metadata
    [@type, @permission, @nlink, @user, @group, @size, @mtime, @displayed_file_name].join
  end

  private

  def mode(file)
    file.mode.to_s(8).rjust(6, '0')
  end

  def type(mode, file_name)
    return 'l' if FileTest.symlink?(file_name)

    {
      '04' => 'd',
      '10' => '-'
    }[mode.slice(0, 2)]
  end

  def permission(mode)
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

  def nlink(file)
    file.nlink.to_s.rjust(4)
  end

  def align_file_metadata(file_metadata, added_space = 1)
    file_metadata_length = file_metadata.length
    max_length = file_metadata_length + added_space
    file_metadata.rjust(max_length)
  end

  def user(file)
    align_file_metadata(Etc.getpwuid(file.uid).name)
  end

  def group(file)
    align_file_metadata(Etc.getgrgid(file.gid).name, 2)
  end

  def size(file)
    file.size.to_s.rjust(6)
  end

  def mtime(file)
    file.mtime.strftime('%_m %_d %H:%M')
  end

  def displayed_file_name(file)
    return " #{file} -> #{File.readlink(file)}" if FileTest.symlink?(file)

    " #{file}"
  end
end
