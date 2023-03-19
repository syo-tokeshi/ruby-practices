# frozen_string_literal: true

require 'etc'
require_relative 'ls'

class DetailedFile
  def initialize(detailed_file, file_name)
    @blocks = blocks(detailed_file)
    @mode = mode(detailed_file)
    @type = type(@mode, file_name)
    @permission = permission(@mode)
    @nlink = nlink(detailed_file)
    @user = user(detailed_file)
    @group = group(detailed_file)
    @size = size(detailed_file)
    @mtime = mtime(detailed_file)
    @file_name = displayed_filename(file_name)
  end

  def informations
    [@blocks, @type, @permission, @nlink, @user, @group, @size, @mtime, @file_name]
  end

  private

  def blocks(file)
    file.blocks
  end

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

  def align_file_info(file_info, added_space = 1, right_justified_flag: true)
    file_info_length = file_info.length
    max_length = file_info_length + added_space
    if right_justified_flag
      file_info.rjust(max_length)
    else
      file_info.ljust(max_length)
    end
  end

  def user(file)
    align_file_info(Etc.getpwuid(file.uid).name)
  end

  def group(file)
    align_file_info(Etc.getgrgid(file.gid).name, 2)
  end

  def size(file)
    file.size.to_s.rjust(6)
  end

  def mtime(file)
    Date.today.year ? file.mtime.strftime('%_m %e %H:%M') : file.mtime.strftime('%_m %e  %Y')
  end

  def displayed_filename(file)
    return " #{file} -> #{File.readlink(file)}" if FileTest.symlink?(file)

    file.prepend(' ')
  end
end
