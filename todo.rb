# frozen_string_literal: true

require_relative 'lib/app'

todo = App.new('./data/todo.json')
todo.run
