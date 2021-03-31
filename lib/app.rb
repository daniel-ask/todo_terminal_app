# frozen_string_literal: true

require 'json'
require 'tty-prompt'
require 'artii'
class App
  attr_accessor :tasks

  def initialize(file_path)
    # absolute_path = '/Users/dask/CoderAcademy/todo-app'
    @prompt = TTY::Prompt.new
    @file_path = file_path
    load_data(file_path)
  end

  def run
    if ARGV.empty?
      run_normal
    else
      run_with_argv
    end
  end

  def run_normal
    loop do
      system 'clear'
      a = Artii::Base.new
      puts a.asciify('Todo!')
      puts '-' * 20
      display_tasks
      puts '-' * 20
      # display_menu
      # process_menu(menu_input)
      input = @prompt.select('Menu:') do |menu|
        menu.choice 'Add Task', 1
        menu.choice 'Complete Task', 2
        menu.choice 'Edit Task', 3
        menu.choice 'Delete Task', 4
        menu.choice 'Exit', 5
      end
      puts '-' * 20
      process_menu(input)
    end
  end

  def run_with_argv
    first, *other = ARGV
    ARGV.clear
    case first
    when 'list'
      display_tasks
    when 'add'
      add_task(other.join(' '))
      puts "#{other.join(' ')} has been added"
    when 'complete', 'c'
      index = other[0].to_i - 1
      toggle_complete(index)
      puts "#{@tasks[index][:task]} has been switched"
    when 'edit', 'e'
      index, *new_task = other
      change_task(new_task.join(' '), index.to_i - 1)
      puts 'Changed task'
    when 'delete', 'd'
      index = other[0].to_i - 1
      puts "#{@tasks[index][:task]} has been deleted"
      delete_task(index)
    else
      puts 'INVALID COMMAND LINE ARGUMENT'
    end
    File.write(@file_path, @tasks.to_json)
  end

  def process_menu(menu_choice)
    case menu_choice
    when 1
      display_new_task
      add_task(task_add)
    when 2
      toggle_task_action
    when 3
      edit_task
    when 4
      delete_task_action
    when 5
      File.write(@file_path, @tasks.to_json)
      exit
    end
  end

  def edit_task
    index = select_task_action
    display_new_task
    change_task(task_add, index)
  end

  def delete_task_action
    index = select_task_action
    delete_task(index)
  end

  def toggle_task_action
    index = select_task_action
    toggle_complete(index)
  end

  def select_task_action
    display_select_task
    index = select_task
    raise StandardError, 'Task is not within range' if index.negative? || index > @tasks.length

    index
  rescue StandardError
    puts "Task can't be found"
    retry
  end

  def add_task(task_input)
    @tasks << { task: task_input, completed: false }
  end

  def change_task(edited_task, index)
    @tasks[index][:task] = edited_task
  end

  def delete_task(index)
    @tasks.delete_at(index)
  end

  def toggle_complete(index)
    @tasks[index][:completed] = !@tasks[index][:completed]
  end

  def load_data(file_path)
    json_data = JSON.parse(File.read(file_path))
    @tasks = json_data.map do |task|
      task.transform_keys(&:to_sym)
    end
  rescue Errno::ENOENT
    File.open(file_path, 'w+')
    File.write(file_path, [])
    retry
  end

  def display_add_task
    puts 'Enter name of task'
  end

  def display_tasks
    puts 'Tasks:'
    @tasks.each_with_index do |task, index|
      puts "#{index + 1}. #{task[:task]} [#{task[:completed] ? 'X' : ' '}]"
    end
  end

  def display_new_task
    puts 'Please enter new task'
  end

  def display_select_task
    puts 'Please enter the number of the task:'
  end

  def display_welcome
    puts 'WELCOME TO MY APP!'
  end

  def menu_input
    gets.to_i
  end

  def select_task
    gets.to_i - 1
  end

  def task_add
    gets.strip
  end
end
